import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/licensing/license_keys.dart';

/// Statuses that end a licence on this computer.
const blockingStatuses = {'revoked', 'moved', 'other-device'};

/// Verifies a signed status from the licence server:
/// `{body, sig}` with sig = Ed25519("CVSTAT1|" + body). Returns the decoded
/// status, or null when it's malformed, forged, or more than 2 days old
/// (so an old "active" answer can't be replayed forever).
Future<Map<String, dynamic>?> verifySignedStatus(Map<String, dynamic> json,
    {List<int> publicKey = CrizaKeys.licensePublicKey, DateTime? now}) async {
  try {
    final body = json['body'] as String, sig = json['sig'] as String;
    List<int> d(String s) => base64Url.decode(base64Url.normalize(s));
    final ok = await Ed25519().verify(
      utf8.encode('CVSTAT1|$body'),
      signature: Signature(d(sig), publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519)),
    );
    if (!ok) return null;
    final status = jsonDecode(utf8.decode(d(body))) as Map<String, dynamic>;
    final ts = DateTime.tryParse('${status['ts']}');
    if (ts == null || (now ?? DateTime.now()).toUtc().difference(ts).abs() > const Duration(days: 2)) {
      return null;
    }
    return status;
  } catch (_) {
    return null;
  }
}

/// Default fetcher: null (no request at all) while [AppConfig.licenseCheckUrl]
/// is unset. Never throws; any network problem just means "no answer".
Future<Map<String, dynamic>?> fetchLicenceStatus(String id, String device) async {
  final url = AppConfig.licenseCheckUrl;
  if (url == null) return null;
  try {
    final uri = Uri.parse(url).replace(queryParameters: {'id': id, 'device': device});
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    return await verifySignedStatus(jsonDecode(res.body) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}
