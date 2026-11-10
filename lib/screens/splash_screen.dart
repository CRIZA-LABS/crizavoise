import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/migration/legacy_data_migration.dart';
import 'package:crizavoise/theme/brand_assets.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/screens/auth/login_screen.dart';
import 'package:crizavoise/screens/legal/terms_acceptance_screen.dart';
import 'package:crizavoise/services/terms_service.dart';
import 'package:crizavoise/common/constants.dart';
import 'package:crizavoise/utils/app_logger.dart';

const _tag = 'SplashScreen';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await DatabaseHelper().database;
    } catch (e, stack) {
      AppLogger.e(_tag, 'Database initialization failed', e, stack);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.splashInitErrorTitle),
          content: Text(l10n.splashInitErrorMessage('$e')),
          actions: [
            ElevatedButton(
              onPressed: () => _initializeApp(),
              child: Text(l10n.actionRetry),
            ),
          ],
        ),
      );
      return;
    }

    AppLogger.d(_tag, 'DB path: ${DatabaseHelper.path}');

    // The database opened fine on this launch, so data imported from the
    // pre-rename install is verified: the old folder can go.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await (await LegacyDataMigration.forCurrentPlatform())
          .finalizeAfterSuccessfulOpen();
    }

    if (!mounted) return;
    // Terms of Use / Privacy Policy must be accepted (again when they change)
    // before anyone can log in.
    final accepted = await TermsService.isAccepted();
    if (!mounted) return;
    void toLogin(BuildContext ctx) => Navigator.pushReplacement(
        ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (accepted) {
      toLogin(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => TermsAcceptanceScreen(onAccepted: () => toLogin(ctx)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: reduceMotion ? CvMotion.fast : CvMotion.slow,
          curve: CvMotion.standard,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.scale(
                scale: reduceMotion ? 1 : 0.94 + 0.06 * t, child: child),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(BrandAssets.markFor(Theme.of(context).brightness),
                  width: 96, height: 96, semanticsLabel: AppConfig.name),
              const SizedBox(height: CvSpace.lg),
              Image.asset(
                isDark ? BrandAssets.lockupDark : BrandAssets.lockupLight,
                height: 48,
                filterQuality: FilterQuality.medium,
                semanticLabel: AppConfig.name,
              ),
              const SizedBox(height: CvSpace.xl),
              Text(AppLocalizations.of(context)!.splashInitializingMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              AppSpacing.hLarge,
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
