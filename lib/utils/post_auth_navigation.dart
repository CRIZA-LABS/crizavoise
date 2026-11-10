import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crizavoise/common/common.dart';
import 'package:crizavoise/database/recovery_code_service.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/screens/auth/recovery_code_screen.dart';
import 'package:crizavoise/screens/dashboard_screen.dart';
import 'package:crizavoise/screens/onboarding/onboarding_screen.dart';

/// Routes to the onboarding wizard on a user's first login, else straight
/// to the dashboard. Shared by every post-auth navigation call site so the
/// "show once" gate lives in exactly one place.
///
/// Admins without a recovery code (accounts made before codes existed) are
/// offered one first; "Later" asks again after two weeks.
Future<void> navigateAfterAuth(
    BuildContext context, WidgetRef ref, User user) async {
  final completed = await ref
      .read(settingsRepositoryProvider)
      .getSetting(SettingKey.onboardingCompleted);
  if (!context.mounted) return;
  Widget home() =>
      completed == 'true' ? DashboardScreen(user) : OnboardingScreen(user);

  if (user.isAdmin() && await _shouldOfferRecoveryCode(user)) {
    final code = await RecoveryCodeService.createFor(user.id);
    final company = (await ref.read(companyInfoRepositoryProvider).getCompanyInfo())?.name;
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => RecoveryCodeScreen(
          code: code,
          username: user.username,
          companyName: (company?.isNotEmpty ?? false) ? company : null,
          onDone: () => Navigator.pushReplacement(
              ctx, MaterialPageRoute(builder: (_) => home())),
          onLater: () async {
            // Not kept: drop it so the person isn't left with a code they
            // never saw again.
            await RecoveryCodeService.clear(user.id);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_laterKey(user), DateTime.now().toIso8601String());
            if (!ctx.mounted) return;
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => home()));
          },
        ),
      ),
    );
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => home()),
  );
}

String _laterKey(User user) => 'cv_recovery_offered_${user.id}';

Future<bool> _shouldOfferRecoveryCode(User user) async {
  try {
    if (await RecoveryCodeService.hasCode(user.id)) return false;
    final prefs = await SharedPreferences.getInstance();
    final last = DateTime.tryParse(prefs.getString(_laterKey(user)) ?? '');
    return last == null || DateTime.now().difference(last).inDays >= 14;
  } catch (_) {
    return false;
  }
}
