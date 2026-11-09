import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Settings → About → Open-source licenses.
///
/// Shows THIRD_PARTY_NOTICES.md, which is bundled as an asset, so the notices
/// always match what ships. Package licenses collected by Flutter are one tap
/// away via [showLicensePage].
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutOpenSourceLicensesTitle)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(AppConfig.thirdPartyNoticesAsset),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(CvSpace.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, color: scheme.error),
                    const SizedBox(width: CvSpace.sm),
                    Flexible(child: Text(l10n.aboutLicensesLoadError)),
                  ],
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.all(CvSpace.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(CvSpace.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(CvRadius.md),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: SelectableText(
                      snap.data!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontFamilyFallback: const ['Consolas', 'Menlo', 'DejaVu Sans Mono'],
                        fontSize: 12.5,
                        height: 1.5,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: CvSpace.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(l10n.aboutPackageLicensesButton),
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: AppConfig.name,
                        applicationVersion: AppConfig.version,
                        applicationLegalese: AppConfig.makerCredit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
