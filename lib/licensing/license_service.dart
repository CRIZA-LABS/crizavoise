import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crizavoise/database/company_registry_service.dart';
import 'package:crizavoise/licensing/license_codec.dart';
import 'package:crizavoise/licensing/license_keys.dart';
import 'package:crizavoise/licensing/machine_id.dart';
import 'package:win32/win32.dart' show HKEY_CURRENT_USER;

/// Free trial length.
const trialDays = 30;

/// Days before the end of a trial or a dated licence when reminders start.
const reminderDays = 7;

enum LicenseKind {
  /// Free trial running.
  trial,

  /// Trial over, no licence: data stays viewable, new documents are blocked.
  trialEnded,

  /// Valid licence for this computer.
  licensed,

  /// A dated licence ran out: same limits as [trialEnded].
  licenseExpired,
}

class LicenseState {
  final LicenseKind kind;
  final String deviceCode;
  final DateTime trialStart;

  /// Whole days left in the trial or licence; null for lifetime.
  final int? daysLeft;
  final LicensePayload? license;

  /// The computer's date is earlier than a date this app has already seen.
  final bool clockLooksWrong;

  const LicenseState({
    required this.kind,
    required this.deviceCode,
    required this.trialStart,
    required this.daysLeft,
    this.license,
    this.clockLooksWrong = false,
  });

  /// New invoices, quotations, receipts and notes may be created and saved.
  /// Viewing, printing, exporting and backups always work.
  bool get canCreateDocuments => kind == LicenseKind.trial || kind == LicenseKind.licensed;

  bool get showReminder =>
      canCreateDocuments && daysLeft != null && daysLeft! <= reminderDays;
}

enum ActivationResult { activated, invalid, otherDevice, expired }

/// One place the licence state is kept. Several are used so deleting one
/// (or the app's data folder) doesn't restart the trial.
abstract class LicenseStore {
  Future<String?> read();
  Future<void> write(String value);
}

class MemoryLicenseStore implements LicenseStore {
  String? value;
  MemoryLicenseStore([this.value]);
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
}

class _PrefsStore implements LicenseStore {
  static const _key = 'cv_license_state';
  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);
  @override
  Future<void> write(String v) async =>
      (await SharedPreferences.getInstance()).setString(_key, v);
}

class _FileStore implements LicenseStore {
  final Future<File> Function() _file;
  _FileStore(this._file);
  @override
  Future<String?> read() async {
    final f = await _file();
    return await f.exists() ? f.readAsString() : null;
  }

  @override
  Future<void> write(String v) async {
    final f = await _file();
    await f.parent.create(recursive: true);
    await f.writeAsString(v, flush: true);
  }
}

class _RegistryStore implements LicenseStore {
  static const _subKey = r'Software\Criza Labs\CrizaVoise';
  static const _name = 'State';
  @override
  Future<String?> read() async =>
      WindowsRegistry.readString(HKEY_CURRENT_USER, _subKey, _name);
  @override
  Future<void> write(String v) async =>
      WindowsRegistry.writeString(HKEY_CURRENT_USER, _subKey, _name, v);
}

/// Works out the trial / licence state fully offline.
///
/// Each store keeps `{t: trial start, s: latest date seen, k: licence key}`
/// with a checksum. The earliest trial start and latest date seen across all
/// stores win, so deleting one store, or setting the clock back, doesn't buy
/// more time. A record with a broken checksum counts as an ended trial.
class LicenseService {
  final List<LicenseStore> stores;
  final Future<String> Function() deviceCode;
  final List<int> publicKey;
  final DateTime Function() clock;

  LicenseService({
    required this.stores,
    required this.deviceCode,
    this.publicKey = CrizaKeys.licensePublicKey,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  static LicenseService? _instance;
  static LicenseService get instance => _instance ??= _defaultService();
  static set instance(LicenseService s) => _instance = s;

  static LicenseService _defaultService() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      // Tests must never touch the real registry or files.
      return LicenseService(
          stores: [MemoryLicenseStore()], deviceCode: () async => 'TEST-TEST-TEST-TEST');
    }
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '.';
    return LicenseService(
      stores: [
        _PrefsStore(),
        _FileStore(() async => File('${(await getApplicationSupportDirectory()).path}'
            '${Platform.pathSeparator}.cv_state')),
        if (Platform.isWindows) _RegistryStore(),
        if (!Platform.isWindows)
          _FileStore(() async => File('$home${Platform.pathSeparator}.config'
              '${Platform.pathSeparator}.crizavoise_state')),
      ],
      deviceCode: currentDeviceCode,
    );
  }

  static String? _cachedDevice;

  /// This computer's device code (from the OS machine ID; the installation
  /// ID is the fallback).
  static Future<String> currentDeviceCode() async {
    if (_cachedDevice != null) return _cachedDevice!;
    final id = await MachineId.read() ??
        await CompanyRegistryService.getOrCreateInstallationId();
    return _cachedDevice = await DeviceCode.fromMachineId(id);
  }

