import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/screens/legal/legal_document_screen.dart';
import 'package:crizavoise/services/terms_service.dart';
import 'package:crizavoise/theme/brand_assets.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Shown before login until this installation has accepted the current
/// Terms of Use and Privacy Policy (and again whenever they change).
/// Plain-language key points first; the full documents are one tap away.
class TermsAcceptanceScreen extends StatefulWidget {
  final VoidCallback onAccepted;
  const TermsAcceptanceScreen({super.key, required this.onAccepted});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _agreed = false;
  bool _saving = false;

  Future<void> _accept() async {
    setState(() => _saving = true);
    await TermsService.accept();
    if (mounted) widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final points = <(IconData, String)>[
      (Icons.storefront_outlined, l10n.termsPointYourBusiness),
      (Icons.fact_check_outlined, l10n.termsPointCheckDocuments),
      (Icons.backup_outlined, l10n.termsPointBackups),
      (Icons.gpp_maybe_outlined, l10n.termsPointNoWarranty),
      (Icons.payments_outlined, l10n.termsPointPricing),
      (Icons.lock_outline, l10n.termsPointPrivacy),
      (Icons.forum_outlined, l10n.termsPointTalkFirst),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CvSpace.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(CvSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SvgPicture.asset(BrandAssets.markFor(theme.brightness),
                            width: 48, height: 48, semanticsLabel: AppConfig.name),
                        const SizedBox(width: CvSpace.md),
                        Expanded(child: Text(l10n.termsTitle, style: theme.textTheme.headlineSmall)),
                      ]),
                      const SizedBox(height: CvSpace.sm),
                      Text(l10n.termsIntro, style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: CvSpace.lg),
                      for (final (icon, text) in points)
                        Padding(
                          padding: const EdgeInsets.only(bottom: CvSpace.sm + 4),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(CvRadius.sm),
                              ),
                              child: Icon(icon, size: 20, color: scheme.onSurface),
                            ),
                            const SizedBox(width: CvSpace.md),
                            Expanded(child: Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text(text),
                            )),
                          ]),
                        ),
                      const SizedBox(height: CvSpace.sm),
                      Wrap(spacing: CvSpace.sm, children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.description_outlined, size: 18),
                          label: Text(l10n.termsReadTerms),
                          onPressed: () => LegalDocumentScreen.open(context,
                              title: l10n.termsOfUseTitle, asset: AppConfig.termsAsset),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                          label: Text(l10n.termsReadPrivacy),
                          onPressed: () => LegalDocumentScreen.open(context,
                              title: l10n.privacyPolicyTitle, asset: AppConfig.privacyAsset),
                        ),
                      ]),
                      const SizedBox(height: CvSpace.md),
                      CheckboxListTile(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.termsAgreeCheckbox,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: CvSpace.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _agreed && !_saving ? _accept : null,
                          child: Text(l10n.termsContinueButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
