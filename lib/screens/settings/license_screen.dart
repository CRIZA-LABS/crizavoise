import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/licensing/license_codec.dart';
import 'package:crizavoise/licensing/license_service.dart';
import 'package:crizavoise/providers/license_provider.dart';
import 'package:crizavoise/screens/auth/auth_layout.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/utils/contact_links.dart';

/// Settings → Licence: trial / licence status, this computer's device code,
/// buying or renewing, and entering a licence key. Works fully offline.
class LicenseScreen extends ConsumerStatefulWidget {
  const LicenseScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const LicenseScreen()));

  @override
  ConsumerState<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends ConsumerState<LicenseScreen> {
  final _key = TextEditingController();
  String? _message;
  bool _messageIsError = false;
  bool _busy = false;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  String _planName(AppLocalizations l10n, LicensePlan p) => switch (p) {
        LicensePlan.sixMonths => l10n.licensePlanSixMonths,
        LicensePlan.oneYear => l10n.licensePlanOneYear,
        LicensePlan.lifetime => l10n.licensePlanLifetime,
      };

  Future<void> _activate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_key.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final r = await ref.read(licenseProvider.notifier).activate(_key.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _messageIsError = r != ActivationResult.activated;
      _message = switch (r) {
        ActivationResult.activated => l10n.licenseActivated,
        ActivationResult.invalid => l10n.licenseErrorInvalid,
        ActivationResult.otherDevice => l10n.licenseErrorOtherDevice,
        ActivationResult.expired => l10n.licenseErrorExpired,
      };
      if (r == ActivationResult.activated) _key.clear();
    });
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.licenseRemove),
        content: Text(l10n.licenseRemoveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.licenseRemove)),
        ],
      ),
    );
    if (ok == true) await ref.read(licenseProvider.notifier).deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(licenseProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.licenseTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authSomethingWentWrong)),
        data: (s) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(CvSpace.lg),
              children: [
                _statusCard(context, l10n, s),
                if (s.clockLooksWrong) ...[
                  const SizedBox(height: CvSpace.md),
                  AuthMessage(l10n.licenseClockWrong),
                ],
                const SizedBox(height: CvSpace.lg),
                _section(context, l10n.licenseDeviceCodeLabel, l10n.licenseDeviceCodeHelp,
                    _deviceCode(context, l10n, s.deviceCode)),
                const SizedBox(height: CvSpace.lg),
                _section(context, l10n.licensePlansTitle, l10n.licensePlansHelp,
                    _plans(context, l10n, s)),
                const SizedBox(height: CvSpace.lg),
                _section(context, l10n.licenseEnterKeyTitle, null, _enterKey(context, l10n)),
                if (s.license != null) ...[
                  const SizedBox(height: CvSpace.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.link_off_rounded),
                      label: Text(l10n.licenseRemove),
                      onPressed: _remove,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context, AppLocalizations l10n, LicenseState s) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = CrizaTokens.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale);
    final (IconData icon, Color color, String title, String body) = switch (s.kind) {
      LicenseKind.trial => (
          Icons.hourglass_top_rounded,
          s.showReminder ? tokens.warning : scheme.primary,
          l10n.licenseStatusTrial(s.daysLeft ?? 0),
          l10n.licenseTrialBody
        ),
      LicenseKind.trialEnded => (
          Icons.lock_clock_outlined,
          scheme.error,
          l10n.licenseStatusTrialEnded,
          l10n.licenseEndedBody
        ),
      LicenseKind.licensed => (
          Icons.verified_rounded,
          tokens.success,
          l10n.licenseStatusLicensed,
          s.daysLeft == null
              ? l10n.licenseNeverExpires
              : l10n.licenseValidUntil(date.format(s.license!.expires!.toLocal()))
        ),
      LicenseKind.licenseExpired => (
          Icons.event_busy_rounded,
          scheme.error,
          l10n.licenseStatusExpired,
          l10n.licenseEndedBody
        ),
      LicenseKind.licenseRevoked => (
          Icons.gpp_bad_outlined,
          scheme.error,
          l10n.licenseStatusRevoked,
          l10n.licenseRevokedBody
        ),
    };
    final lic = s.license;
    return Container(
      padding: const EdgeInsets.all(CvSpace.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CvRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: CvSpace.md),
              Expanded(
                child: Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
            ],
          ),
          const SizedBox(height: CvSpace.sm),
          Text(body, style: TextStyle(color: scheme.onSurfaceVariant)),
          if (s.kind == LicenseKind.trial) ...[
            const SizedBox(height: CvSpace.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(CvRadius.pill),
              child: LinearProgressIndicator(
                value: ((s.daysLeft ?? 0) / trialDays).clamp(0.0, 1.0),
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.18),
                semanticsLabel: title,
              ),
            ),
          ],
          if (lic != null) ...[
            const SizedBox(height: CvSpace.md),
            _kv(context, l10n.licenseLicensedTo, lic.name),
            _kv(context, l10n.licensePlanLabel, _planName(l10n, lic.plan)),
            _kv(context, l10n.licenseNumberLabel, lic.id),
            _kv(context, l10n.licenseIssuedLabel, date.format(lic.issued.toLocal())),
          ],
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 140,
                child: Text(k,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
            Expanded(child: SelectableText(v, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _section(BuildContext context, String title, String? help, Widget child) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(CvSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
                header: true,
                child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            if (help != null) ...[
              const SizedBox(height: 4),
              Text(help, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: CvSpace.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _deviceCode(BuildContext context, AppLocalizations l10n, String code) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: CvSpace.md, vertical: CvSpace.sm + 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(CvRadius.sm),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: SelectableText(
              code,
              semanticsLabel: code.split('').join(' '),
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: ['Consolas', 'Menlo'],
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5),
            ),
          ),
        ),
        const SizedBox(width: CvSpace.sm),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: Text(l10n.actionCopy),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l10n.licenseDeviceCodeCopied)));
          },
        ),
      ],
    );
  }

  Widget _plans(BuildContext context, AppLocalizations l10n, LicenseState s) {
    final scheme = Theme.of(context).colorScheme;
    Widget plan(IconData icon, String name, String desc) => Container(
          width: 200,
          padding: const EdgeInsets.all(CvSpace.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CvRadius.md),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: CvSpace.sm),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CvSpace.sm,
          runSpacing: CvSpace.sm,
          children: [
            plan(Icons.calendar_view_month_rounded, l10n.licensePlanSixMonths,
                l10n.licensePlanSixMonthsHelp),
            plan(Icons.event_repeat_rounded, l10n.licensePlanOneYear, l10n.licensePlanOneYearHelp),
            plan(Icons.all_inclusive_rounded, l10n.licensePlanLifetime,
                l10n.licensePlanLifetimeHelp),
          ],
        ),
        const SizedBox(height: CvSpace.md),
        FilledButton.icon(
          icon: const Icon(Icons.mail_outline_rounded),
          label: Text(l10n.licenseBuy),
          onPressed: () async {
            final ok = await openContact(ContactChannel.business,
                topic: 'Licence – device ${s.deviceCode}');
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.licenseNoMailApp(ContactChannel.business.email))));
            }
          },
        ),
      ],
    );
  }

  Widget _enterKey(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_message != null) AuthMessage(_message!, isError: _messageIsError),
        TextField(
          controller: _key,
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'monospace', fontFamilyFallback: ['Consolas'], fontSize: 13),
          decoration: InputDecoration(
            labelText: l10n.licenseEnterKeyLabel,
            hintText: l10n.licenseEnterKeyHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: CvSpace.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.key_rounded),
            label: Text(l10n.licenseActivate),
            onPressed: _busy ? null : _activate,
          ),
        ),
      ],
    );
  }
}