  // Not a secret (it ships in the app); it only stops casual hand edits.
  static const _macKey = 'crizavoise-state-v1';

  static String _mac(String body) =>
      Hmac(sha256, utf8.encode(_macKey)).convert(utf8.encode(body)).toString().substring(0, 24);

  static String encodeRecord({required DateTime trialStart, required DateTime seen, String? key}) {
    final body = jsonEncode({
      't': trialStart.toUtc().toIso8601String(),
      's': seen.toUtc().toIso8601String(),
      if (key != null) 'k': key,
    });
    return jsonEncode({'b': body, 'm': _mac(body)});
  }

  /// null = no record; throws [FormatException] for a tampered record.
  static Map<String, dynamic>? decodeRecord(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final outer = jsonDecode(raw) as Map<String, dynamic>;
    final body = outer['b'] as String;
    if (outer['m'] != _mac(body)) throw const FormatException('checksum');
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<String?>> _readAll() async => [
        for (final s in stores)
          await s.read().then<String?>((v) => v).catchError((_) => null),
      ];

  Future<void> _writeAll(String record) async {
    for (final s in stores) {
      try {
        await s.write(record);
      } catch (_) {}
    }
  }

  /// Checks [key] for this computer without saving it.
  Future<(ActivationResult, LicensePayload?)> check(String key, {DateTime? at}) async {
    final p = await LicenseCodec.verify(key, publicKey);
    if (p == null) return (ActivationResult.invalid, null);
    if (p.device != '*' &&
        DeviceCode.normalize(p.device) != DeviceCode.normalize(await deviceCode())) {
      return (ActivationResult.otherDevice, p);
    }
    if (p.isExpiredAt(at ?? clock())) return (ActivationResult.expired, p);
    return (ActivationResult.activated, p);
  }

  /// Reads every store, repairs missing ones and returns the current state.
  Future<LicenseState> load() => _compute();

  /// Saves [key] if it's valid for this computer.
  Future<ActivationResult> activate(String key) async {
    final cleaned = LicenseCodec.clean(key);
    final (result, _) = await check(cleaned);
    if (result != ActivationResult.activated) return result;
    await _compute(newKey: cleaned);
    return result;
  }

  /// Removes the saved licence (e.g. before moving it to another computer).
  Future<void> deactivate() => _compute(clearKey: true);

  Future<LicenseState> _compute({String? newKey, bool clearKey = false}) async {
    final now = clock().toUtc();
    DateTime? trialStart, seen;
    String? key;
    var tampered = false;
    for (final raw in await _readAll()) {
      try {
        final r = decodeRecord(raw);
        if (r == null) continue;
        final t = DateTime.tryParse('${r['t']}');
        final sn = DateTime.tryParse('${r['s']}');
        if (t != null && (trialStart == null || t.isBefore(trialStart))) trialStart = t;
        if (sn != null && (seen == null || sn.isAfter(seen))) seen = sn;
        key ??= r['k'] as String?;
      } catch (_) {
        tampered = true;
      }
    }
    if (tampered && trialStart == null) {
      trialStart = now.subtract(const Duration(days: trialDays + 1));
    }
    trialStart ??= now;
    // A clock set back can't go below a date already seen.
    final effective = (seen != null && seen.isAfter(now)) ? seen : now;
    final clockWrong = seen != null && now.isBefore(seen.subtract(const Duration(days: 1)));
    if (clearKey) key = null;
    if (newKey != null) key = newKey;

    await _writeAll(encodeRecord(trialStart: trialStart, seen: effective, key: key));

    final device = await deviceCode();
    if (key != null) {
      final (result, p) = await check(key, at: effective);
      if (p != null && result != ActivationResult.invalid && result != ActivationResult.otherDevice) {
        final days = p.expires == null ? null : _daysUntil(effective, p.expires!);
        return LicenseState(
          kind: result == ActivationResult.activated ? LicenseKind.licensed : LicenseKind.licenseExpired,
          deviceCode: device,
          trialStart: trialStart,
          daysLeft: days,
          license: p,
          clockLooksWrong: clockWrong,
        );
      }
    }
    final trialEnd = trialStart.add(const Duration(days: trialDays));
    final left = _daysUntil(effective, trialEnd);
    return LicenseState(
      kind: left > 0 ? LicenseKind.trial : LicenseKind.trialEnded,
      deviceCode: device,
      trialStart: trialStart,
      daysLeft: left < 0 ? 0 : left,
      clockLooksWrong: clockWrong,
    );
  }

  static int _daysUntil(DateTime from, DateTime to) {
    final ms = to.difference(from).inMilliseconds;
    if (ms <= 0) return 0;
    return (ms / Duration.millisecondsPerDay).ceil();
  }
}
