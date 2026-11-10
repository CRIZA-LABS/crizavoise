import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/common/setting_key.dart';
import 'package:crizavoise/database/company_registry_service.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/providers/locale_provider.dart';
import 'package:crizavoise/providers/purchase_bills_settings_provider.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/providers/sqlite_repository_overrides.dart';
import 'package:crizavoise/providers/theme_provider.dart';
import 'package:crizavoise/providers/motion_provider.dart';
import 'package:crizavoise/theme/app_theme.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/migration/legacy_data_migration.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_company_info_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_installation_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_invoice_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_payment_repository.dart';
import 'package:crizavoise/repositories/sqlite/sqlite_settings_repository.dart';
import 'package:crizavoise/screens/splash_screen.dart';
import 'package:crizavoise/services/backend_services.dart';
import 'package:crizavoise/utils/window_title.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // Set up error handlers BEFORE runApp
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('[PlatformDispatcher] Unhandled error: $error');
      debugPrint('Stack: $stack');
    }
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    final p = CvColors.of(PlatformDispatcher.instance.platformBrightness);
    return Material(
      child: Container(
        color: p.background,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: p.danger),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: p.text),
            ),
            const SizedBox(height: 8),
            Text(
              kDebugMode ? details.exceptionAsString() : 'Please restart the app.',
              style: TextStyle(fontSize: 14, color: p.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  if (!Platform.isAndroid) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();
  registerFallbackNumberSymbols();
  // Import data from the pre-rename install BEFORE anything opens the
  // database or SharedPreferences (both live in the app-support dir).
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await (await LegacyDataMigration.forCurrentPlatform()).runCopyPhase();
  }
  await CompanyRegistryService.ensureDefaultCompanyRegistered();
  DatabaseHelper().setActiveFileNameBeforeFirstOpen(
      await CompanyRegistryService.getActiveCompanyDbFileName());
  await CompanyRegistryService.nameActiveDbIfMissing();
  BackendServices.configure(
    settings: SqliteSettingsRepository(),
    companyInfo: SqliteCompanyInfoRepository(),
    invoices: SqliteInvoiceRepository(),
    payments: SqlitePaymentRepository(),
    installation: SqliteInstallationRepository()
  );

  // Read the saved theme BEFORE the first frame so the window never flashes
  // the wrong theme.
  final initialThemeMode = await _loadInitialThemeMode();
  final initialBrightness = switch (initialThemeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => PlatformDispatcher.instance.platformBrightness,
  };

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    final WindowOptions options = WindowOptions(
      title: AppConfig.name,
      minimumSize: const Size(600, 400),
      center: true,
      backgroundColor: CvColors.of(initialBrightness).background,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.center();
      await windowManager.show();
      await windowManager.focus();
    });

    await refreshWindowTitle();
  }

  runApp(ProviderScope(
    overrides: [
      ...sqliteRepositoryOverrides,
      themeModeProvider.overrideWith((ref) => initialThemeMode),
    ],
    child: const MyApp()
  ));
}

/// Saved theme preference; falls back to following the system if the
/// database can't be read yet (the splash screen reports DB errors).
Future<ThemeMode> _loadInitialThemeMode() async {
  try {
    return themeModeFromKey(await SqliteSettingsRepository().getThemeMode());
  } catch (_) {
    return ThemeMode.system;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadAppLocale();
    _loadPurchaseBillsAndSuppliersEnabled();
    _loadReduceMotion();
  }

  Future<void> _loadReduceMotion() async {
    final v = await ref.read(settingsRepositoryProvider).getSetting(SettingKey.reduceMotion);
    if (!mounted) return;
    ref.read(reduceMotionProvider.notifier).state = v == 'true';
  }


  Future<void> _loadAppLocale() async {
    final key = await ref.read(settingsRepositoryProvider).getAppLocale();
    if (!mounted) return;
    applyAppLocale(ref, localeFromKey(key));
  }

  Future<void> _loadPurchaseBillsAndSuppliersEnabled() async {
    final value = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.enablePurchaseBillsAndSuppliers);
    if (!mounted) return;
    ref.read(enablePurchaseBillsAndSuppliersProvider.notifier).state =
        value == 'true';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: AppConfig.name,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackLocalizationsDelegate<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
        FallbackLocalizationsDelegate<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
        FallbackLocalizationsDelegate<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
      ],
      // Reduce motion: the in-app setting OR the OS preference turns
      // animations down everywhere (widgets read MediaQuery.disableAnimations).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final reduce = ref.watch(reduceMotionProvider) || mq.disableAnimations;
        return MediaQuery(data: mq.copyWith(disableAnimations: reduce), child: child!);
      },
      home: const SplashScreen(),
    );
  }
}
