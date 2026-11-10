import 'package:sqflite/sqflite.dart';

import 'package:crizavoise/common/setting_key.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/settings_service.dart';
import 'package:crizavoise/database/user_service.dart';
import 'package:crizavoise/models/user.dart';

/// Who may type their own invoice number (Settings, admin only).
enum CustomNumberAccess {
  /// Default: numbers are always automatic.
  off,

  /// Admins may set the number on new invoices and change existing ones.
  admins,

  /// Staff may also set the number on NEW invoices. Changing an existing
  /// invoice's number always stays admin-only.
  everyone;

  static CustomNumberAccess fromKey(String? key) =>
      CustomNumberAccess.values.firstWhere((v) => v.name == key, orElse: () => off);
}

/// Why a typed number can't be used.
enum InvoiceNumberIssue { empty, invalidCharacters, tooLong, duplicate }

/// One row of the number audit trail.
class InvoiceNumberChange {
  final String action; // 'set_on_create' | 'changed'
  final String? oldNumber;
  final String newNumber;
  final String changedBy;
  final String? reason;
  final DateTime changedAt;

  const InvoiceNumberChange({
    required this.action,
    required this.oldNumber,
    required this.newNumber,
    required this.changedBy,
    required this.reason,
    required this.changedAt,
  });
}

/// Rules for invoice numbers typed by a person instead of generated.
///
/// Guards against misuse:
///  * permission: off by default; admins decide who may set numbers, and
///    only admins can change an existing invoice's number — with a reason
///    and their password ([changeNumber]);
///  * format: Indian GST (CGST Rule 46) — up to 16 characters INCLUDING the
///    prefix, only letters, digits, "-" and "/";
///  * uniqueness per document type (so "105" and "00000105" are the same);
///  * every manual number and change is written to `invoice_number_log`;
///  * manual numbers never disturb the automatic sequence
///    (InvoiceService.generateNextInvoiceNumber ignores them and skips any
///    number already taken).
class InvoiceNumberService {
  static const maxLength = 16;
  static final _allowed = RegExp(r'^[A-Za-z0-9/-]+$');

  static Future<CustomNumberAccess> access() async => CustomNumberAccess.fromKey(
      await SettingsService.getSetting(SettingKey.customInvoiceNumberAccess));

  static Future<void> setAccess(CustomNumberAccess a) =>
      SettingsService.setSetting(SettingKey.customInvoiceNumberAccess, a.name);

  /// The prefix printed before [type]'s number — identical to
  /// PDFService.fetchPdfSettings().prefixFor(type), without loading fonts.
  static Future<String> prefixFor(String type) async {
    String dashed(String raw) {
      final p = raw.replaceFirst(RegExp(r'-+$'), '');
      return p.isNotEmpty ? '$p-' : '';
    }

    final raw = await SettingsService.getSetting(SettingKey.invoicePrefix) ?? 'INV';
    final invoicePrefix = raw.isNotEmpty ? '$raw-' : '';
    Future<String> optional(SettingKey k) async {
      final v = await SettingsService.getSetting(k);
      return (v == null || v.trim().isEmpty) ? invoicePrefix : dashed(v.trim());
    }

    return switch (type) {
      'Quotation' => await optional(SettingKey.quotationPrefix),
      'Receipt' => await optional(SettingKey.receiptPrefix),
      _ => invoicePrefix,
    };
  }

  /// May [user] type the number on a new invoice?
  static bool canSetOnNew(User user, CustomNumberAccess a) =>
      a == CustomNumberAccess.everyone || (a == CustomNumberAccess.admins && user.isAdmin());

  /// May [user] change the number of an existing invoice? Admins only.
  static bool canChangeExisting(User user, CustomNumberAccess a) =>
      a != CustomNumberAccess.off && user.isAdmin();

  /// Format check (no DB). [prefix] is the document prefix printed before
  /// the number; the GST limit applies to the whole printed number.
  static InvoiceNumberIssue? checkFormat(String number, {String prefix = ''}) {
    final n = number.trim();
    if (n.isEmpty) return InvoiceNumberIssue.empty;
    if (!_allowed.hasMatch(n)) return InvoiceNumberIssue.invalidCharacters;
    if ((prefix + n).length > maxLength) return InvoiceNumberIssue.tooLong;
    return null;
  }

  /// Comparison key: case-insensitive, and leading zeros don't count for
  /// purely numeric numbers ("00000105" == "105").
  static String normalize(String number) {
    final n = number.trim().toUpperCase();
    if (RegExp(r'^\d+$').hasMatch(n)) {
      final stripped = n.replaceFirst(RegExp(r'^0+'), '');
      return stripped.isEmpty ? '0' : stripped;
    }
    return n;
  }

