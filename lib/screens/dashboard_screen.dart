import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/widgets/license_banner.dart';
import 'package:crizavoise/services/pdf/pdf_font_service.dart';
import 'package:crizavoise/widgets/discovery_banner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crizavoise/common/constants.dart';
import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/theme/brand_assets.dart';
import 'package:crizavoise/utils/contact_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crizavoise/providers/app_config_provider.dart';
import 'package:crizavoise/providers/cash_exchange_settings_provider.dart';
import 'package:crizavoise/providers/purchase_bills_settings_provider.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/providers/returns_settings_provider.dart';
import 'package:crizavoise/services/update_service.dart';
import 'package:crizavoise/widgets/update_dialog.dart';
import 'package:crizavoise/domain/invoice_calculator.dart';
import 'package:crizavoise/domain/customer_identity.dart';
import 'package:crizavoise/theme/screen_colors.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/product.dart';
import 'package:crizavoise/common/common.dart';
import 'package:crizavoise/database/company_registry_service.dart';
import 'package:crizavoise/models/company_profile.dart';
import 'package:crizavoise/screens/settings/company_management_screen.dart';
import 'package:crizavoise/utils/company_switch_navigation.dart';
import 'package:crizavoise/screens/help/help_search_screen.dart';
import 'package:crizavoise/screens/settings/settings_screen.dart';
import 'package:crizavoise/services/invoice_pdf_services.dart';
import 'package:crizavoise/services/pdf_service.dart';
import 'package:crizavoise/utils/formatters.dart';
import 'package:crizavoise/widgets/apply_payment_dialog.dart';
import 'package:crizavoise/widgets/customer_info_button.dart';
import 'package:crizavoise/utils/session_manager.dart';

import 'package:crizavoise/models/user.dart';
// import 'package:crizavoise/screens/customer_management_screen.dart';
import 'package:crizavoise/screens/customer_management_screen_v2.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/screens/create_invoice_screen_v2.dart';
// import 'package:crizavoise/screens/product_management_screen.dart';
import 'package:crizavoise/screens/product_management_screen_v2.dart';
// import 'package:crizavoise/screens/invoice_management_screen.dart';
import 'package:crizavoise/screens/invoice_management_screen_v2.dart';
import 'package:crizavoise/screens/cash_exchange_screen.dart';
import 'package:crizavoise/screens/auth/login_screen.dart';
import 'package:crizavoise/screens/reports_screen.dart';
import 'package:crizavoise/screens/purchase_bill_management_screen.dart';
import 'package:crizavoise/screens/supplier_management_screen.dart';
import 'package:crizavoise/theme/swatch.dart';
import 'package:crizavoise/theme/tokens.dart';

// invoice.type is a raw internal value ('Invoice'/'Quotation'/'Receipt') used
// for comparisons throughout this file — only the displayed label is localized.
String _invoiceTypeLabel(BuildContext context, String type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case 'Quotation':
      return l10n.labelQuotation;
    case 'Receipt':
      return l10n.labelReceipt;
    default:
      return l10n.labelInvoice;
  }
}

// Final credit / debit notes are settled at creation and never edited.
bool _isFinalNote(Invoice inv) =>
    (inv.type == 'Credit Note' || inv.type == 'Debit Note') && !inv.isDraft;

// Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  final User loggedInUser;

  const DashboardScreen(this.loggedInUser, {super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  bool _reportsAdminOnly = false;
  // Reports hidden for this user (Settings → Accessibility).
  bool get _reportsLocked => _reportsAdminOnly && !_currentUser.isAdmin();
  bool _purchaseBillsAdminOnly = false;
  // Purchase Bills + Suppliers hidden for this user (Settings → Accessibility).
  bool get _purchaseBillsLocked =>
      _purchaseBillsAdminOnly && !_currentUser.isAdmin();
  bool _sidebarExpanded = true;
  late User _currentUser;
  String? _pendingReportsStatementCustomerKey;
  String? _companyName;
  List<CompanyProfile> _companies = [];
  String? _activeCompanyId;

  Invoice? invoiceToEdit;
  Invoice? _invoiceToClone;
  String _cloneType = 'Invoice';
  // Document type preselected on the create form for a brand-new doc, set by
  // the "New {type}" button on each management screen. Reset to 'Invoice' by
  // the nav-rail New Invoice action.
  String _newInvoiceType = 'Invoice';
  // Id of the quotation being converted to an invoice (drives the create
  // form's convert mode). Null unless a conversion is in flight.
  String? _convertSourceQuotationId;
  bool _hasUpdate = false;
  int? _accessibilityJumpToken;
  final InvoiceFormGuard _invoiceFormGuard = InvoiceFormGuard();
  final FocusNode _shortcutsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.loggedInUser;
    _loadServicesEnabled();
    _loadReturnsEnabled();
    _loadReportsAdminOnly();
    _loadPurchaseBillsAdminOnly();
    // Number format for every screen's amounts (cached; see AmountFormat).
    AmountFormat.load().then((_) {
      if (mounted) setState(() {});
    });
    _loadCompanies();
    // Load PDF fonts in the background so the first preview is instant.
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      Future.delayed(const Duration(seconds: 2), PdfFontService.warmUp);
    }
    SessionManager.initialize(_onSessionTimeout);
    if (ref.read(appEditionConfigProvider).enableUpdateCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
    // Tab 1 (Create Invoice) owns its own autofocus/shortcuts — only claim
    // focus here for the other tabs, so it doesn't get stolen away and
    // block the Create Invoice screen's own Ctrl shortcuts from working.
    if (_selectedIndex != 1) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _shortcutsFocusNode.requestFocus());
    }
  }

  Future<void> _loadCompanies() async {
    final companies = await CompanyRegistryService.listCompanies();
    final activeId = await CompanyRegistryService.getActiveCompanyId();
    if (!mounted) return;
    setState(() {
      _companies = companies;
      _activeCompanyId = activeId;
      _companyName = companies.where((c) => c.id == activeId).firstOrNull?.name;
    });
  }

  Future<void> _switchCompany(CompanyProfile company) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.companyMgmtSwitchConfirmTitle),
        content: Text(l10n.companyMgmtSwitchConfirmBody(company.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.companyMgmtSwitchButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await CompanyRegistryService.switchToCompany(company.id);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(l10n.companyMgmtSwitchErrorMessage(e.toString()));
      return;
    }
    if (!mounted) return;
    await returnToLoginAfterCompanyChange(context, ref);
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonErrorTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionOk),
          ),
        ],
      ),
    );
  }

  // Services nav item; the toggle lives in Settings → Accessibility.
  Future<void> _loadServicesEnabled() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.cashUpiExchangeEnabled);
    if (!mounted) return;
    ref.read(cashUpiExchangeEnabledProvider.notifier).state = v == 'true';
  }

  // Credit / Debit Notes nav items; the toggle lives in Settings → Accessibility.
  Future<void> _loadReturnsEnabled() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.returnsEnabled);
    if (!mounted) return;
    ref.read(returnsEnabledProvider.notifier).state = v == 'true';
  }

  Future<void> _loadReportsAdminOnly() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.reportsAdminOnly);
    if (!mounted) return;
    setState(() => _reportsAdminOnly = v == 'true');
  }

  Future<void> _loadPurchaseBillsAdminOnly() async {
    final v = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.purchaseBillsAndSuppliersAdminOnly);
    if (!mounted) return;
    setState(() => _purchaseBillsAdminOnly = v == 'true');
  }

  Future<void> _checkForUpdates() async {
    final info = await UpdateService.checkForUpdate();
    if (info == null) return;
    if (info.hasUpdate && mounted) setState(() => _hasUpdate = true);
    if (!await UpdateService.shouldNotify(info)) return;
    if (!mounted) return;
    await UpdateDialog.show(context, info);
  }

  @override
  void dispose() {
    SessionManager.dispose();
    _shortcutsFocusNode.dispose();
    super.dispose();
  }

  void _logoutAndResetSession() async {
    await ref.read(authRepositoryProvider).logoutAndSessionReset();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _onSessionTimeout() {
    if (!mounted) return;
    // Clear the whole stack — a dialog or pushed screen may be on top, and
    // pushReplacement would leave the dashboard reachable behind Login.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (_) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(AppLocalizations.of(context)!.dashboardSessionExpiredMessage),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _refreshUser() async {
    final cfg = ref.watch(appEditionConfigProvider);
    if (cfg.isCloud || !mounted) return;
    final fresh =
        await ref.read(authRepositoryProvider).getUserById(_currentUser.id);
    if (fresh != null && mounted) {
      setState(() => _currentUser = fresh);
    }
  }

  Widget buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHome(
            onEditInvoice: editInvoice,
            onCloneInvoice: cloneInvoice,
            onQuickAction: (a) => switch (a) {
                  DashboardAction.newInvoice => _createDocumentOfType('Invoice'),
                  DashboardAction.newQuotation => _createDocumentOfType('Quotation'),
                  DashboardAction.newReceipt => _createDocumentOfType('Receipt'),
                  DashboardAction.invoices => _selectTab(2),
                  DashboardAction.customers => _selectTab(5),
                  DashboardAction.products => _selectTab(6),
                },
            user: _currentUser);
      case 1:
        final isNewDoc = invoiceToEdit == null && _invoiceToClone == null;
        final createInvoiceKey = ValueKey(
            'create_invoice_${invoiceToEdit?.id ?? 'new'}_${_invoiceToClone?.id ?? ''}_${isNewDoc ? _newInvoiceType : ''}_${_convertSourceQuotationId ?? ''}');
        void onCreateNewInvoice() {
          if (!mounted) return;
          setState(() {
            invoiceToEdit = null;
            _invoiceToClone = null;
            _newInvoiceType = 'Invoice';
            _convertSourceQuotationId = null;
          });
        }
        return CreateInvoiceScreenV2(
          key: createInvoiceKey,
          invoiceToEdit: invoiceToEdit,
          cloneFrom: _invoiceToClone,
          cloneType: _invoiceToClone != null ? _cloneType : null,
          initialType: isNewDoc ? _newInvoiceType : null,
          convertFromQuotationId: _convertSourceQuotationId,
          guard: _invoiceFormGuard,
          onCreateNewInvoice: onCreateNewInvoice,
          user: _currentUser,
        );
      case 2:
        return InvoiceManagementScreenV2(
          key: const ValueKey('invoice_list'),
          onEditInvoice: editInvoice,
          onCloneInvoice: cloneInvoice,
          onCreateNew: _createDocumentOfType,
          user: _currentUser,
          filterType: 'Invoice',
        );
      case 3:
        return InvoiceManagementScreenV2(
          key: const ValueKey('quotation_list'),
          onEditInvoice: editInvoice,
          onCloneInvoice: cloneInvoice,
          onCreateNew: _createDocumentOfType,
          onConvertToInvoice: _convertQuotationToInvoice,
          user: _currentUser,
          filterType: 'Quotation',
        );
      case 4:
        return InvoiceManagementScreenV2(
          key: const ValueKey('receipt_list'),
          onEditInvoice: editInvoice,
          onCloneInvoice: cloneInvoice,
          onCreateNew: _createDocumentOfType,
          user: _currentUser,
          filterType: 'Receipt',
        );
      case 5:
        return CustomerManagementScreenV2(
          user: _currentUser,
          onViewCustomerStatement: _reportsLocked
              ? null
              : (c) {
                  setState(() {
                    _pendingReportsStatementCustomerKey =
                        CustomerIdentity.key(id: c.id, name: c.name);
                    _selectedIndex = 7;
                  });
                },
        );
      case 6:
        return ProductManagementScreenV2(user: _currentUser);
      case 7 when !_reportsLocked:
        final statementCustomerKey = _pendingReportsStatementCustomerKey;
        _pendingReportsStatementCustomerKey = null;
        return ReportsScreen(
            initialStatementCustomerKey: statementCustomerKey,
            isAdmin: _currentUser.isAdmin());
      case 8:
        return SettingsScreen(
          currentUser: _currentUser,
          openAccessibilityToken: _accessibilityJumpToken,
        );
      case 9: // Services (Cash / UPI-Bank exchange); shown after New Invoice
        return CashExchangeScreen(user: _currentUser);
      case 10 when !_purchaseBillsLocked:
        return ref.watch(enablePurchaseBillsAndSuppliersProvider)
            ? PurchaseBillManagementScreen(user: _currentUser)
            : Center(
                child: Text(
                    AppLocalizations.of(context)!.dashboardUnknownTabLabel));
      case 11 when !_purchaseBillsLocked:
        return ref.watch(enablePurchaseBillsAndSuppliersProvider)
            ? SupplierManagementScreen(user: _currentUser)
            : Center(
                child: Text(
                    AppLocalizations.of(context)!.dashboardUnknownTabLabel));
      case 12:
        return InvoiceManagementScreenV2(
          key: const ValueKey('credit_note_list'),
          onEditInvoice: editInvoice,
          onCloneInvoice: cloneInvoice,
          onCreateNew: _createDocumentOfType,
          user: _currentUser,
          filterType: 'Credit Note',
        );
      case 13:
        return InvoiceManagementScreenV2(
          key: const ValueKey('debit_note_list'),
          onEditInvoice: editInvoice,
          onCloneInvoice: cloneInvoice,
          onCreateNew: _createDocumentOfType,
          user: _currentUser,
          filterType: 'Debit Note',
        );
      default:
        return Center(
            child:
                Text(AppLocalizations.of(context)!.dashboardUnknownTabLabel));
    }
  }

  void editInvoice(Invoice invoice) {
    _openEditInvoice(invoice);
  }

  Future<void> _openEditInvoice(Invoice invoice) async {
    if (!await _canLeaveInvoiceForm()) return;
    if (!mounted) return;
    setState(() {
      _selectedIndex = 1;
      invoiceToEdit = invoice;
      _invoiceToClone = null;
      _convertSourceQuotationId = null;
    });
    _shortcutsFocusNode.unfocus();
  }

  void cloneInvoice(Invoice invoice, String type) {
    _openCloneInvoice(invoice, type);
  }

  Future<void> _openCloneInvoice(Invoice invoice, String type) async {
    if (!await _canLeaveInvoiceForm()) return;
    if (!mounted) return;
    setState(() {
      _selectedIndex = 1;
      invoiceToEdit = null;
      _invoiceToClone = invoice;
      _cloneType = type;
      _convertSourceQuotationId = null;
    });
    _shortcutsFocusNode.unfocus();
  }

  // "New {type}" button on the Invoice / Quotation / Receipt management screens
  // — opens the create form with that document type preselected.
  Future<void> _createDocumentOfType(String type) async {
    if (!await _canLeaveInvoiceForm()) return;
    if (!mounted) return;
    setState(() {
      _selectedIndex = 1;
      invoiceToEdit = null;
      _invoiceToClone = null;
      _newInvoiceType = type;
      _convertSourceQuotationId = null;
    });
    _shortcutsFocusNode.unfocus();
  }

  // "Convert to Invoice" action on a quotation row — opens the create form
  // pre-filled from the quotation, locked to Invoice type; on save the
  // quotation is stamped 'converted' and the two are linked.
  Future<void> _convertQuotationToInvoice(Invoice quotation) async {
    if (!await _canLeaveInvoiceForm()) return;
    if (!mounted) return;
    setState(() {
      _selectedIndex = 1;
      invoiceToEdit = null;
      _invoiceToClone = quotation;
      _cloneType = 'Invoice';
      _convertSourceQuotationId = quotation.id;
    });
    _shortcutsFocusNode.unfocus();
  }

  Future<bool> _canLeaveInvoiceForm() async {
    return await _invoiceFormGuard.canLeave?.call() ?? true;
  }

  Future<void> _selectTab(int index) async {
    if (_selectedIndex == index) return;
    if (_selectedIndex == 1 && !await _canLeaveInvoiceForm()) return;
    if (_selectedIndex == 7 && index != 7) await _refreshUser();
    if (_selectedIndex == 8 && index != 8) {
      await _loadServicesEnabled();
      await _loadReturnsEnabled();
      await _loadReportsAdminOnly();
      await _loadPurchaseBillsAdminOnly();
    }
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      if (index != 1) {
        invoiceToEdit = null;
        _invoiceToClone = null;
        _convertSourceQuotationId = null;
      } else {
        // Nav-rail "New Invoice" always means a plain, blank invoice.
        _newInvoiceType = 'Invoice';
        _invoiceToClone = null;
        _convertSourceQuotationId = null;
      }
    });
    // See initState: only hold shortcuts focus for non-create-invoice tabs.
    // Autofocus is a no-op while this scope already has a focused node, so
    // on the way IN to tab 1 we must explicitly unfocus — otherwise Create
    // Invoice's own `Focus(autofocus: true)` never actually takes focus and
    // its Ctrl+S/N/M/O/P shortcuts silently stop firing.
    if (index == 1) {
      _shortcutsFocusNode.unfocus();
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _shortcutsFocusNode.requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SessionManager.onUserActivity,
      onPanDown: (_) => SessionManager.onUserActivity(),
      behavior: HitTestBehavior.translucent,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () =>
              _selectTab(1),
        },
        child: Focus(
          focusNode: _shortcutsFocusNode,
          child: Scaffold(
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      const LicenseStrip(),
                      Expanded(child: buildScreen()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final expanded = _sidebarExpanded;
    final primary = Theme.of(context).primaryColor;
    final cfg = ref.watch(appEditionConfigProvider);
    final showPurchaseBillsAndSuppliers =
        ref.watch(enablePurchaseBillsAndSuppliersProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: expanded ? 210 : 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
            right: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant, width: 1)),
      ),
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logo + toggle ──────────────────────────
            if (expanded)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 76,
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 16,
                            right: 36,
                            child: Image.asset(
                              Theme.of(context).brightness == Brightness.dark
                                  ? BrandAssets.lockupDark
                                  : BrandAssets.lockupLight,
                              height: 36, // Criza lockup minimum
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              filterQuality: FilterQuality.medium,
                              semanticLabel: AppConfig.name,
                            ),
                          ),
                          Positioned(
                            right: 6,
                            child: Tooltip(
                              message: AppLocalizations.of(context)!
                                  .dashboardCollapseSidebarTooltip,
                              child: InkWell(
                                onTap: () {
                                  if (!mounted) return;
                                  setState(() => _sidebarExpanded = false);
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.chevron_left_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_companyName?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: PopupMenuButton<String>(
                          tooltip: '',
                          padding: EdgeInsets.zero,
                          offset: const Offset(0, 40),
                          itemBuilder: (context) => [
                            for (final company in _companies)
                              PopupMenuItem<String>(
                                value: company.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      company.id == _activeCompanyId
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 18,
                                      color: company.id == _activeCompanyId
                                          ? CvSwatch.success
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                        child: Text(company.name,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: '__manage__',
                              child: Row(
                                children: [
                                  Icon(Icons.settings_outlined,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                  const SizedBox(width: 10),
                                  Text(AppLocalizations.of(context)!
                                      .companyMgmtTitle),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == '__manage__') {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => CompanyManagementScreen(
                                    currentUser: _currentUser),
                              ));
                            } else if (value != _activeCompanyId) {
                              final company = _companies
                                  .where((c) => c.id == value)
                                  .firstOrNull;
                              if (company != null) _switchCompany(company);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // `expanded` flips true while the sidebar is still ~64px
                            // wide mid-animation; give the row a minimum width and
                            // clip the excess instead of overflowing.
                            child: LayoutBuilder(
                              builder: (context, constraints) => UnconstrainedBox(
                                constrainedAxis: Axis.vertical,
                                alignment: Alignment.centerLeft,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: constraints.maxWidth < 60
                                      ? 60
                                      : constraints.maxWidth,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: primary,
                                        child: Text(
                                          _companyName!.trim()[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _companyName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.expand_more, size: 16, color: primary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              )
            else
              SizedBox(
                height: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: _companyName ?? '',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SvgPicture.asset(
                          BrandAssets.markFor(Theme.of(context).brightness, size: 38),
                          width: 38,
                          height: 38,
                          semanticsLabel: AppConfig.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .dashboardExpandSidebarTooltip,
                      child: InkWell(
                        onTap: () {
                          if (!mounted) return;
                          setState(() => _sidebarExpanded = true);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.chevron_right_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 1,
                thickness: 1),
            const SizedBox(height: 8),

            // ── Nav Items ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── 5 main destinations (Phase 2 IA) ──────
                    _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard,
                        AppLocalizations.of(context)!.navDashboard),
                    _buildNavItem(1, Icons.receipt_outlined, Icons.receipt,
                        AppLocalizations.of(context)!.navNewInvoice),
                    _buildNavItem(
                        2,
                        Icons.receipt_long_outlined,
                        Icons.receipt_long,
                        AppLocalizations.of(context)!.navInvoices),
                    _buildNavItem(5, Icons.people_outline, Icons.people,
                        AppLocalizations.of(context)!.navCustomers),
                    _buildNavItem(
                        6,
                        Icons.inventory_2_outlined,
                        Icons.inventory_2,
                        AppLocalizations.of(context)!.navProducts),
                    // ── Everything else, one tap away ─────────
                    _buildMoreGroup([
                      (3, Icons.request_quote_outlined, Icons.request_quote,
                          AppLocalizations.of(context)!.navQuotations),
                      (4, Icons.point_of_sale_outlined, Icons.point_of_sale,
                          AppLocalizations.of(context)!.navReceipts),
                      if (ref.watch(returnsEnabledProvider)) ...[
                        (12, Icons.assignment_return_outlined, Icons.assignment_return,
                            AppLocalizations.of(context)!.navCreditNotes),
                        (13, Icons.assignment_late_outlined, Icons.assignment_late,
                            AppLocalizations.of(context)!.navDebitNotes),
                      ],
                      if (ref.watch(cashUpiExchangeEnabledProvider))
                        (9, Icons.currency_exchange, Icons.currency_exchange,
                            AppLocalizations.of(context)!.navServices),
                      if (showPurchaseBillsAndSuppliers && !_purchaseBillsLocked) ...[
                        (10, Icons.shopping_cart_outlined, Icons.shopping_cart,
                            AppLocalizations.of(context)!.navPurchaseBills),
                        (11, Icons.local_shipping_outlined, Icons.local_shipping,
                            AppLocalizations.of(context)!.navSuppliers),
                      ],
                      if (!_reportsLocked)
                        (7, Icons.bar_chart_outlined, Icons.bar_chart,
                            AppLocalizations.of(context)!.navReports),
                    ]),
                    _buildNavItem(8, Icons.settings_outlined, Icons.settings,
                        AppLocalizations.of(context)!.navSettings,
                        showDot: _hasUpdate),
                  ],
                ),
              ),
            ),

            // ── Search Help & Settings ──────────────────
            _buildSearchNavItem(),
            const SizedBox(height: 4),

            // ── User Info ──────────────────────────────
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 1,
                thickness: 1),
            LayoutBuilder(
              builder: (context, constraints) {
                // Row below needs ~178px of fixed content (padding + avatar +
                // 3 icon buttons) — switch only once it fits, not at 110.
                final useExpanded = constraints.maxWidth > 180;
                if (useExpanded) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: primary.withValues(alpha: 0.12),
                              child: Text(
                                _currentUser.username.isNotEmpty
                                    ? _currentUser.username[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentUser.username,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _currentUser.isAdmin()
                                        ? AppLocalizations.of(context)!
                                            .dashboardRoleAdmin
                                        : AppLocalizations.of(context)!
                                            .dashboardRoleUser,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: AppLocalizations.of(context)!
                                  .dashboardSupportTooltip,
                              child: InkWell(
                                onTap: () => showHelpSearchDialog(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.support_agent_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 18),
                                ),
                              ),
                            ),
                            Tooltip(
                              message: AppLocalizations.of(context)!
                                  .dashboardLogoutTooltip,
                              child: InkWell(
                                onTap: () => _logoutAndResetSession(),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.logout_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            cfg.version,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (TestBuildConfig.isTestBuild) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CvSwatch.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!
                                    .dashboardTestBuildBadge,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: CvSwatch.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Tooltip(
                          message: _currentUser.username,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: primary.withValues(alpha: 0.12),
                            child: Text(
                              _currentUser.username.isNotEmpty
                                  ? _currentUser.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .dashboardSupportTooltip,
                          child: InkWell(
                            onTap: () => showHelpSearchDialog(context),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.support_agent_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Tooltip(
                          message: AppLocalizations.of(context)!
                              .dashboardLogoutTooltip,
                          child: InkWell(
                            onTap: () => _logoutAndResetSession(),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.logout_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          cfg.version,
                          style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(context).colorScheme.outlineVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (TestBuildConfig.isTestBuild) ...[
                        const SizedBox(height: 3),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: CvSwatch.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .dashboardTestBadgeShort,
                              style: TextStyle(
                                fontSize: 7,
                                color: CvSwatch.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ), // ClipRect
    );
  }

  /*
  Widget _buildComingSoonNavItem(IconData icon, String label) {
    const disabledColor = CvSwatch.neutralSoft;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useExpanded = constraints.maxWidth > 110;

        if (!useExpanded) {
          return Tooltip(
            message: '$label — Coming Soon',
            preferBelow: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: disabledColor, size: 20),
              ),
            ),
          );
        }

        return Tooltip(
          message: 'Coming Soon',
          preferBelow: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, color: disabledColor, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: disabledColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: const Text(
                      'Soon',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: disabledColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  */

  bool _moreExpanded = false;

  /// Collapsible "More" group: every secondary destination stays one tap
  /// away. It opens by itself when the current page is one of its items.
  Widget _buildMoreGroup(List<(int, IconData, IconData, String)> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final containsSelected = items.any((i) => i.$1 == _selectedIndex);
    final open = _moreExpanded || containsSelected;
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 110;
          final header = InkWell(
            onTap: containsSelected ? null : () => setState(() => _moreExpanded = !_moreExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: wide ? 12 : 0, vertical: 11),
              child: Row(
                mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Icon(open ? Icons.expand_less : Icons.apps_outlined,
                      size: 20, color: scheme.onSurfaceVariant),
                  if (wide) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l10n.navMore,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ),
                    Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 18, color: scheme.onSurfaceVariant),
                  ],
                ],
              ),
            ),
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 10 : 8, vertical: 2),
            child: Tooltip(message: l10n.navMore, child: Material(type: MaterialType.transparency, child: header)),
          );
        }),
        AnimatedSize(
          duration: CvMotion.scaled(context, CvMotion.base),
          curve: CvMotion.standard,
          alignment: Alignment.topCenter,
          child: open
              ? Column(children: [
                  for (final (i, outline, filled, label) in items)
                    _buildNavItem(i, outline, filled, label),
                ])
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildNavItem(
      int index, IconData outlinedIcon, IconData filledIcon, String label,
      {bool showDot = false}) {
    final selected = _selectedIndex == index;
    final primary = Theme.of(context).primaryColor;

    Future<void> onTap() => _selectTab(index);

    // Use LayoutBuilder so the layout switches based on actual rendered width,
    // not just state — prevents overflow errors during the AnimatedContainer transition.
    return LayoutBuilder(
      builder: (context, constraints) {
        final useExpanded = constraints.maxWidth > 110;

        if (!useExpanded) {
          return Tooltip(
            message: label,
            preferBelow: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: primary.withValues(alpha: 0.06),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          selected ? filledIcon : outlinedIcon,
                          color: selected
                              ? primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        if (showDot)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CvSwatch.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              hoverColor: primary.withValues(alpha: 0.06),
              splashColor: primary.withValues(alpha: 0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          selected ? filledIcon : outlinedIcon,
                          color: selected
                              ? primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        if (showDot)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: CvSwatch.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchNavItem() {
    final primary = Theme.of(context).primaryColor;
    final label = AppLocalizations.of(context)!.helpSearchTooltip;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useExpanded = constraints.maxWidth > 110;

        if (!useExpanded) {
          return Tooltip(
            message: label,
            preferBelow: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => showHelpSearchDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: primary.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.search, color: onSurfaceVariant, size: 20),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => showHelpSearchDialog(context),
              borderRadius: BorderRadius.circular(8),
              hoverColor: primary.withValues(alpha: 0.06),
              splashColor: primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  children: [
                    Icon(Icons.search, color: onSurfaceVariant, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Big shortcut tiles on the dashboard home.
enum DashboardAction { newInvoice, newQuotation, newReceipt, invoices, customers, products }

class DashboardHome extends ConsumerStatefulWidget {
  final Function(Invoice) onEditInvoice;
  final void Function(DashboardAction)? onQuickAction;
  final Function(Invoice, String) onCloneInvoice;
  final User user;
  const DashboardHome({
    required this.onEditInvoice,
    required this.onCloneInvoice,
    required this.user,
    this.onQuickAction,
    super.key,
  });

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  final dbHelper = DatabaseHelper();
  int totalCustomers = 0;
  int totalProducts = 0;
  int totalInvoices = 0;
  double totalRevenue = 0.0;
  double totalOutstanding = 0.0;
  List<Invoice> recentInvoices = [];
  List<Invoice> dueSoonInvoices = [];
  List<Product> outOfStockProducts = [];
  List<Product> lowStockProducts = [];
  // Hides "Update stock" when stock editing is admin-only.
  bool _stockLocked = false;
  List<Invoice> overdueInvoices = [];
  String _currencySymbol = '₹';
  bool isLoading = true;
  String _dashboardLayout = 'default';
  bool _showLayoutBanner = false;
  bool _showShortcutsBanner = false;
  bool _showPurchaseBanner = false;
  bool _showSupportBanner = false;
  String _supportMilestone = '';
  List<Map<String, dynamic>> _monthlyRevenue = [];
  List<Map<String, dynamic>> _topCustomers = [];
  List<Map<String, dynamic>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final results = await Future.wait([
      ref.read(customerRepositoryProvider).getTotalCustomerCount(), // 0
      ref.read(productRepositoryProvider).getTotalProductCount(), // 1
      ref.read(invoiceRepositoryProvider).getDashboardFinancials(), // 2
      ref.read(invoiceRepositoryProvider).getRecentInvoices(limit: 5), // 3
      ref.read(invoiceRepositoryProvider).getDueSoonInvoices(), // 4
      ref.read(invoiceRepositoryProvider).getOverdueInvoices(limit: 10), // 5
      ref.read(settingsRepositoryProvider).getCurrency(), // 6
      ref.read(invoiceRepositoryProvider).getMonthlyRevenue(), // 7
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.dashboardLayout), // 8
      ref.read(invoiceRepositoryProvider).getTopCustomers(), // 9
      ref.read(invoiceRepositoryProvider).getTopProducts(), // 10
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.layoutBannerDismissed), // 11
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.supportBannerDismissed), // 12
      ref.read(productRepositoryProvider).getOutOfStockProducts(), // 13
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.themeBannerDismissed), // 14
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.shortcutsBannerDismissed), // 15
      ref.read(productRepositoryProvider).getLowStockProducts(), // 16
      ref.read(settingsRepositoryProvider).getProductColumnsConfig(), // 17
      ref
          .read(settingsRepositoryProvider)
          .getSetting(SettingKey.purchaseBillsBannerDismissed), // 18
    ]);

    final customerCount = results[0] as int;
    final productCount = results[1] as int;
    final financials =
        results[2] as ({int count, double revenue, double outstanding});
    final recent = results[3] as List<Invoice>;
    final dueSoon = results[4] as List<Invoice>;
    final overdue = results[5] as List<Invoice>;
    final currency = results[6] as CurrencyOption;
    final monthly = results[7] as List<Map<String, dynamic>>;
    final layout = results[8] as String?;
    final topCust = results[9] as List<Map<String, dynamic>>;
    final topProd = results[10] as List<Map<String, dynamic>>;
    final bannerDismissed = results[11] as String?;
    final supportDismissed = results[12] as String?;
    final outOfStock = results[13] as List<Product>;
    final lowStock = results[16] as List<Product>;
    final stockLocked =
        (results[17] as ProductColumnsConfig).stockEditAdminOnly &&
            !widget.user.isAdmin();
    final shortcutsBannerDismissed =
        Platform.isAndroid ? '1' : results[15] as String?;
    final String milestone = financials.count >= 100
        ? '100'
        : financials.count >= 50
            ? '50'
            : financials.count > 10
                ? '10'
                : '';
    if (!mounted) return;
    setState(() {
      totalCustomers = customerCount;
      totalProducts = productCount;
      outOfStockProducts = outOfStock;
      lowStockProducts = lowStock;
      _stockLocked = stockLocked;
      totalInvoices = financials.count;
      totalRevenue = financials.revenue;
      totalOutstanding = financials.outstanding;
      recentInvoices = recent;
      dueSoonInvoices = dueSoon;
      overdueInvoices = overdue;
      _currencySymbol = currency.symbol;
      _monthlyRevenue = monthly;
      _dashboardLayout = layout ?? 'default';
      _topCustomers = topCust;
      _topProducts = topProd;
      _showLayoutBanner = bannerDismissed != '1';
      _showShortcutsBanner = shortcutsBannerDismissed != '1';
      _showPurchaseBanner = (results[18] as String?) != '1';
      _supportMilestone = milestone;
      _showSupportBanner =
          milestone.isNotEmpty && supportDismissed != milestone;
      isLoading = false;
    });
  }

  Future<void> _dismissSupportBanner() async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.supportBannerDismissed, _supportMilestone);
    if (mounted) setState(() => _showSupportBanner = false);
  }

  Future<void> _dismissLayoutBanner() async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.layoutBannerDismissed, '1');
    if (mounted) setState(() => _showLayoutBanner = false);
  }

  Future<void> _dismissShortcutsBanner() async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.shortcutsBannerDismissed, '1');
    if (mounted) setState(() => _showShortcutsBanner = false);
  }

  Future<void> _dismissPurchaseBanner() async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.purchaseBillsBannerDismissed, '1');
    if (mounted) setState(() => _showPurchaseBanner = false);
  }

  // Same as the Settings → Accessibility toggle; the sidebar picks it up
  // from the provider immediately.
  Future<void> _enablePurchaseBills() async {
    await ref
        .read(settingsRepositoryProvider)
        .setSetting(SettingKey.enablePurchaseBillsAndSuppliers, 'true');
    ref.read(enablePurchaseBillsAndSuppliersProvider.notifier).state = true;
    await _dismissPurchaseBanner();
  }

  void _showShortcutsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.keyboard_outlined),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.dashboardKeyboardShortcutsTitle),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppShortcuts.all(context)
                .map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                            ),
                            child: Text(s.$1,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(s.$2,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.actionClose),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsDiscoveryBanner() {
    return DiscoveryBanner(
      visible: _showShortcutsBanner,
      icon: Icons.keyboard_outlined,
      iconColor: CvSwatch.success,
      backgroundColor: CvSwatch.successTint,
      borderColor: CvSwatch.successSoft,
      title: Text(
        AppLocalizations.of(context)!.dashboardShortcutsBannerTitle,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: CvSwatch.success),
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.dashboardShortcutsBannerSubtitle,
        style: const TextStyle(fontSize: 12, color: CvSwatch.success),
      ),
      actionLabel: AppLocalizations.of(context)!.dashboardViewAllAction,
      onAction: _showShortcutsDialog,
      actionColor: CvSwatch.success,
      onDismiss: _dismissShortcutsBanner,
      dismissIconColor: CvSwatch.successSoft,
    );
  }

  // Admin-only (Settings, where the feature is toggled, is admin-only);
  // hidden once the feature is on.
  Widget _buildPurchaseDiscoveryBanner() {
    return DiscoveryBanner(
      visible: _showPurchaseBanner &&
          widget.user.isAdmin() &&
          !ref.watch(enablePurchaseBillsAndSuppliersProvider),
      icon: Icons.local_shipping_outlined,
      iconColor: CvSwatch.neutral,
      backgroundColor: CvSwatch.neutralTint,
      borderColor: CvSwatch.neutralSoft,
      title: Text(
        AppLocalizations.of(context)!.dashboardPurchaseBannerTitle,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: CvSwatch.neutral),
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.dashboardPurchaseBannerSubtitle,
        style: const TextStyle(fontSize: 12, color: CvSwatch.neutral),
      ),
      actionLabel: AppLocalizations.of(context)!.dashboardPurchaseBannerAction,
      onAction: _enablePurchaseBills,
      actionColor: CvSwatch.neutral,
      onDismiss: _dismissPurchaseBanner,
      dismissIconColor: CvSwatch.neutralSoft,
    );
  }

  Widget _buildLayoutDiscoveryBanner() {
    return DiscoveryBanner(
      visible: _showLayoutBanner,
      icon: Icons.dashboard_customize_outlined,
      iconColor: CvSwatch.neutral,
      backgroundColor: CvSwatch.neutralTint,
      borderColor: CvSwatch.neutralSoft,
      title: Text(
        AppLocalizations.of(context)!.dashboardLayoutBannerTitle,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: CvSwatch.neutral),
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.dashboardLayoutBannerSubtitle,
        style: const TextStyle(fontSize: 12, color: CvSwatch.neutral),
      ),
      actionLabel: AppLocalizations.of(context)!.actionGotIt,
      onAction: _dismissLayoutBanner,
      actionColor: CvSwatch.neutral,
      onDismiss: _dismissLayoutBanner,
      dismissIconColor: CvSwatch.neutralSoft,
    );
  }

  Widget _buildSupportBanner() {
    final bool isReviewMilestone = _supportMilestone == '10';
    return DiscoveryBanner(
      visible: _showSupportBanner,
      margin: const EdgeInsets.only(bottom: 16),
      crossAxisAlignment: CrossAxisAlignment.start,
      icon: isReviewMilestone ? Icons.star_outline : Icons.celebration_outlined,
      iconSize: 22,
      iconColor: CvSwatch.warning,
      backgroundColor: CvSwatch.warningTint,
      borderColor: CvSwatch.warningSoft,
      title: Text(
        AppLocalizations.of(context)!
            .dashboardSupportBannerTitle(_supportMilestone),
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: CvSwatch.warning),
      ),
      subtitle: Text(
        isReviewMilestone
            ? AppLocalizations.of(context)!.dashboardSupportBannerReviewSubtitle
            : AppLocalizations.of(context)!
                .dashboardSupportBannerSupportSubtitle,
        style: const TextStyle(fontSize: 12, color: CvSwatch.warning),
      ),
      actionLabel: isReviewMilestone
          ? AppLocalizations.of(context)!.dashboardReviewAction
          : AppLocalizations.of(context)!.dashboardSupportAction,
      onAction: () async {
        await openContact(ContactChannel.support,
            topic: isReviewMilestone ? 'Feedback' : null);
      },
      actionColor: CvSwatch.warning,
      actionBackgroundColor: CvSwatch.warningSoft,
      onDismiss: _dismissSupportBanner,
      dismissIconColor: CvSwatch.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboardOverviewTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          _buildLayoutToggle(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: AppLocalizations.of(context)!.actionRefresh,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_dashboardLayout) {
      case 'classic':
        return _buildClassicLayout();
      case 'simple':
        return _buildSimpleFeedLayout();
      case 'bento':
        return _buildBentoLayout();
      default:
        return _buildDefaultLayout();
    }
  }

  Widget _buildDefaultLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxWidthNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOneDiscoveryBanner(),
              // ── Greeting Banner ──────────────────────────────
              _buildGreetingBanner(),
              _buildQuickActions(),

              const SizedBox(height: 28),

              // ── Stats Row ────────────────────────────────────
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatCard(
                        AppLocalizations.of(context)!.navCustomers,
                        totalCustomers.toString(),
                        CvSwatch.neutral,
                        Icons.people_outline),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      AppLocalizations.of(context)!.navProducts,
                      totalProducts.toString(),
                      CvSwatch.success,
                      Icons.inventory_2_outlined,
                      subtitle: outOfStockProducts.isNotEmpty
                          ? AppLocalizations.of(context)!
                              .dashboardOutOfStockCountLabel(
                                  outOfStockProducts.length)
                          : null,
                      subtitleColor: CvSwatch.danger,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                        AppLocalizations.of(context)!.navInvoices,
                        totalInvoices.toString(),
                        CvSwatch.warning,
                        Icons.receipt_long_outlined),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      AppLocalizations.of(context)!
                          .dashboardRevenueCollectedLabel,
                      '$_currencySymbol ${AmountFormat.money(totalRevenue)}',
                      CvSwatch.neutral,
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      AppLocalizations.of(context)!.dashboardOutstandingLabel,
                      '$_currencySymbol ${AmountFormat.money(totalOutstanding)}',
                      CvSwatch.danger,
                      Icons.hourglass_top_outlined,
                      subtitle: overdueInvoices.isNotEmpty
                          ? AppLocalizations.of(context)!
                              .dashboardOverdueCountLabel(
                                  overdueInvoices.length)
                          : null,
                      subtitleColor: CvSwatch.danger,
                    ),
                  ],
                ),
              ),

              // ── Due Soon ─────────────────────────────────────
              if (dueSoonInvoices.isNotEmpty) ...[
                const SizedBox(height: 36),
                _buildDueSoonSection(),
              ],

              // ── Out of Stock ──────────────────────────────────
              if (outOfStockProducts.isNotEmpty) ...[
                const SizedBox(height: 36),
                _buildOutOfStockSection(),
              ],
              if (lowStockProducts.isNotEmpty) ...[
                const SizedBox(height: 36),
                _buildOutOfStockSection(low: true),
              ],

              // ── Overdue Invoices ──────────────────────────────
              if (overdueInvoices.isNotEmpty) ...[
                const SizedBox(height: 36),
                _buildOverdueSection(),
              ],

              const SizedBox(height: 36),

              // ── Recent Invoices Header ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.dashboardRecentInvoicesTitle,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!
                        .dashboardLastFiveInvoicesLabel,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              recentInvoices.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 80,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!
                                  .dashboardNoInvoicesYetTitle,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!
                                  .dashboardNoInvoicesYetSubtitle,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = recentInvoices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 2,
                            shadowColor: Colors.black.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.xsmall),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  if (invoice.dueDate == null)
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context).primaryColor,
                                            Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            AppBorderRadius.xsmall),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (invoice.dueDate != null)
                                    () {
                                      final isOverdue =
                                          InvoiceCalculator.isOverdue(
                                        dueDate: invoice.dueDate,
                                        outstanding: invoice.outstandingBalance,
                                      );
                                      return Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          gradient: isOverdue
                                              ? DashboardScreenColors
                                                  .invoiceNumberOverDueLinearGradient
                                              : LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Theme.of(context)
                                                        .primaryColor,
                                                    Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.7),
                                                  ],
                                                ),
                                          borderRadius: BorderRadius.circular(
                                              AppBorderRadius.xsmall),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    }(),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              invoice.isDraft
                                                  ? '${invoice.type} · ${AppLocalizations.of(context)!.invoiceDraftBadge}'
                                                  : '${invoice.type} #${invoice.invoiceNumber ?? invoice.id}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: invoice.type == 'Invoice'
                                                    ? CvSwatch.neutral
                                                        .withValues(alpha: 0.1)
                                                    : CvSwatch.warning
                                                        .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color:
                                                      invoice.type == 'Invoice'
                                                          ? CvSwatch.neutral
                                                              .withValues(
                                                                  alpha: 0.35)
                                                          : CvSwatch.warning
                                                              .withValues(
                                                                  alpha: 0.35),
                                                ),
                                              ),
                                              child: Text(
                                                _invoiceTypeLabel(
                                                    context, invoice.type),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      invoice.type == 'Invoice'
                                                          ? CvSwatch.neutral
                                                          : CvSwatch.warning,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            if (invoice.type == 'Invoice')
                                              _buildPaymentStatusChip(
                                                  invoice.paymentStatus),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person_outline,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                    child: Text(
                                                  invoice.customer.name
                                                      .limit(15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface),
                                                )),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                    child: Text(
                                                  invoice.date
                                                      .toString()
                                                      .split(' ')[0],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface),
                                                )),
                                              ],
                                            ),
                                            if (invoice.dueDate != null)
                                              () {
                                                final isOverdue =
                                                    InvoiceCalculator.isOverdue(
                                                  dueDate: invoice.dueDate,
                                                  outstanding: invoice
                                                      .outstandingBalance,
                                                );
                                                final color = isOverdue
                                                    ? CvSwatch.danger
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant;
                                                return ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 260),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.event_outlined,
                                                          size: 16,
                                                          color: color),
                                                      const SizedBox(width: 6),
                                                      Flexible(
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .dashboardDueDateLabel(
                                                                  AppFormatters
                                                                      .formatShortDate(
                                                                          invoice
                                                                              .dueDate)),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: color,
                                                            fontWeight:
                                                                isOverdue
                                                                    ? FontWeight
                                                                        .w600
                                                                    : FontWeight
                                                                        .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: CvSwatch.neutral
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${invoice.currencySymbol} ${AmountFormat.money(invoice.total)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: CvSwatch.neutral,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        alignment: WrapAlignment.end,
                                        children: [
                                          _buildActionButton(
                                              Icons.visibility_outlined,
                                              CvSwatch.success,
                                              AppLocalizations.of(context)!
                                                  .actionView,
                                              () => InvoicePdfServices
                                                  .showInvoiceDetails(
                                                      context, invoice)),
                                          _buildActionButton(
                                              Icons.edit_outlined,
                                              CvSwatch.neutral,
                                              AppLocalizations.of(context)!
                                                  .actionEdit,
                                              invoice.status == 'declined' ||
                                                      _isFinalNote(invoice)
                                                  ? null
                                                  : () => widget
                                                      .onEditInvoice(invoice)),
                                          _buildActionButton(
                                              Icons.copy_all_outlined,
                                              CvSwatch.success,
                                              AppLocalizations.of(context)!
                                                  .actionDuplicate,
                                              () => _showCloneDialog(invoice)),
                                          // Drafts: preview only, like the
                                          // invoice list.
                                          _buildActionButton(
                                              Icons.picture_as_pdf_outlined,
                                              CvSwatch.warning,
                                              AppLocalizations.of(context)!
                                                  .actionPdfPreview,
                                              () =>
                                                  InvoicePdfServices.previewPDF(
                                                      context, invoice)),
                                          if (!invoice.isDraft) ...[
                                          _buildActionButton(
                                              Icons.download_outlined,
                                              CvSwatch.neutral,
                                              AppLocalizations.of(context)!
                                                  .actionDownloadPdf,
                                              () => PDFService.downloadPDF(
                                                  context, invoice)),
                                          _buildActionButton(
                                              Icons.print_outlined,
                                              CvSwatch.neutral,
                                              AppLocalizations.of(context)!
                                                  .actionPrint,
                                              () => InvoicePdfServices
                                                  .generatePDF(
                                                      context, invoice)),
                                          ],
                                          _buildActionButton(
                                              Icons.payments_outlined,
                                              CvSwatch.neutral,
                                              AppLocalizations.of(context)!
                                                  .actionPayment,
                                              invoice.type == 'Invoice' &&
                                                      !invoice.isDraft &&
                                                      (invoice.status !=
                                                              'declined' ||
                                                          invoice.payments
                                                              .isNotEmpty)
                                                  ? () => showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (_) =>
                                                            ApplyPaymentDialog(
                                                          invoice: invoice,
                                                          onPaymentRecorded:
                                                              () {
                                                            if (!mounted) {
                                                              return;
                                                            }
                                                            setState(() {});
                                                          },
                                                        ),
                                                      )
                                                  : null),
                                          _buildActionButton(
                                              Icons.delete_outline,
                                              CvSwatch.danger,
                                              AppLocalizations.of(context)!
                                                  .actionDelete,
                                              widget.user.isAdmin()
                                                  ? () =>
                                                      _showDeleteDialog(invoice)
                                                  : null),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Only one tip at a time, so a new user isn't greeted by a wall of
  /// banners. The next one appears after this one is dismissed.
  Widget _buildOneDiscoveryBanner() {
    if (_showPurchaseBanner &&
        widget.user.isAdmin() &&
        !ref.watch(enablePurchaseBillsAndSuppliersProvider)) {
      return _buildPurchaseDiscoveryBanner();
    }
    if (_showShortcutsBanner) return _buildShortcutsDiscoveryBanner();
    if (_showLayoutBanner) return _buildLayoutDiscoveryBanner();
    if (_showSupportBanner) return _buildSupportBanner();
    return const SizedBox.shrink();
  }

  Widget _buildQuickActions() {
    final cb = widget.onQuickAction;
    if (cb == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final tiles = <(IconData, String, String?, DashboardAction)>[
      (Icons.receipt_long_rounded, l10n.quickActionNewInvoice, 'Ctrl+Q', DashboardAction.newInvoice),
      (Icons.request_quote_outlined, l10n.quickActionNewQuotation, null, DashboardAction.newQuotation),
      (Icons.payments_outlined, l10n.quickActionNewReceipt, null, DashboardAction.newReceipt),
      (Icons.folder_open_rounded, l10n.quickActionInvoices, null, DashboardAction.invoices),
      (Icons.person_add_alt_1_outlined, l10n.quickActionCustomers, null, DashboardAction.customers),
      (Icons.inventory_2_outlined, l10n.quickActionProducts, null, DashboardAction.products),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: LayoutBuilder(builder: (context, c) {
        final perRow = c.maxWidth >= 900 ? 6 : (c.maxWidth >= 560 ? 3 : 2);
        final w = (c.maxWidth - (perRow - 1) * 12) / perRow;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final t in tiles)
              SizedBox(
                width: w,
                child: _QuickActionTile(
                  icon: t.$1,
                  label: t.$2,
                  shortcut: t.$3,
                  primary: t.$4 == DashboardAction.newInvoice,
                  onTap: () => cb(t.$4),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        gradient: DashboardScreenColors.welcomePanelBackgroundGradientColor,
        borderRadius: BorderRadius.circular(CvRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .dashboardWelcomeBackMessage(widget.user.username),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.dashboardBusinessGlanceSubtitle,
                style: TextStyle(
                    fontSize: 13, color: Colors.white.withValues(alpha: 0.72)),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE').format(DateTime.now()),
                style: TextStyle(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.72)),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueSoonSection() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: CvSwatch.warning,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.notifications_active_outlined,
                color: CvSwatch.warning, size: 22),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.dashboardDueSoonTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CvSwatch.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CvSwatch.warning.withValues(alpha: 0.4)),
              ),
              child: Text(
                AppLocalizations.of(context)!
                    .dashboardInvoiceCountLabel(dueSoonInvoices.length),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CvSwatch.warning),
              ),
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.dashboardTodayTomorrowLabel,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Cards
        ...dueSoonInvoices.map((invoice) {
          final due = DateTime(invoice.dueDate!.year, invoice.dueDate!.month,
              invoice.dueDate!.day);
          final isToday = due == today;
          final badgeColor = isToday ? CvSwatch.danger : CvSwatch.warning;
          final badgeLabel = isToday
              ? AppLocalizations.of(context)!.dashboardDueTodayBadge
              : AppLocalizations.of(context)!.dashboardDueTomorrowBadge;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xsmall),
                side: BorderSide(
                    color: badgeColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Due badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: badgeColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Invoice ID
                    Text(
                      '#${invoice.invoiceNumber ?? invoice.id}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    // Customer
                    Icon(Icons.person_outline,
                        size: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              invoice.customer.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          CustomerInfoButton(customer: invoice.customer),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Outstanding amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_currencySymbol ${AmountFormat.money(invoice.outstandingBalance)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: badgeColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Actions
                    _buildActionButton(
                        Icons.visibility_outlined,
                        CvSwatch.success,
                        AppLocalizations.of(context)!.actionView,
                        () => InvoicePdfServices.showInvoiceDetails(
                            context, invoice)),
                    const SizedBox(width: 6),
                    _buildActionButton(
                        Icons.picture_as_pdf_outlined,
                        CvSwatch.warning,
                        AppLocalizations.of(context)!.actionPdfPreview,
                        () => InvoicePdfServices.previewPDF(context, invoice)),
                    const SizedBox(width: 6),
                    _buildActionButton(
                        Icons.payments_outlined,
                        CvSwatch.neutral,
                        AppLocalizations.of(context)!.actionRecordPayment,
                        () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => ApplyPaymentDialog(
                                invoice: invoice,
                                onPaymentRecorded: _loadDashboardData,
                              ),
                            )),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOverdueSection() {
    final today = InvoiceCalculator.dateOnly(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: CvSwatch.danger,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.warning_amber_rounded, color: CvSwatch.danger, size: 22),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.dashboardOverdueSectionTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CvSwatch.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CvSwatch.danger.withValues(alpha: 0.4)),
              ),
              child: Text(
                AppLocalizations.of(context)!
                    .dashboardInvoiceCountLabel(overdueInvoices.length),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CvSwatch.danger),
              ),
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.dashboardOldestFirstLabel,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...overdueInvoices.map((invoice) {
          final daysOverdue = InvoiceCalculator.daysOverdue(
            dueDate: invoice.dueDate,
            asOf: today,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.xsmall),
                side: BorderSide(
                    color: CvSwatch.danger.withValues(alpha: 0.3), width: 1),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Days overdue badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CvSwatch.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: CvSwatch.danger.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .dashboardDaysOverdueLabel(daysOverdue),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CvSwatch.danger),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Invoice ID
                    Text(
                      '#${invoice.invoiceNumber ?? invoice.id}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    // Customer
                    Icon(Icons.person_outline,
                        size: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              invoice.customer.name,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          CustomerInfoButton(customer: invoice.customer),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Outstanding amount
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CvSwatch.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$_currencySymbol ${AmountFormat.money(invoice.outstandingBalance)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CvSwatch.danger),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Actions
                    _buildActionButton(
                        Icons.visibility_outlined,
                        CvSwatch.success,
                        AppLocalizations.of(context)!.actionView,
                        () => InvoicePdfServices.showInvoiceDetails(
                            context, invoice)),
                    const SizedBox(width: 6),
                    _buildActionButton(
                        Icons.picture_as_pdf_outlined,
                        CvSwatch.warning,
                        AppLocalizations.of(context)!.actionPdfPreview,
                        () => InvoicePdfServices.previewPDF(context, invoice)),
                    const SizedBox(width: 6),
                    _buildActionButton(
                      Icons.payments_outlined,
                      CvSwatch.neutral,
                      AppLocalizations.of(context)!.actionRecordPayment,
                      () => showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => ApplyPaymentDialog(
                          invoice: invoice,
                          onPaymentRecorded: _loadDashboardData,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showUpdateStockDialog(Product product) async {
    final controller = TextEditingController(text: product.stock.toString());
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.inventory_2, color: CvSwatch.danger, size: 20),
            const SizedBox(width: 8),
            Flexible(
                child: Text(product.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.dashboardNewStockQuantityLabel,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.add_box_outlined),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              final qty = int.tryParse(controller.text.trim());
              if (qty == null || qty < 0) return;
              await ref
                  .read(productRepositoryProvider)
                  .updateProductStock(product.id, qty);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadDashboardData();
            },
            child: Text(l10n.actionUpdate),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  // [low]: the same alert for in-stock items at/below their low-stock limit.
  Widget _buildOutOfStockSection({bool low = false}) {
    final products = low ? lowStockProducts : outOfStockProducts;
    final Color alert = low ? CvSwatch.warning : CvSwatch.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: alert,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.inventory_2, color: alert, size: 22),
            const SizedBox(width: 8),
            Text(
              low
                  ? AppLocalizations.of(context)!.productMgmtLowStockTabLabel
                  : AppLocalizations.of(context)!.dashboardOutOfStockSectionTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: alert.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: alert.withValues(alpha: 0.4)),
              ),
              child: Text(
                AppLocalizations.of(context)!
                    .dashboardItemCountLabel(products.length),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: alert),
              ),
            ),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.dashboardTapToRestockLabel,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...products.map((product) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xsmall),
                  side: BorderSide(
                      color: alert.withValues(alpha: 0.3), width: 1),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: alert.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2,
                            color: alert, size: 20),
                      ),
                      const SizedBox(width: 16),
                      // Name & type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.type == 'service'
                                  ? AppLocalizations.of(context)!.labelService
                                  : AppLocalizations.of(context)!.labelProduct,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Price
                      Text(
                        '$_currencySymbol${AmountFormat.money(product.price)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(width: 16),
                      // Stock badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: alert.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: alert.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!
                              .dashboardStockLabel(product.stock),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: alert),
                        ),
                      ),
                      if (!_stockLocked) ...[
                      const SizedBox(width: 12),
                      // Update stock button
                      _buildActionButton(
                        Icons.add_box_outlined,
                        CvSwatch.success,
                        AppLocalizations.of(context)!.actionUpdateStock,
                        () => _showUpdateStockDialog(product),
                      ),
                      ],
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  /// One stat-tile style across the app: card surface with a hairline
  /// border (like every card), a neutral icon badge — status is carried by the
  /// warning line, not by a decorative icon colour — and the value in the
  /// brand display face. [color] is kept for callers but no longer tints.
  Widget _buildStatCard(String title, String value, Color color, IconData icon,
      {String? subtitle, Color? subtitleColor}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(CvSpace.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(CvRadius.md),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(CvRadius.sm + 2),
              ),
              child: Icon(icon, color: scheme.onSurface, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (subtitle?.isNotEmpty ?? false) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.warning_amber_rounded,
                            size: 11, color: subtitleColor ?? CvSwatch.danger),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                color: subtitleColor ?? CvSwatch.danger,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18, color: scheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, String tooltip, VoidCallback? onPressed) {
    final effectiveColor = onPressed != null
        ? color
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveColor.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: effectiveColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus status) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    switch (status) {
      case PaymentStatus.paid:
        color = CvSwatch.success;
        label = l10n.paymentStatusPaid;
      case PaymentStatus.partial:
        color = CvSwatch.warning;
        label = l10n.paymentStatusPartial;
      case PaymentStatus.unpaid:
        color = CvSwatch.danger;
        label = l10n.paymentStatusUnpaid;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Future<void> _showCloneDialog(Invoice invoice) async {
    final l10n = AppLocalizations.of(context)!;
    final type = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.copy_all, color: CvSwatch.success),
            const SizedBox(width: 12),
            Text(l10n.dashboardDuplicateInvoiceTitle),
          ],
        ),
        content: Text(
          l10n.dashboardDuplicateInvoiceBody(
              invoice.invoiceNumber ?? invoice.id, invoice.customer.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(ctx, 'Quotation'),
            icon: const Icon(Icons.request_quote_outlined),
            label: Text(l10n.labelQuotation),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, 'Invoice'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.receipt),
            label: Text(l10n.labelInvoice),
          ),
        ],
      ),
    );
    if (type != null) {
      widget.onCloneInvoice(invoice, type);
    }
  }

  void _showDeleteDialog(Invoice invoice) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: CvSwatch.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.warning_amber_rounded, color: CvSwatch.danger),
            ),
            const SizedBox(width: 12),
            Text(l10n.dashboardDeleteInvoiceTitle),
          ],
        ),
        content: Text(
          l10n.dashboardDeleteInvoiceBody(invoice.invoiceNumber ?? invoice.id),
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.actionCancel,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              InvoicePdfServices.deleteInvoice(context, invoice);
              _loadDashboardData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CvSwatch.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
  }

  // ── Layout Toggle ───────────────────────────────────────────────────────────

  Widget _buildLayoutToggle() {
    return PopupMenuButton<String>(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.dashboard_customize_outlined, size: 20),
          if (_showLayoutBanner)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CvSwatch.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      tooltip: AppLocalizations.of(context)!.dashboardLayoutTooltip,
      offset: const Offset(0, 40),
      onSelected: (value) async {
        if (!mounted) return;
        await ref
            .read(settingsRepositoryProvider)
            .setSetting(SettingKey.dashboardLayout, value);
        setState(() => _dashboardLayout = value);
        if (_showLayoutBanner) _dismissLayoutBanner();
      },
      itemBuilder: (ctx) {
        final l10n = AppLocalizations.of(context)!;
        return [
          _layoutMenuItem(
              'default',
              Icons.view_agenda_outlined,
              l10n.dashboardLayoutDefaultTitle,
              l10n.dashboardLayoutDefaultSubtitle),
          _layoutMenuItem('classic', Icons.grid_view_outlined,
              l10n.dashboardLayoutClassic, l10n.dashboardLayoutClassicSubtitle),
          _layoutMenuItem(
              'bento',
              Icons.auto_awesome_mosaic_outlined,
              l10n.dashboardLayoutBentoTitle,
              l10n.dashboardLayoutBentoSubtitle),
          _layoutMenuItem(
              'simple',
              Icons.view_list_outlined,
              l10n.dashboardLayoutSimpleTitle,
              l10n.dashboardLayoutSimpleSubtitle),
        ];
      },
    );
  }

  PopupMenuItem<String> _layoutMenuItem(
      String value, IconData icon, String title, String sub) {
    final active = _dashboardLayout == value;
    final primary = Theme.of(context).primaryColor;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: active
                  ? primary
                  : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal,
                        color: active
                            ? primary
                            : Theme.of(context).colorScheme.onSurface)),
                Text(sub,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (active) Icon(Icons.check_rounded, size: 16, color: primary),
        ],
      ),
    );
  }

  // ── Layout: Classic ─────────────────────────────────────────────────────────

  Widget _buildClassicLayout() {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxWidthNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOneDiscoveryBanner(),
              _buildGreetingBanner(),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // KPI row
              Row(
                children: [
                  _buildKpiCard(
                      AppLocalizations.of(context)!
                          .dashboardRevenueCollectedLabel,
                      '$_currencySymbol ${_fmtAmt(totalRevenue)}',
                      Icons.account_balance_wallet_outlined,
                      CvSwatch.neutral),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.dashboardOutstandingLabel,
                      '$_currencySymbol ${_fmtAmt(totalOutstanding)}',
                      Icons.hourglass_top_outlined,
                      CvSwatch.danger),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.dashboardTotalInvoicesLabel,
                      totalInvoices.toString(),
                      Icons.receipt_long_outlined,
                      CvSwatch.warning),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.navCustomers,
                      totalCustomers.toString(),
                      Icons.people_outline,
                      CvSwatch.neutral),
                  const SizedBox(width: 10),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.navProducts,
                      totalProducts.toString(),
                      Icons.inventory_2_outlined,
                      CvSwatch.success),
                ],
              ),
              const SizedBox(height: 20),
              // Charts row
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _buildRevenueBarChart(primary)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildRevenueDonut()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Bottom row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3, child: _buildCompactRecentInvoices(limit: 7)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        if (dueSoonInvoices.isNotEmpty) ...[
                          _buildDueSoonCard(),
                          const SizedBox(height: 14),
                        ],
                        if (overdueInvoices.isNotEmpty) ...[
                          _buildOverdueCompactCard(),
                          const SizedBox(height: 14),
                        ],
                        if (outOfStockProducts.isNotEmpty) ...[
                          _buildOutOfStockCard(),
                          const SizedBox(height: 14),
                        ],
                        if (lowStockProducts.isNotEmpty) ...[
                          _buildOutOfStockCard(low: true),
                          const SizedBox(height: 14),
                        ],
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Layout: Simple Feed ─────────────────────────────────────────────────────

  Widget _buildSimpleFeedLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxWidthNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOneDiscoveryBanner(),
              _buildGreetingBanner(),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // Mini KPI strip
              Row(
                children: [
                  _buildKpiCard(
                      AppLocalizations.of(context)!
                          .dashboardRevenueCollectedLabel,
                      '$_currencySymbol ${_fmtAmt(totalRevenue)}',
                      Icons.account_balance_wallet_outlined,
                      CvSwatch.neutral),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.dashboardOutstandingLabel,
                      '$_currencySymbol ${_fmtAmt(totalOutstanding)}',
                      Icons.hourglass_top_outlined,
                      CvSwatch.danger),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.navInvoices,
                      totalInvoices.toString(),
                      Icons.receipt_long_outlined,
                      CvSwatch.warning),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.navCustomers,
                      totalCustomers.toString(),
                      Icons.people_outline,
                      CvSwatch.neutral),
                  const SizedBox(width: 12),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.navProducts,
                    totalProducts.toString(),
                    Icons.inventory_2_outlined,
                    CvSwatch.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Two-column body
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: recent invoices + top customers + top products
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildCompactRecentInvoices(limit: 10),
                        if (_topCustomers.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildTopCustomersCard(),
                        ],
                        if (_topProducts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildTopProductsCard(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right sidebar
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildQuickActionsCard(),
                        const SizedBox(height: 14),
                        if (overdueInvoices.isNotEmpty) ...[
                          _buildOverdueCompactCard(),
                          const SizedBox(height: 14),
                        ],
                        if (dueSoonInvoices.isNotEmpty) ...[
                          _buildDueSoonCard(),
                          const SizedBox(height: 14),
                        ],
                        if (outOfStockProducts.isNotEmpty)
                          _buildOutOfStockCard(),
                        if (lowStockProducts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildOutOfStockCard(low: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared: KPI Card ────────────────────────────────────────────────────────

  Widget _buildKpiCard(String title, String value, IconData icon, Color color,
      {bool alert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: alert
              ? Border.all(color: color.withValues(alpha: 0.35), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared: Revenue Bar Chart ────────────────────────────────────────────────

  Widget _buildRevenueBarChart(Color primary) {
    final hasData = _monthlyRevenue.isNotEmpty;
    final maxY = hasData
        ? _monthlyRevenue
                .map((e) => (e['revenue'] as num).toDouble())
                .reduce((a, b) => a > b ? a : b) *
            1.25
        : 1000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.dashboardRevenueLast6MonthsTitle,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: hasData
                ? BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barGroups: _monthlyRevenue.asMap().entries.map((entry) {
                        final rev = (entry.value['revenue'] as num).toDouble();
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: rev,
                              gradient: LinearGradient(
                                colors: [
                                  primary,
                                  primary.withValues(alpha: 0.55)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= _monthlyRevenue.length) {
                                return const SizedBox.shrink();
                              }
                              final monthStr =
                                  _monthlyRevenue[idx]['month'] as String;
                              try {
                                final date =
                                    DateFormat('yyyy-MM').parse(monthStr);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(DateFormat('MMM').format(date),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                );
                              } catch (_) {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.12),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                            '$_currencySymbol ${_fmtAmt(rod.toY)}',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_outlined,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.outlineVariant),
                        const SizedBox(height: 8),
                        Text(
                            AppLocalizations.of(context)!
                                .dashboardNoPaymentDataYetLabel,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 13)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Shared: Revenue Donut ────────────────────────────────────────────────────

  Widget _buildRevenueDonut() {
    final total = totalRevenue + totalOutstanding;
    final hasData = total > 0.01;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.dashboardFinancialOverviewTitle,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: hasData
                ? PieChart(
                    PieChartData(
                      centerSpaceRadius: 46,
                      sectionsSpace: 3,
                      sections: [
                        PieChartSectionData(
                          value: totalRevenue,
                          color: CvSwatch.success,
                          title: '',
                          radius: 38,
                        ),
                        PieChartSectionData(
                          value: totalOutstanding,
                          color: CvSwatch.danger,
                          title: '',
                          radius: 38,
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                        AppLocalizations.of(context)!
                            .dashboardNoInvoicesYetTitle,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13))),
          ),
          const SizedBox(height: 14),
          _buildDonutLegend(
              AppLocalizations.of(context)!.dashboardCollectedLabel,
              CvSwatch.success,
              '$_currencySymbol ${_fmtAmt(totalRevenue)}'),
          const SizedBox(height: 6),
          _buildDonutLegend(
              AppLocalizations.of(context)!.dashboardOutstandingLabel,
              CvSwatch.danger,
              '$_currencySymbol ${_fmtAmt(totalOutstanding)}'),
          if (overdueInvoices.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CvSwatch.danger.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 13, color: CvSwatch.danger),
                  const SizedBox(width: 6),
                  Text(
                      AppLocalizations.of(context)!
                          .dashboardInvoiceCountOverdueLabel(
                              overdueInvoices.length),
                      style: const TextStyle(
                          fontSize: 12,
                          color: CvSwatch.danger,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDonutLegend(String label, Color color, String amount) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant))),
        Text(amount,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  // ── Shared: Compact Recent Invoices ─────────────────────────────────────────

  Widget _buildCompactRecentInvoices({int limit = 7}) {
    final invoices = recentInvoices.take(limit).toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context)!.dashboardRecentInvoicesTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Text(AppLocalizations.of(context)!.dashboardLastNLabel(limit),
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 4),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                        AppLocalizations.of(context)!.dashboardColDocumentNo,
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text(AppLocalizations.of(context)!.dashboardColType,
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 3,
                    child: Text(AppLocalizations.of(context)!.labelCustomer,
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 3,
                    child: Text(AppLocalizations.of(context)!.labelAmount,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600))),
                const SizedBox(width: 60),
              ],
            ),
          ),
          Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 4),
          if (invoices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                  child: Text(
                      AppLocalizations.of(context)!.dashboardNoInvoicesYetTitle,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13))),
            )
          else
            ...invoices.map(_buildCompactInvoiceRow),
        ],
      ),
    );
  }

  Widget _buildCompactInvoiceRow(Invoice inv) {
    final status = inv.paymentStatus;
    final Color statusColor;
    final String statusLabel;
    final l10n = AppLocalizations.of(context)!;
    if (inv.status == 'declined') {
      statusColor = CvSwatch.danger;
      statusLabel = l10n.invoiceStatusDeclinedBadge;
    } else {
      switch (status) {
        case PaymentStatus.paid:
          statusColor = CvSwatch.success;
          statusLabel = l10n.paymentStatusPaid;
          break;
        case PaymentStatus.partial:
          statusColor = CvSwatch.warning;
          statusLabel = l10n.paymentStatusPartial;
          break;
        default:
          final isOver = InvoiceCalculator.isOverdue(
              dueDate: inv.dueDate, outstanding: inv.outstandingBalance);
          statusColor =
              isOver ? CvSwatch.danger : CvSwatch.neutral;
          statusLabel = isOver
              ? l10n.dashboardOverdueSectionTitle
              : l10n.paymentStatusUnpaid;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
                inv.isDraft
                    ? AppLocalizations.of(context)!.invoiceDraftBadge
                    : '#${inv.invoiceNumber ?? inv.id}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(_invoiceTypeLabel(context, inv.type),
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Text(inv.customer.name,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Text('$_currencySymbol ${_fmtAmt(inv.total)}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
                maxLines: 1),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Text(statusLabel,
                style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          if (inv.status != 'declined' && !_isFinalNote(inv)) ...[
            Tooltip(
              message: 'Edit',
              child: InkWell(
                onTap: () => widget.onEditInvoice(inv),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined,
                      size: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],
          // Drafts have no number yet — no PDF, like the invoice list.
          if (!inv.isDraft)
          Tooltip(
            message: 'Download PDF',
            child: InkWell(
              onTap: () => PDFService.downloadPDF(context, inv),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.download_outlined,
                    size: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared: Due Soon Card ────────────────────────────────────────────────────

  Widget _buildDueSoonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: CvSwatch.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.event_outlined,
                    color: CvSwatch.warning, size: 15),
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.dashboardDueSoonTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: CvSwatch.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${dueSoonInvoices.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: CvSwatch.warning,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...dueSoonInvoices.take(5).map((inv) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(inv.customer.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Text('$_currencySymbol ${_fmtAmt(inv.outstandingBalance)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 2),
                    _buildInvoiceActionMenu(inv),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Shared: Out of Stock Card ────────────────────────────────────────────────

  // [low]: see _buildOutOfStockSection.
  Widget _buildOutOfStockCard({bool low = false}) {
    final products = low ? lowStockProducts : outOfStockProducts;
    final Color alert = low ? CvSwatch.warning : CvSwatch.danger;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert.withValues(alpha: 0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: alert.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.inventory_2_outlined,
                    color: alert, size: 15),
              ),
              const SizedBox(width: 8),
              Text(
                  low
                      ? AppLocalizations.of(context)!.productMgmtLowStockTabLabel
                      : AppLocalizations.of(context)!.dashboardOutOfStockSectionTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: alert.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${products.length}',
                    style: TextStyle(
                        fontSize: 12,
                        color: alert,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...products.take(5).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(p.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Text(
                        low
                            ? AppLocalizations.of(context)!
                                .dashboardStockLabel(p.stock)
                            : AppLocalizations.of(context)!.dashboardZeroLeftLabel,
                        style: TextStyle(
                            fontSize: 12,
                            color: alert,
                            fontWeight: FontWeight.w600)),
                    if (!_stockLocked) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: AppLocalizations.of(context)!.actionUpdateStock,
                      child: InkWell(
                        onTap: () => _showUpdateStockDialog(p),
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: CvSwatch.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_box_outlined,
                                  size: 13, color: CvSwatch.success),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.labelStock,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: CvSwatch.success,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Shared: Overdue Compact Card ─────────────────────────────────────────────

  Widget _buildOverdueCompactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: CvSwatch.danger.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: CvSwatch.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.warning_amber_rounded,
                    color: CvSwatch.danger, size: 15),
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.dashboardOverdueSectionTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: CvSwatch.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${overdueInvoices.length}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: CvSwatch.danger,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...overdueInvoices.take(5).map((inv) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(inv.customer.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Text('$_currencySymbol ${_fmtAmt(inv.outstandingBalance)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: CvSwatch.danger,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Tooltip(
                      message:
                          AppLocalizations.of(context)!.actionRecordPayment,
                      child: InkWell(
                        onTap: () => showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => ApplyPaymentDialog(
                            invoice: inv,
                            onPaymentRecorded: _loadDashboardData,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                                CvSwatch.neutral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payments_outlined,
                                  size: 13, color: CvSwatch.neutral),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.actionPay,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: CvSwatch.neutral,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    _buildPdfActionMenu(inv),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Shared: Quick Actions Card ───────────────────────────────────────────────

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppLocalizations.of(context)!.dashboardQuickActionsTitle,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          _buildQuickActionRow(
              Icons.add_circle_outline_rounded,
              AppLocalizations.of(context)!.navNewInvoice,
              Theme.of(context).primaryColor, () {
            if (!mounted) return;
            context
                .findAncestorStateOfType<_DashboardScreenState>()
                ?.setState(() {
              context
                  .findAncestorStateOfType<_DashboardScreenState>()
                  ?._selectedIndex = 1;
            });
          }),
          const SizedBox(height: 4),
          _buildQuickActionRow(
              Icons.person_add_outlined,
              AppLocalizations.of(context)!.navCustomers,
              CvSwatch.neutral, () {
            if (!mounted) return;
            context
                .findAncestorStateOfType<_DashboardScreenState>()
                ?.setState(() {
              context
                  .findAncestorStateOfType<_DashboardScreenState>()
                  ?._selectedIndex = 5;
            });
          }),
          if (context
                  .findAncestorStateOfType<_DashboardScreenState>()
                  ?._reportsLocked !=
              true) ...[
          const SizedBox(height: 4),
          _buildQuickActionRow(
              Icons.bar_chart_outlined,
              AppLocalizations.of(context)!.navReports,
              CvSwatch.success, () {
            if (!mounted) return;
            context
                .findAncestorStateOfType<_DashboardScreenState>()
                ?.setState(() {
              context
                  .findAncestorStateOfType<_DashboardScreenState>()
                  ?._selectedIndex = 7;
            });
          }),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionRow(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ── Shared: Amount Formatter ─────────────────────────────────────────────────

  String _fmtAmt(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    }
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return AmountFormat.money(amount);
  }

  // ── Layout: Bento Grid ──────────────────────────────────────────────────────

  Widget _buildBentoLayout() {
    final primary = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxWidthNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOneDiscoveryBanner(),
              _buildGreetingBanner(),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // ── Top row: Hero chart + 2×2 KPI grid ──────────────────────────
              SizedBox(
                height: 290,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero: Revenue bar chart
                    Expanded(
                      flex: 3,
                      child: _buildRevenueBarChart(primary),
                    ),
                    const SizedBox(width: 14),
                    // 2×2 KPI tiles
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _buildKpiCard(
                                  AppLocalizations.of(context)!
                                      .dashboardRevenueCollectedLabel,
                                  '$_currencySymbol ${_fmtAmt(totalRevenue)}',
                                  Icons.account_balance_wallet_outlined,
                                  CvSwatch.neutral,
                                ),
                                const SizedBox(width: 14),
                                _buildKpiCard(
                                  AppLocalizations.of(context)!.navInvoices,
                                  totalInvoices.toString(),
                                  Icons.receipt_long_outlined,
                                  CvSwatch.warning,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                _buildKpiCard(
                                  AppLocalizations.of(context)!
                                      .dashboardOutstandingLabel,
                                  '$_currencySymbol ${_fmtAmt(totalOutstanding)}',
                                  Icons.hourglass_top_outlined,
                                  CvSwatch.danger,
                                ),
                                const SizedBox(width: 14),
                                _buildKpiCard(
                                  AppLocalizations.of(context)!
                                      .dashboardOverdueSectionTitle,
                                  overdueInvoices.length.toString(),
                                  Icons.warning_amber_outlined,
                                  CvSwatch.danger,
                                  alert: overdueInvoices.isNotEmpty,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                _buildKpiCard(
                                    AppLocalizations.of(context)!.navCustomers,
                                    totalCustomers.toString(),
                                    Icons.people_outline,
                                    CvSwatch.neutral),
                                const SizedBox(width: 14),
                                _buildKpiCard(
                                  AppLocalizations.of(context)!.navProducts,
                                  totalProducts.toString(),
                                  Icons.inventory_2_outlined,
                                  CvSwatch.success,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ── Bottom row: Wide invoice table + narrow sidebar ───────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildCompactRecentInvoices(limit: 8),
                        if (_topProducts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildTopProductsCard(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildQuickActionsCard(),
                        if (overdueInvoices.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildOverdueCompactCard(),
                        ],
                        if (dueSoonInvoices.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildDueSoonCard(),
                        ],
                        if (outOfStockProducts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildOutOfStockCard(),
                        ],
                        if (lowStockProducts.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildOutOfStockCard(low: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared: PDF-Only Action Menu (⋯) ───────────────────────────────────────

  Widget _buildPdfActionMenu(Invoice inv) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
      iconSize: 22,
      padding: EdgeInsets.zero,
      tooltip: AppLocalizations.of(context)!.dashboardPdfActionsTooltip,
      offset: const Offset(0, 24),
      onSelected: (value) {
        if (value == 'preview') {
          InvoicePdfServices.previewPDF(context, inv);
        } else if (value == 'download') {
          PDFService.downloadPDF(context, inv);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'preview',
          child: Row(children: [
            const Icon(Icons.visibility_outlined,
                size: 16, color: CvSwatch.success),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.actionPdfPreview,
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
        PopupMenuItem(
          value: 'download',
          child: Row(children: [
            const Icon(Icons.download_outlined,
                size: 16, color: CvSwatch.neutral),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.actionDownloadPdf,
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
      ],
    );
  }

  // ── Shared: Invoice Action Menu (⋯) ────────────────────────────────────────

  Widget _buildInvoiceActionMenu(Invoice inv) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          size: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
      iconSize: 22,
      padding: EdgeInsets.zero,
      tooltip: AppLocalizations.of(context)!.dashboardActionsTooltip,
      offset: const Offset(0, 24),
      onSelected: (value) {
        switch (value) {
          case 'payment':
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => ApplyPaymentDialog(
                invoice: inv,
                onPaymentRecorded: _loadDashboardData,
              ),
            );
            break;
          case 'preview':
            InvoicePdfServices.previewPDF(context, inv);
            break;
          case 'download':
            PDFService.downloadPDF(context, inv);
            break;
        }
      },
      itemBuilder: (ctx) => [
        if (inv.status != 'declined')
          PopupMenuItem(
            value: 'payment',
            child: Row(children: [
              const Icon(Icons.payments_outlined,
                  size: 16, color: CvSwatch.neutral),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.actionRecordPayment,
                  style: const TextStyle(fontSize: 13)),
            ]),
          ),
        PopupMenuItem(
          value: 'preview',
          child: Row(children: [
            const Icon(Icons.visibility_outlined,
                size: 16, color: CvSwatch.success),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.actionPdfPreview,
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
        PopupMenuItem(
          value: 'download',
          child: Row(children: [
            const Icon(Icons.download_outlined,
                size: 16, color: CvSwatch.neutral),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.actionDownloadPdf,
                style: const TextStyle(fontSize: 13)),
          ]),
        ),
      ],
    );
  }

  // ── Shared: Top Customers Card ───────────────────────────────────────────────

  Widget _buildTopCustomersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: CvSwatch.neutral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.emoji_events_outlined,
                    color: CvSwatch.neutral, size: 15),
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.dashboardTopCustomersTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          ..._topCustomers.map((c) {
            final name = c['customer_name'] as String? ?? '';
            final paid = (c['total_paid'] as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor:
                        CvSwatch.neutral.withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 11,
                          color: CvSwatch.neutral,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  Text('$_currencySymbol ${_fmtAmt(paid)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Shared: Top Products Card ────────────────────────────────────────────────

  Widget _buildTopProductsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: CvSwatch.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.trending_up_outlined,
                    color: CvSwatch.success, size: 15),
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.dashboardTopProductsTitle,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          ..._topProducts.map((p) {
            final name = p['product_name'] as String? ?? '';
            final qty = (p['total_qty'] as num).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: CvSwatch.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.inventory_2_outlined,
                        size: 13, color: CvSwatch.success),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                  Text(
                      AppLocalizations.of(context)!.dashboardUnitsLabel(
                          qty % 1 == 0
                              ? qty.toInt().toString()
                              : qty.toStringAsFixed(1)),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// One big, easy-to-hit dashboard shortcut (icon over label).
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? shortcut;
  final bool primary;
  final VoidCallback onTap;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.shortcut,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = primary ? scheme.primary : scheme.surfaceContainer;
    final fg = primary ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      button: true,
      label: shortcut == null ? label : '$label, $shortcut',
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CvRadius.md),
          side: primary ? BorderSide.none : BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30, color: primary ? fg : scheme.primary),
                  const SizedBox(height: 8),
                  Text(label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
                  if (shortcut != null) ...[
                    const SizedBox(height: 2),
                    Text(shortcut!,
                        style: TextStyle(color: fg.withValues(alpha: 0.75), fontSize: 11)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
