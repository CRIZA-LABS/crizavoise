import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/licensing/license_service.dart';

/// Current trial / licence state. Loaded once at start-up and after every
/// activation; cheap (no network, a few small reads).
class LicenseNotifier extends AsyncNotifier<LicenseState> {
  @override
  Future<LicenseState> build() async {
    // Free edition: always allowed, no reminders, no device code or storage.
    if (!AppConfig.licensingEnabled) {
      return LicenseState(
        kind: LicenseKind.licensed,
        deviceCode: '',
        trialStart: DateTime.now(),
        daysLeft: null,
      );
    }
    final s = await LicenseService.instance.load();
    // Online licence check (dormant until AppConfig.licenseCheckUrl is set).
    // Runs in the background and never delays start-up.
    LicenseService.instance.checkOnline().then((changed) {
      if (changed) refresh();
    }).catchError((_) {});
    return s;
  }

  Future<ActivationResult> activate(String key) async {
    final result = await LicenseService.instance.activate(key);
    if (result == ActivationResult.activated) {
      state = AsyncData(await LicenseService.instance.load());
    }
    return result;
  }

  Future<void> deactivate() async {
    await LicenseService.instance.deactivate();
    state = AsyncData(await LicenseService.instance.load());
  }

  Future<void> refresh() async => state = AsyncData(await LicenseService.instance.load());
}

final licenseProvider =
    AsyncNotifierProvider<LicenseNotifier, LicenseState>(LicenseNotifier.new);
