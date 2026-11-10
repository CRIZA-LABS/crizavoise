import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/screens/settings/licenses_screen.dart';
import 'package:crizavoise/theme/brand_assets.dart';
import 'package:crizavoise/utils/contact_links.dart';
import 'package:crizavoise/common/constants.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/providers/app_config_provider.dart';
import 'package:crizavoise/services/update_service.dart';
import 'package:crizavoise/theme/swatch.dart';

class AppInfoScreen extends ConsumerStatefulWidget {
  final UpdateInfo? updateInfo;
  final bool isCheckingUpdate;
  final bool updateCheckFailed;
  final VoidCallback onCheckForUpdates;

  const AppInfoScreen({
    super.key,
    required this.updateInfo,
    required this.isCheckingUpdate,
    required this.updateCheckFailed,
    required this.onCheckForUpdates,
  });

  @override
  ConsumerState<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends ConsumerState<AppInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cfg = ref.watch(appEditionConfigProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.appInfoTitle),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero card ────────────────────────────────────────────
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          BrandAssets.markFor(Theme.of(context).brightness),
                          width: 56,
                          height: 56,
                          semanticsLabel: AppConfig.name,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                Theme.of(context).brightness == Brightness.dark
                                    ? BrandAssets.lockupDark
                                    : BrandAssets.lockupLight,
                                height: 40,
                                filterQuality: FilterQuality.medium,
                                semanticLabel: cfg.name,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cfg.description,
                                style: TextStyle(
                                  fontSize: AppFontSize.small,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            cfg.version,
                            style: TextStyle(
                              fontSize: AppFontSize.medium,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Two info cards ───────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _infoCard(l10n.appInfoAppDetailsTitle, [
                        _infoRow(Icons.apps_rounded, l10n.appInfoAppNameLabel,
                            cfg.name),
                        _infoRow(Icons.tag_rounded, l10n.appInfoVersionLabel,
                            cfg.version),
                        _infoRow(Icons.gavel_rounded, l10n.appInfoLicenseLabel,
                            cfg.license),
                      ]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _infoCard(l10n.appInfoDeveloperTitle, [
                        _infoRow(Icons.business_rounded,
                            l10n.appInfoDeveloperLabel, AppConfig.makerCredit),
                        _linkRow(Icons.language_rounded, AppConfig.madeBy,
                            AppConfig.websiteLabel, openCrizaWebsite),
                      ]),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Contact ──────────────────────────────────────────────
                _infoCard(l10n.aboutContactTitle, [
                  _linkRow(Icons.support_agent_rounded,
                      l10n.aboutContactSupportLabel, AppConfig.supportEmail,
                      () => _contact(ContactChannel.support)),
                  _linkRow(Icons.info_outline_rounded,
                      l10n.aboutContactInfoLabel, AppConfig.infoEmail,
                      () => _contact(ContactChannel.info)),
                  _linkRow(Icons.handshake_outlined,
                      l10n.aboutContactBusinessLabel, AppConfig.businessEmail,
                      () => _contact(ContactChannel.business)),
                ]),

                const SizedBox(height: 20),

                // ── Update card ──────────────────────────────────────────
                if (cfg.enableUpdateCheck) _buildUpdateCard(),

                const SizedBox(height: 32),

                // ── Open-source licenses (small, out of the main UI) ─────
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: Text(l10n.aboutOpenSourceLicensesTitle),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LicensesScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Footer ───────────────────────────────────────────────
                Text(
                  l10n.aboutRightsReserved(DateTime.now().year, AppConfig.maker),
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard() {
    final primaryColor = Theme.of(context).primaryColor;
    final cfg = ref.watch(appEditionConfigProvider);
    final l10n = AppLocalizations.of(context)!;
    final info = widget.updateInfo;
    final hasUpdate = info != null && info.hasUpdate;
    final isUpToDate = info != null && !info.hasUpdate;

    Widget statusBadge;
    if (widget.isCheckingUpdate) {
      statusBadge = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
          ),
          const SizedBox(width: 8),
          Text(l10n.appInfoCheckingLabel,
              style:
                  TextStyle(fontSize: AppFontSize.xsmall, color: primaryColor)),
        ],
      );
    } else if (hasUpdate) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CvSwatch.warningTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CvSwatch.warningSoft),
        ),
        child: Text(
          l10n.appInfoUpdateAvailableLabel,
          style: TextStyle(
              fontSize: AppFontSize.xsmall,
              color: CvSwatch.warning,
              fontWeight: FontWeight.w600),
        ),
      );
    } else if (isUpToDate) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CvSwatch.successTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CvSwatch.successSoft),
        ),
        child: Text(
          l10n.appInfoUpToDateLabel,
          style: TextStyle(
              fontSize: AppFontSize.xsmall,
              color: CvSwatch.success,
              fontWeight: FontWeight.w600),
        ),
      );
    } else if (widget.updateCheckFailed) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CvSwatch.dangerTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CvSwatch.dangerSoft),
        ),
        child: Text(
          l10n.appInfoCheckFailedLabel,
          style: TextStyle(
              fontSize: AppFontSize.xsmall,
              color: CvSwatch.danger,
              fontWeight: FontWeight.w600),
        ),
      );
    } else {
      statusBadge = const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.appInfoUpdatesTitle,
                  style: TextStyle(
                    fontSize: AppFontSize.xsmall,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                statusBadge,
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: CvSwatch.neutralTint),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.tag_rounded,
                          size: 18,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appInfoCurrentVersionLabel,
                              style: TextStyle(
                                  fontSize: AppFontSize.xsmall,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 3),
                          Text(cfg.version,
                              style: const TextStyle(
                                  fontSize: AppFontSize.medium,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      if (info != null) ...[
                        const SizedBox(width: 32),
                        Icon(Icons.new_releases_outlined,
                            size: 18,
                            color: hasUpdate
                                ? CvSwatch.warning
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.appInfoLatestVersionLabel,
                                style: TextStyle(
                                    fontSize: AppFontSize.xsmall,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 3),
                            Text(
                              info.latestVersion,
                              style: TextStyle(
                                fontSize: AppFontSize.medium,
                                fontWeight: FontWeight.w600,
                                color: hasUpdate
                                    ? CvSwatch.warning
                                    : CvSwatch.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.isCheckingUpdate
                          ? null
                          : widget.onCheckForUpdates,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(l10n.appInfoCheckNowButton),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(
                            color: primaryColor.withValues(alpha: 0.4)),
                      ),
                    ),
                    if (hasUpdate) ...[
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: primaryColor),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(l10n.createInvoiceDownloadLabel),
                        onPressed: () => launchUrl(
                          Uri.parse(UpdateConfig.downloadUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSize.xsmall,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            ...rows
                .expand((row) => [
                      row,
                      Divider(
                          height: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest),
                    ])
                .toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }

  Future<void> _contact(ContactChannel channel) async {
    final opened = await openContact(channel);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!
              .contactMailUnavailableMessage(channel.email))));
    }
  }

  /// A row that opens a link; keyboard-focusable with a 48px target.
  Widget _linkRow(
      IconData icon, String label, String value, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$label, $value',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 14),
                SizedBox(
                  width: 90,
                  child: Text(label,
                      style: TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface)),
                ),
                Expanded(
                  child: Text(value,
                      style: TextStyle(
                          fontSize: AppFontSize.small,
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: scheme.primary)),
                ),
                Icon(Icons.open_in_new_rounded,
                    size: 16, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppFontSize.xsmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
