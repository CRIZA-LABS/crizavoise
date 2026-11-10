import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/licensing/license_service.dart';

/// Current trial / licence state. Loaded once at start-up and after every
/// activation; cheap (no network, a few small reads).
class LicenseNotifier extends AsyncNotifier<LicenseState> {
  @override
  Future<LicenseState> build() => LicenseService.instance.load();

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
