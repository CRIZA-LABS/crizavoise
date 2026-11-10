import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crizavoise/common/common.dart';
import 'package:crizavoise/common/constants.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/database/invoice_number_service.dart';
import 'package:crizavoise/providers/cash_exchange_settings_provider.dart';
import 'package:crizavoise/providers/purchase_bills_settings_provider.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/providers/returns_settings_provider.dart';

class AccessibilityScreen extends ConsumerStatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  ConsumerState<AccessibilityScreen> createState() =>
      _AccessibilityScreenState();
}

class _AccessibilityScreenState extends ConsumerState<AccessibilityScreen> {
  bool _cashExchangeEnabled = false;
  bool _reportsAdminOnly = false;
  bool _purchaseBillsAdminOnly = false;
  CustomNumberAccess _numberAccess = CustomNumberAccess.off;

  @override
  void initState() {
    super.initState();
    _loadCashExchangeEnabled();
    _loadReportsAdminOnly();
    _loadPurchaseBillsAdminOnly();
    InvoiceNumberService.access().then((a) {
      if (mounted) setState(() => _numberAccess = a);
    });
  }

  Future<void> _setNumberAccess(CustomNumberAccess a) async {
    await InvoiceNumberService.setAccess(a);
    if (mounted) setState(() => _numberAccess = a);
  }

  /// Admin-only (the Settings area is admin-only): who may type their own
  /// invoice number. Safeguards are listed so the choice is informed.
  Widget _customNumbersCard(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.pin_outlined),
              const SizedBox(width: 16),
              Expanded(
                child: Text(l10n.customNumbersSettingTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.customNumbersSettingSubtitle,
                      style: TextStyle(fontSize: AppFontSize.xsmall, color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 14),
                  SegmentedButton<CustomNumberAccess>(
                    segments: [
                      ButtonSegment(value: CustomNumberAccess.off,
                          icon: const Icon(Icons.auto_mode_outlined), label: Text(l10n.customNumbersAccessOff)),
                      ButtonSegment(value: CustomNumberAccess.admins,
                          icon: const Icon(Icons.admin_panel_settings_outlined), label: Text(l10n.customNumbersAccessAdmins)),
                      ButtonSegment(value: CustomNumberAccess.everyone,
                          icon: const Icon(Icons.groups_outlined), label: Text(l10n.customNumbersAccessEveryone)),
                    ],
                    selected: {_numberAccess},
                    onSelectionChanged: (v) => _setNumberAccess(v.first),
                  ),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.verified_user_outlined, size: 18, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.customNumbersSafeguards,
                          style: TextStyle(fontSize: AppFontSize.xsmall, color: scheme.onSurfaceVariant)),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Saved immediately and pushed to the provider so the dashboard sidebar
  // shows/hides the Credit Notes / Debit Notes tabs without a restart.
  Future<void> _setReturnsEnabled(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.returnsEnabled, value.toString());
    ref.read(returnsEnabledProvider.notifier).state = value;
  }

  Future<void> _loadReportsAdminOnly() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.reportsAdminOnly);
    if (!mounted) return;
    setState(() => _reportsAdminOnly = v == 'true');
  }

  Future<void> _setReportsAdminOnly(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.reportsAdminOnly, value.toString());
    if (!mounted) return;
    setState(() => _reportsAdminOnly = value);
  }

  Future<void> _loadPurchaseBillsAdminOnly() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.purchaseBillsAndSuppliersAdminOnly);
    if (!mounted) return;
    setState(() => _purchaseBillsAdminOnly = v == 'true');
  }

  Future<void> _setPurchaseBillsAdminOnly(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.purchaseBillsAndSuppliersAdminOnly, value.toString());
    if (!mounted) return;
    setState(() => _purchaseBillsAdminOnly = value);
  }

  Future<void> _loadCashExchangeEnabled() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.cashUpiExchangeEnabled);
    if (!mounted) return;
    setState(() => _cashExchangeEnabled = v == 'true');
  }

  Future<void> _setCashExchangeEnabled(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.cashUpiExchangeEnabled, value.toString());
    if (!mounted) return;
    setState(() => _cashExchangeEnabled = value);
    ref.read(cashUpiExchangeEnabledProvider.notifier).state = value;
  }

  // Saved immediately and pushed to the provider so the dashboard sidebar
  // shows/hides the Purchase Bills / Suppliers tabs without a restart.
  Future<void> _setEnablePurchaseBills(bool value) async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.enablePurchaseBillsAndSuppliers, value.toString());
    ref.read(enablePurchaseBillsAndSuppliersProvider.notifier).state = value;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.settingsNavAccessibilityLabel),
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
                Text(l10n.accessibilityOptionalFeaturesSectionTitle,
                    style: const TextStyle(
                        fontSize: AppFontSize.large,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    secondary: const Icon(Icons.currency_exchange),
                    title: Text(l10n.accessibilityCashExchangeLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.accessibilityCashExchangeSubtitle,
                        style: TextStyle(
                            fontSize: AppFontSize.xsmall,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    value: _cashExchangeEnabled,
                    onChanged: _setCashExchangeEnabled,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    secondary: const Icon(Icons.bar_chart_outlined),
                    title: Text(l10n.accessibilityReportsAdminOnlyLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.accessibilityReportsAdminOnlySubtitle,
                        style: TextStyle(
                            fontSize: AppFontSize.xsmall,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    value: _reportsAdminOnly,
                    onChanged: _setReportsAdminOnly,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        secondary: const Icon(Icons.local_shipping_outlined),
                        title: Text(
                            l10n.settingsEnablePurchaseBillsSuppliersLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            l10n.settingsEnablePurchaseBillsSuppliersSubtitle,
                            style: TextStyle(
                                fontSize: AppFontSize.xsmall,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                        value:
                            ref.watch(enablePurchaseBillsAndSuppliersProvider),
                        onChanged: _setEnablePurchaseBills,
                      ),
                      // Purchase costs / supplier dues are business data,
                      // like Reports.
                      if (ref.watch(enablePurchaseBillsAndSuppliersProvider)) ...[
                        Divider(
                            height: 1,
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          secondary:
                              const Icon(Icons.admin_panel_settings_outlined),
                          title: Text(
                              l10n.accessibilityPurchaseBillsAdminOnlyLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              l10n.accessibilityPurchaseBillsAdminOnlySubtitle,
                              style: TextStyle(
                                  fontSize: AppFontSize.xsmall,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                          value: _purchaseBillsAdminOnly,
                          onChanged: _setPurchaseBillsAdminOnly,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    secondary: const Icon(Icons.assignment_return_outlined),
                    title: Text(l10n.returnsSettingTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.returnsSettingSubtitle,
                        style: TextStyle(
                            fontSize: AppFontSize.xsmall,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    value: ref.watch(returnsEnabledProvider),
                    onChanged: _setReturnsEnabled,
                  ),
                ),
                const SizedBox(height: 16),
                _customNumbersCard(l10n),
                const SizedBox(height: 24),
                if (!Platform.isAndroid) ...[
                  Text(l10n.dashboardKeyboardShortcutsTitle,
                      style: const TextStyle(
                          fontSize: AppFontSize.large,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.accessibilityShortcutsSubtitle,
                    style: TextStyle(
                        fontSize: AppFontSize.small,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Column(
                        children: AppShortcuts.all(context)
                            .map((s) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant),
                                        ),
                                        child: Text(s.$1,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(s.$2,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
