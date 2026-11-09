import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FaqService {
  static const _bundledAssetPath = 'assets/data/faq.json';

  /// Returns the FAQ data as a decoded map ({version, categories, items}).
  ///
  /// CrizaVoise ships its FAQ inside the app and makes no network call. Any
  /// FAQ cached in the database by an older build (SettingKey.faqCache) is
  /// ignored on purpose, so migrated users never see outdated answers.
  /// [force] is kept for API compatibility with the help screen's refresh.
  static Future<Map<String, dynamic>> load({bool force = false}) async {
    final bundled = await rootBundle.loadString(_bundledAssetPath);
    return jsonDecode(bundled) as Map<String, dynamic>;
  }
}
