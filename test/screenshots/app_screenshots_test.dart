// Renders real CrizaVoise screens (temp SQLite DB, real fonts and icons) in
// light and dark and writes PNGs to build/screenshots/. Used for design
// review because Windows Smart App Control can block the unsigned app.
//
// Run:  SCREENSHOTS=1 flutter test test/screenshots/app_screenshots_test.dart
// (skipped in normal `flutter test` runs).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/providers/sqlite_repository_overrides.dart';
import 'package:crizavoise/providers/theme_provider.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_company_info_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_installation_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_invoice_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_payment_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_settings_repository.dart';
import 'package:crizavoise/screens/auth/login_screen.dart';
import 'package:crizavoise/screens/dashboard_screen.dart';
import 'package:crizavoise/services/backend_services.dart';
import 'package:crizavoise/theme/app_theme.dart';
import 'package:crizavoise/utils/session_manager.dart';

import 'seed.dart';

final _enabled = Platform.environment.containsKey('SCREENSHOTS');
final _out = Directory('build/screenshots');

// Render as the real target platform (Windows desktop density/scrollbars).
final _windows = TargetPlatformVariant.only(TargetPlatform.windows);

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter';
  await family('Inter', ['assets/fonts/Inter-Variable.ttf']);
  await family('BricolageGrotesque', ['assets/fonts/BricolageGrotesque-Variable.ttf']);
  await family('NotoSansDevanagari', ['assets/fonts/NotoSansDevanagari-Regular.ttf']);
  await family('MaterialIcons',
      ['$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf']);
  // Roboto is the fallback for widgets that don't set a family.
  await family('Roboto', ['$flutterRoot/bin/cache/artifacts/material_fonts/roboto-regular.ttf']);
}

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    _out.createSync(recursive: true);
    File('${_out.path}/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// Known debug-only framework assertion on desktop (ListTile ink inside a
/// coloured box) — rendering is unaffected; tracked in CLAUDE.md.
void _ignoreKnownAsserts() {
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    if (d.exceptionAsString().contains('ListTile background color')) return;
    prev?.call(d);
  };
  addTearDown(() => FlutterError.onError = prev);
}

Future<void> _pumpApp(WidgetTester tester, Widget home, ThemeMode mode,
    {Size size = const Size(1366, 820)}) async {
  _ignoreKnownAsserts();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...sqliteRepositoryOverrides,
      themeModeProvider.overrideWith((ref) => mode),
    ],
    child: RepaintBoundary(
      key: const Key('shot'),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  ));
  // Let async loads (DB queries) complete, then settle animations.
  for (var i = 0; i < 24; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 150)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUpAll(() async {
    if (!_enabled) return;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tmp = Directory.systemTemp.createTempSync('cv_shots');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => tmp.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/shared_preferences'),
            (call) async => call.method == 'getAll' ? <String, Object>{} : true);
    BackendServices.configure(
      settings: SqliteSettingsRepository(),
      companyInfo: SqliteCompanyInfoRepository(),
      invoices: SqliteInvoiceRepository(),
      payments: SqlitePaymentRepository(),
      installation: SqliteInstallationRepository(),
    );
    await _loadFonts();
    await DatabaseHelper().switchToFile('shots.db');
    await seedDemoData();
  });

  tearDownAll(() async {
    if (!_enabled) return;
    await DatabaseHelper().close();
    try { tmp.deleteSync(recursive: true); } catch (_) {}
  });

  final admin = User(id: 'admin', username: 'admin', password: '', userType: 'admin');

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final m = mode == ThemeMode.light ? 'light' : 'dark';

    testWidgets('login · $m', (tester) async {
      await _pumpApp(tester, const LoginScreen(), mode);
      await _shot(tester, 'login_$m');
    }, skip: !_enabled, variant: _windows);

    testWidgets('all screens · $m', (tester) async {
      await _pumpApp(tester, DashboardScreen(admin), mode);
      const pages = {
        'New Invoice': 'new_invoice',
        'Invoices': 'invoices',
        'Customers': 'customers',
        'Products': 'products',
        'Reports': 'reports',
        'Settings': 'settings',
      };
      for (final e in pages.entries) {
        if (find.text(e.key).evaluate().isEmpty) {
          await tester.tap(find.text('More').first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 400));
        }
        final nav = find.text(e.key).first;
        await tester.tap(nav, warnIfMissed: false);
        for (var i = 0; i < 12; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
          await tester.pump(const Duration(milliseconds: 250));
        }
        await _shot(tester, '${e.value}_$m');
      }
      SessionManager.dispose();
      await tester.pumpWidget(const SizedBox());
    }, skip: !_enabled, variant: _windows);

    testWidgets('dashboard · $m', (tester) async {
      await _pumpApp(tester, DashboardScreen(admin), mode);
      await _shot(tester, 'dashboard_$m');
      SessionManager.dispose();
      await tester.pumpWidget(const SizedBox());
    }, skip: !_enabled, variant: _windows);
  }
}
