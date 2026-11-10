// Custom invoice numbers: GST format rules, uniqueness, permissions,
// password-confirmed changes, audit trail, and the auto sequence ignoring
// manual numbers. Real InvoiceService against an ffi SQLite file.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/common/setting_key.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/settings_service.dart';
import 'package:crizavoise/database/invoice_number_service.dart';
import 'package:crizavoise/database/invoice_service.dart';
import 'package:crizavoise/database/payment_service.dart';
import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/models/customer.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/models/product.dart';
import 'package:crizavoise/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tmp = Directory.systemTemp.createTempSync('cv_invnum_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), (call) async => tmp.path);
  });

  tearDownAll(() async {
    await DatabaseHelper().close();
    tmp.deleteSync(recursive: true);
  });

  var dbCounter = 0;
  setUp(() async {
    await DatabaseHelper().switchToFile('invnum_${dbCounter++}.db');
    await ProductService.insertProduct(Product(
        id: 'p1', name: 'Rice', description: '', price: 100, stock: 100, hsncode: '', tax_rate: 0));
  });

  final admin = User(id: 'u0', username: 'admin', password: '', userType: 'admin');
  final staff = User(id: 'u1', username: 'staff', password: '', userType: 'user');
  final customer = Customer(id: 'c1', name: 'Patel', email: '', phone: '', address: '', gstin: '');

  Future<Invoice> add(String id, {String? number, bool manual = false, String type = 'Invoice'}) async {
    final p = (await ProductService.getProductById('p1'))!;
    final inv = Invoice(
      id: id,
      invoiceNumber: number ?? await InvoiceService.generateNextInvoiceNumber(type),
      manualNumber: manual,
      customer: customer,
      items: [InvoiceItem(product: p, quantity: 1)],
      date: DateTime(2026, 4, 1),
      type: type,
    );
    await InvoiceService.insertInvoice(inv);
    return inv;
  }

  group('format (GST CGST Rule 46)', () {
    test('letters, digits, - and / up to 16 characters incl. prefix', () {
      expect(InvoiceNumberService.checkFormat('SGS/24-25/105'), isNull);
      expect(InvoiceNumberService.checkFormat('  '), InvoiceNumberIssue.empty);
      expect(InvoiceNumberService.checkFormat('INV 105'), InvoiceNumberIssue.invalidCharacters);
      expect(InvoiceNumberService.checkFormat('INV#105'), InvoiceNumberIssue.invalidCharacters);
      expect(InvoiceNumberService.checkFormat('1234567890123456'), isNull);
      expect(InvoiceNumberService.checkFormat('12345678901234567'), InvoiceNumberIssue.tooLong);
      expect(InvoiceNumberService.checkFormat('105', prefix: 'SGS/2024-25/'), isNull); // 15
      expect(InvoiceNumberService.checkFormat('10567', prefix: 'SGS/2024-25/'), InvoiceNumberIssue.tooLong);
    });

    test('"105" and "00000105" are the same number', () {
      expect(InvoiceNumberService.normalize('00000105'), InvoiceNumberService.normalize('105'));
      expect(InvoiceNumberService.normalize('inv-7'), InvoiceNumberService.normalize('INV-7'));
    });
  });

  test('prefix matches what PDFs print (INV-, per-type fallback)', () async {
    expect(await InvoiceNumberService.prefixFor('Invoice'), 'INV-');
    await SettingsService.setSetting(SettingKey.invoicePrefix, 'SGS');
    await SettingsService.setSetting(SettingKey.receiptPrefix, 'RCPT--');
    expect(await InvoiceNumberService.prefixFor('Invoice'), 'SGS-');
    expect(await InvoiceNumberService.prefixFor('Quotation'), 'SGS-'); // unset -> invoice prefix
    expect(await InvoiceNumberService.prefixFor('Receipt'), 'RCPT-');
  });

  group('permissions', () {
    test('off by default; staff can never change existing numbers', () {
      expect(InvoiceNumberService.canSetOnNew(admin, CustomNumberAccess.off), isFalse);
      expect(InvoiceNumberService.canChangeExisting(admin, CustomNumberAccess.off), isFalse);
      expect(InvoiceNumberService.canSetOnNew(admin, CustomNumberAccess.admins), isTrue);
      expect(InvoiceNumberService.canSetOnNew(staff, CustomNumberAccess.admins), isFalse);
      expect(InvoiceNumberService.canSetOnNew(staff, CustomNumberAccess.everyone), isTrue);
      expect(InvoiceNumberService.canChangeExisting(staff, CustomNumberAccess.everyone), isFalse);
      expect(InvoiceNumberService.canChangeExisting(admin, CustomNumberAccess.everyone), isTrue);
    });

    test('access setting defaults to off', () async {
      expect(await InvoiceNumberService.access(), CustomNumberAccess.off);
    });
  });

  group('automatic sequence', () {
    test('manual numbers do not disturb it, and taken numbers are skipped', () async {
      await add('i1'); // 00000001
      await add('i2', number: 'INV/2026/900', manual: true);
      expect(await InvoiceService.generateNextInvoiceNumber('Invoice'), '00000002');
      await add('i3', number: '3', manual: true); // someone typed 3
      await add('i4'); // must skip 2? no: 2 is free
      expect((await InvoiceService.getInvoiceById('i4'))!.invoiceNumber, '00000002');
      expect(await InvoiceService.generateNextInvoiceNumber('Invoice'), '00000004'); // 3 is taken
    });

    test('duplicates are detected per document type', () async {
      await add('i1', number: '00000105');
      expect(await InvoiceNumberService.validate('Invoice', '105'), InvoiceNumberIssue.duplicate);
      expect(await InvoiceNumberService.validate('Quotation', '105'), isNull);
      expect(await InvoiceNumberService.validate('Invoice', '105', excludeInvoiceId: 'i1'), isNull);
    });
  });

  group('changing an existing number', () {
    Future<void> allow() => InvoiceNumberService.setAccess(CustomNumberAccess.admins);

    test('is blocked while the feature is off', () async {
      await add('i1');
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i1', newNumber: '500', reason: 'Match paper book', user: admin, password: 'admin'),
        throwsA(isA<InvoiceNumberPermissionException>()),
      );
    });

    test('staff cannot, even when the feature is on', () async {
      await allow();
      await add('i1');
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i1', newNumber: '500', reason: 'Match paper book', user: staff, password: 'x'),
        throwsA(isA<InvoiceNumberPermissionException>()),
      );
    });

    test('needs the admin password and a reason', () async {
      await allow();
      await add('i1');
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i1', newNumber: '500', reason: 'Match paper book', user: admin, password: 'wrong'),
        throwsA(isA<InvoiceNumberPasswordException>()),
      );
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i1', newNumber: '500', reason: ' ', user: admin, password: 'admin'),
        throwsA(isA<InvoiceNumberReasonException>()),
      );
    });

    test('rejects duplicates and bad formats', () async {
      await allow();
      await add('i1');
      await add('i2');
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i2', newNumber: '1', reason: 'typo fix', user: admin, password: 'admin'),
        throwsA(isA<InvoiceNumberValidationException>()),
      );
      expect(
        () => InvoiceNumberService.changeNumber(
            invoiceId: 'i2', newNumber: 'A B', reason: 'typo fix', user: admin, password: 'admin'),
        throwsA(isA<InvoiceNumberValidationException>()),
      );
    });

    test('updates the invoice, its payments and the audit trail', () async {
      await allow();
      final inv = await add('i1');
      final saved = (await InvoiceService.getInvoiceById('i1'))!;
      await PaymentService.addPayment(invoice: saved, amountPaid: 50, datePaid: DateTime(2026, 4, 2));

      await InvoiceNumberService.changeNumber(
          invoiceId: 'i1', newNumber: 'SGS/105', reason: 'Match paper bill book', user: admin, password: 'admin');

      final after = (await InvoiceService.getInvoiceById('i1'))!;
      expect(after.invoiceNumber, 'SGS/105');
      expect(after.manualNumber, isTrue);
      final db = await DatabaseHelper().database;
      final pays = await db.query('invoice_payments', where: 'invoice_id = ?', whereArgs: ['i1']);
      expect(pays.single['invoice_number'], 'SGS/105');

      final log = await InvoiceNumberService.history('i1');
      expect(log.single.oldNumber, inv.invoiceNumber);
      expect(log.single.newNumber, 'SGS/105');
      expect(log.single.changedBy, 'admin');
      expect(log.single.reason, 'Match paper bill book');
    });
  });
}
