import 'package:shared_preferences/shared_preferences.dart';

import 'package:crizavoise/common/app_config.dart';

/// Records that this installation accepted the current Terms of Use and
/// Privacy Policy (AppConfig.termsVersion). Stored per installation in
/// SharedPreferences, so switching companies doesn't ask again; bumping the
/// version asks everyone again.
class TermsService {
  static const _versionKey = 'terms_accepted_version';
  static const _atKey = 'terms_accepted_at';

  static Future<bool> isAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_versionKey) == AppConfig.termsVersion;
  }

  static Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_versionKey, AppConfig.termsVersion);
    await prefs.setString(_atKey, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> acceptedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_atKey);
    return v == null ? null : DateTime.tryParse(v);
  }
}
