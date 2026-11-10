import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/common/setting_key.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tmp = Directory.systemTemp.createTempSync('cv_rupee');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), (call) async => tmp.path);
    await DatabaseHelper().switchToFile('rupee.db');
  });
  tearDownAll(() async {
    await DatabaseHelper().close();
    tmp.deleteSync(recursive: true);
  });

  test('INR shows Rs. by default and ₹ when chosen; other currencies unaffected', () async {
    await SettingsService.setSetting(SettingKey.currency, 'INR');
    expect((await SettingsService.getCurrency()).symbol, 'Rs.');
    await SettingsService.setSetting(SettingKey.rupeeSymbol, 'symbol');
    expect((await SettingsService.getCurrency()).symbol, '₹');
    await SettingsService.setSetting(SettingKey.currency, 'USD');
    expect((await SettingsService.getCurrency()).symbol, isNot('₹'));
  });
}