  /// Is [number] already used by another (non-deleted) document of [type]?
  static Future<bool> isTaken(String type, String number,
      {String? excludeInvoiceId, DatabaseExecutor? db}) async {
    final exec = db ?? await DatabaseHelper().database;
    final rows = await exec.rawQuery(
      'SELECT id, invoice_number FROM invoices '
      'WHERE type = ? AND invoice_number IS NOT NULL AND deleted_at IS NULL',
      [type],
    );
    final key = normalize(number);
    return rows.any((r) =>
        r['id'] != excludeInvoiceId && normalize(r['invoice_number'] as String) == key);
  }

  /// Full check: format + uniqueness.
  static Future<InvoiceNumberIssue?> validate(String type, String number,
      {String prefix = '', String? excludeInvoiceId}) async {
    final f = checkFormat(number, prefix: prefix);
    if (f != null) return f;
    if (await isTaken(type, number, excludeInvoiceId: excludeInvoiceId)) {
      return InvoiceNumberIssue.duplicate;
    }
    return null;
  }

  /// Records that a new document was saved with a typed number. Call after
  /// the invoice row has been inserted.
  static Future<void> logSetOnCreate({
    required String invoiceId,
    required String type,
    required String? suggestedNumber,
    required String number,
    required User user,
  }) async {
    final db = await DatabaseHelper().database;
    await db.insert('invoice_number_log', {
      'invoice_id': invoiceId,
      'doc_type': type,
      'action': 'set_on_create',
      'old_number': suggestedNumber,
      'new_number': number.trim(),
      'changed_by': user.username,
      'reason': null,
      'changed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Changes an existing document's number. Admin only; requires a reason
  /// and the admin's password. Updates the invoice, the number copies on its
  /// payments and on notes raised against it, and audits the change — all in
  /// one transaction. Receipt numbers already issued are left as issued.
  static Future<void> changeNumber({
    required String invoiceId,
    required String newNumber,
    required String reason,
    required User user,
    required String password,
    String prefix = '',
  }) async {
    final a = await access();
    if (!canChangeExisting(user, a)) {
      throw const InvoiceNumberPermissionException();
    }
    if (reason.trim().length < 3) throw const InvoiceNumberReasonException();
    final verified = await UserService.getUser(user.username, password);
    if (verified == null || !verified.isAdmin()) {
      throw const InvoiceNumberPasswordException();
    }

    final db = await DatabaseHelper().database;
    final rows = await db.query('invoices',
        columns: ['type', 'invoice_number', 'is_draft'], where: 'id = ?', whereArgs: [invoiceId]);
    if (rows.isEmpty) throw StateError('Invoice $invoiceId not found');
    final type = rows.first['type'] as String;
    final old = rows.first['invoice_number'] as String?;
    if ((rows.first['is_draft'] as int? ?? 0) == 1) {
      throw StateError('Drafts get their number when finalized');
    }

    final issue = await validate(type, newNumber, prefix: prefix, excludeInvoiceId: invoiceId);
    if (issue != null) throw InvoiceNumberValidationException(issue);
    final n = newNumber.trim();
    if (old != null && normalize(old) == normalize(n)) return; // nothing to change

    await db.transaction((txn) async {
      // Re-check inside the transaction (another window may have used it).
      if (await isTaken(type, n, excludeInvoiceId: invoiceId, db: txn)) {
        throw const InvoiceNumberValidationException(InvoiceNumberIssue.duplicate);
      }
      await txn.update('invoices', {'invoice_number': n, 'manual_number': 1},
          where: 'id = ?', whereArgs: [invoiceId]);
      await txn.update('invoice_payments', {'invoice_number': n},
          where: 'invoice_id = ?', whereArgs: [invoiceId]);
      await txn.update('invoices', {'original_invoice_number': n},
          where: 'original_invoice_id = ?', whereArgs: [invoiceId]);
      await txn.insert('invoice_number_log', {
        'invoice_id': invoiceId,
        'doc_type': type,
        'action': 'changed',
        'old_number': old,
        'new_number': n,
        'changed_by': user.username,
        'reason': reason.trim(),
        'changed_at': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Audit trail for one document, newest first.
  static Future<List<InvoiceNumberChange>> history(String invoiceId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('invoice_number_log',
        where: 'invoice_id = ?', whereArgs: [invoiceId], orderBy: 'id DESC');
    return [
      for (final r in rows)
        InvoiceNumberChange(
          action: r['action'] as String,
          oldNumber: r['old_number'] as String?,
          newNumber: r['new_number'] as String,
          changedBy: r['changed_by'] as String,
          reason: r['reason'] as String?,
          changedAt: DateTime.parse(r['changed_at'] as String),
        ),
    ];
  }
}

class InvoiceNumberPermissionException implements Exception {
  const InvoiceNumberPermissionException();
}

class InvoiceNumberPasswordException implements Exception {
  const InvoiceNumberPasswordException();
}

class InvoiceNumberReasonException implements Exception {
  const InvoiceNumberReasonException();
}

class InvoiceNumberValidationException implements Exception {
  final InvoiceNumberIssue issue;
  const InvoiceNumberValidationException(this.issue);
}
