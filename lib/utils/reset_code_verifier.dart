import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:crizavoise/licensing/license_keys.dart';

/// Verifies developer-issued password reset codes.
///
/// Challenge-response: the locked-out user shares their installationId
/// out-of-band; Criza Labs signs `installationId:utcDayBucket` with a
/// private Ed25519 key (never shipped with the app) and returns the
/// base64 signature as the "response code". This file only holds the
/// public key, so it can't be used to forge codes even if decompiled.
class ResetCodeVerifier {
  ResetCodeVerifier._();

  /// Criza Labs reset-code public key (verify only). The private key is in
  /// .secrets/ and codes are made with tool/license/generate.dart reset.
  static const List<int> _publicKeyBytes = CrizaKeys.resetPublicKey;

  /// Days since Unix epoch, computed from UTC. Must match the signer
  /// script's formula exactly.
  static int utcDayBucket([DateTime? now]) {
    final utcNow = (now ?? DateTime.now()).toUtc();
    return utcNow.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  /// Verifies [responseCode] (base64 Ed25519 signature) against
  /// [installationId], trying today/yesterday/day-before UTC day buckets
  /// for ~3 day validity. Returns false on any mismatch or malformed input.
  static Future<bool> verifyResetCode({
    required String installationId,
    required String responseCode,
  }) async {
    late final List<int> signatureBytes;
    try {
      signatureBytes = base64.decode(responseCode.trim());
    } catch (_) {
      return false;
    }

    final algorithm = Ed25519();
    final publicKey = SimplePublicKey(_publicKeyBytes, type: KeyPairType.ed25519);
    final today = utcDayBucket();

    for (final offset in [0, -1, -2]) {
      final bucket = today + offset;
      final payload = utf8.encode('$installationId:$bucket');
      final signature = Signature(signatureBytes, publicKey: publicKey);
      try {
        final valid = await algorithm.verify(payload, signature: signature);
        if (valid) return true;
      } catch (_) {
        // Malformed signature bytes - treat as invalid, keep trying offsets.
      }
    }
    return false;
  }
}
