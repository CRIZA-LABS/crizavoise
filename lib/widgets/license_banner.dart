import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/licensing/license_service.dart';
import 'package:crizavoise/providers/license_provider.dart';
import 'package:crizavoise/screens/settings/license_screen.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Slim strip above every main screen: shown in the last 7 days of the trial
/// or a dated licence, and while the app is in view-only mode. It can be
/// hidden for the session (not when view-only).
class LicenseStrip extends ConsumerStatefulWidget {
  const LicenseStrip({super.key});

  @override
  ConsumerState<LicenseStrip> createState() => _LicenseStripState();
}

class _LicenseStripState extends ConsumerState<LicenseStrip> {
  static bool _hiddenThisSession = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(licenseProvider).valueOrNull;
    if (s == null) return const SizedBox.shrink();
    final blocked = !s.canCreateDocuments;
    if (!blocked && (!s.showReminder || _hiddenThisSession)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final color = blocked ? scheme.error : CrizaTokens.of(context).warning;
    final text = switch (s.kind) {
      LicenseKind.trial => l10n.licenseBannerTrial(s.daysLeft ?? 0),
      LicenseKind.licensed => l10n.licenseBannerExpiring(s.daysLeft ?? 0),
      _ => l10n.licenseBannerEnded,
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
        color: color.withValues(alpha: 0.10),
        child: Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.4)))),
          padding: const EdgeInsets.symmetric(horizontal: CvSpace.md, vertical: CvSpace.xs),
          child: Row(
            children: [
              Icon(blocked ? Icons.lock_clock_outlined : Icons.hourglass_bottom_rounded,
                  size: 20, color: color),
              const SizedBox(width: CvSpace.sm),
              Expanded(child: Text(text, style: TextStyle(color: scheme.onSurface))),
              TextButton(
                onPressed: () => LicenseScreen.open(context),
                child: Text(blocked ? l10n.licenseActivate : l10n.licenseBuy),
              ),
              if (!blocked)
                IconButton(
                  tooltip: l10n.actionDismiss,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => setState(() => _hiddenThisSession = true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Call before saving a new document. Returns true when allowed; otherwise
/// explains view-only mode and offers to activate.
Future<bool> ensureCanCreateDocuments(BuildContext context, WidgetRef ref) async {
  LicenseState s;
  try {
    s = await ref.read(licenseProvider.future);
  } catch (_) {
    return true; // never block work because the check itself failed
  }
  if (s.canCreateDocuments) return true;
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context)!;
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.lock_clock_outlined),
      title: Text(l10n.licenseGateTitle),
      content: Text(l10n.licenseGateBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionClose)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.licenseGateAction)),
      ],
    ),
  );
  if (go == true && context.mounted) {
    await LicenseScreen.open(context);
    final after = await ref.read(licenseProvider.future);
    return after.canCreateDocuments;
  }
  return false;
}
