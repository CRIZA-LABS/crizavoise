// Pure Dart (no Flutter): shared by the app (verify) and by
// tool/license/generate.dart (sign), so both always agree on the format.
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Paid plans after the 30-day trial.
enum LicensePlan {
  sixMonths('6m', 183),
  oneYear('1y', 365),
  lifetime('life', null);

  const LicensePlan(this.code, this.days);
  final String code;

  /// Validity from the issue date; null = never expires.
  final int? days;

  static LicensePlan? fromCode(String? c) {
    for (final p in values) {
      if (p.code == c) return p;
    }
    return null;
  }
}

/// What a licence key says. Signed as a whole, so no field can be changed.
class LicensePayload {
  final String id; // licence number, e.g. "CV-2026-0001"
  final String name; // licensee (business) name
  final String email;
  final LicensePlan plan;
  final DateTime issued; // UTC date
  final DateTime? expires; // UTC date, null for lifetime
  final String device; // device code it's locked to, or '*' for any device

  const LicensePayload({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.issued,
    required this.expires,
    required this.device,
  });

  static String _d(DateTime d) => d.toUtc().toIso8601String().substring(0, 10);

  Map<String, dynamic> toJson() => {
        'v': 1,
        'id': id,
        'n': name,
        'e': email,
        'p': plan.code,
        'i': _d(issued),
        'x': expires == null ? null : _d(expires!),
        'd': device,
      };

  static LicensePayload? fromJson(Map<String, dynamic> j) {
    final plan = LicensePlan.fromCode(j['p'] as String?);
    if (j['v'] != 1 || plan == null) return null;
    final issued = DateTime.tryParse('${j['i']}T00:00:00Z');
    if (issued == null) return null;
    final x = j['x'] as String?;
    return LicensePayload(
      id: j['id'] as String? ?? '',
      name: j['n'] as String? ?? '',
      email: j['e'] as String? ?? '',
      plan: plan,
      issued: issued,
      expires: x == null ? null : DateTime.tryParse('${x}T23:59:59Z'),
      device: j['d'] as String? ?? '',
    );
  }

  bool isExpiredAt(DateTime now) => expires != null && now.toUtc().isAfter(expires!);
}

/// Licence key text: `CV1.<payload>.<signature>` (base64url, no padding).
class LicenseCodec {
  static const _prefix = 'CV1';
  static const _context = 'CVLIC1|'; // domain separation from other signatures

  static String _b64(List<int> b) => base64Url.encode(b).replaceAll('=', '');
  static List<int> _unb64(String s) => base64Url.decode(base64Url.normalize(s));

  /// Expiry date for [plan] issued on [issued] (UTC date).
  static DateTime? expiryFor(LicensePlan plan, DateTime issued) {
    final days = plan.days;
    if (days == null) return null;
    final d = DateTime.utc(issued.year, issued.month, issued.day);
    return d.add(Duration(days: days));
  }

  /// Signs [payload] with the Criza Labs private key (generator side only).
  static Future<String> sign(LicensePayload payload, SimpleKeyPair keyPair) async {
    final body = _b64(utf8.encode(jsonEncode(payload.toJson())));
    final sig = await Ed25519().sign(utf8.encode('$_context$body'), keyPair: keyPair);
    return '$_prefix.$body.${_b64(sig.bytes)}';
  }

  /// Removes spaces/line breaks people add when copying keys from chats.
  static String clean(String key) => key.replaceAll(RegExp(r'\s+'), '');

  /// Verifies [key] against [publicKey]. Returns the payload only if the
  /// signature is valid; null for anything malformed or tampered.
  static Future<LicensePayload?> verify(String key, List<int> publicKey) async {
    final parts = clean(key).split('.');
    if (parts.length != 3 || parts[0] != _prefix) return null;
    try {
      final ok = await Ed25519().verify(
        utf8.encode('$_context${parts[1]}'),
        signature: Signature(_unb64(parts[2]),
            publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519)),
      );
      if (!ok) return null;
      final json = jsonDecode(utf8.decode(_unb64(parts[1])));
      return json is Map<String, dynamic> ? LicensePayload.fromJson(json) : null;
    } catch (_) {
      return null;
    }
  }
}

/// Device code shown to the customer: a short, stable fingerprint of the
/// computer (derived from the OS machine ID), e.g. "7KQ2-M9XD-4TPA-0WRC".
class DeviceCode {
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'; // Crockford base32

  static Future<String> fromMachineId(String machineId) async {
    final hash = await Sha256().hash(utf8.encode('crizavoise-device:${machineId.trim().toLowerCase()}'));
    final bytes = hash.bytes.sublist(0, 10); // 80 bits -> 16 chars
    var bits = 0, value = 0;
    final out = StringBuffer();
    for (final b in bytes) {
      value = (value << 8) | b;
      bits += 8;
      while (bits >= 5) {
        out.write(_alphabet[(value >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    final s = out.toString();
    return [for (var i = 0; i < 16; i += 4) s.substring(i, i + 4)].join('-');
  }

  /// Normalises what a person typed (case, spaces, O/I/L look-alikes).
  static String normalize(String code) => code
      .toUpperCase()
      .replaceAll(RegExp(r'[\s-]'), '')
      .replaceAll('O', '0')
      .replaceAll(RegExp('[IL]'), '1');
}
