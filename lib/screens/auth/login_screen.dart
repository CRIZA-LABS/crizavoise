import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/common/constants.dart';
import 'package:crizavoise/common/setting_key.dart';
import 'package:crizavoise/database/company_registry_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/company_profile.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/providers/locale_provider.dart';
import 'package:crizavoise/providers/purchase_bills_settings_provider.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/providers/theme_provider.dart';
import 'package:crizavoise/screens/auth/forgot_password_screen.dart';
import 'package:crizavoise/screens/auth/create_account_screen.dart';
import 'package:crizavoise/screens/auth/change_password_screen.dart';
import 'package:crizavoise/screens/help/help_search_screen.dart';
import 'package:crizavoise/screens/legal/legal_document_screen.dart';
import 'package:crizavoise/screens/settings/company_management_screen.dart';
import 'package:crizavoise/screens/test_gate_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crizavoise/theme/brand_assets.dart';

import 'package:crizavoise/providers/app_config_provider.dart';
import 'package:crizavoise/utils/post_auth_navigation.dart';
import 'package:crizavoise/utils/window_title.dart';

// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  /// Built-in admin/admin account still unclaimed: show "Create your account".
  User? _defaultAdmin;
  bool _autoOpenedSetup = false;
  List<CompanyProfile> _companies = [];
  String? _activeCompanyId;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _checkFirstTimeUser();
  }

  Future<void> _loadCompanies() async {
    final companies = await CompanyRegistryService.listCompanies();
    final activeId = await CompanyRegistryService.getActiveCompanyId();
    if (!mounted) return;
    setState(() {
      _companies = companies;
      _activeCompanyId = activeId;
    });
  }

  /// Nothing has read per-company data yet at the Login screen (see
  /// `CompanyManagementScreen`'s doc comment for the full reasoning), so
  /// switching here is instant — repoint the DB, re-sync the two providers
  /// loaded before this screen even rendered, and start the credential
  /// fields fresh for whichever company is now selected.
  Future<void> _onCompanySelected(String? id) async {
    if (id == null || id == _activeCompanyId) return;
    await CompanyRegistryService.switchToCompany(id);
    final themeKey = await ref.read(settingsRepositoryProvider).getThemeMode();
    final localeKey = await ref.read(settingsRepositoryProvider).getAppLocale();
    final purchaseBills = await ref
        .read(settingsRepositoryProvider)
        .getSetting(SettingKey.enablePurchaseBillsAndSuppliers);
    await refreshWindowTitle();
    if (!mounted) return;
    ref.read(themeModeProvider.notifier).state = themeModeFromKey(themeKey);
    applyAppLocale(ref, localeFromKey(localeKey));
    ref.read(enablePurchaseBillsAndSuppliersProvider.notifier).state =
        purchaseBills == 'true';
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _activeCompanyId = id;
      _defaultAdmin = null;
    });
    await _checkFirstTimeUser();
  }

  Future<void> _openCompanyManagement() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CompanyManagementScreen()),
    );
    if (!mounted) return;
    _usernameController.clear();
    _passwordController.clear();
    setState(() => _defaultAdmin = null);
    await _loadCompanies();
    await _checkFirstTimeUser();
  }

  // The built-in admin/admin account exists only to bootstrap a new company.
  // While it's unclaimed, offer "Create your account" instead of telling
  // anyone the default password. Cloud edition has no seeded account.
  Future<void> _checkFirstTimeUser() async {
    if (ref.read(appEditionConfigProvider).isCloud) return;
    final user =
        await ref.read(authRepositoryProvider).getUser('admin', 'admin');
    if (!mounted) return;
    setState(() => _defaultAdmin = user);
    if (user != null && !_autoOpenedSetup) {
      _autoOpenedSetup = true;
      _openCreateAccount();
    }
  }

  void _openCreateAccount() {
    final admin = _defaultAdmin;
    if (admin == null) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => CreateAccountScreen(defaultAdmin: admin)));
  }

  Widget _buildSetupCard() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.loginSetupTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.loginSetupBody,
              style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(l10n.createAccountTitle),
              onPressed: _openCreateAccount,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(AppEditionConfig cfg) async {

    // for cloud the username will be email
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final usernameText = cfg.isCloud ? "Email" : "Username";

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter $usernameText and password')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final user = await ref.read(authRepositoryProvider).getUser(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if(user == null)
    {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loginInvalidCredentials)),
      );
      return;
    }

    _afterLoginNavigate(cfg, user);
  }

  Future<void> _afterLoginNavigate(AppEditionConfig cfg, User user) async {
    if (TestBuildConfig.isTestBuild && !await _testGatePasses(cfg, user)) return;

    if(cfg.isCloud)
    {
      if (!mounted) return;
      await navigateAfterAuth(context, ref, user);
    }
    else if (!user.passwordChanged && !cfg.isCloud) {
      // Force password change
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(user: user, forced: true),
        ),
      );
    }
    else{
      if (!mounted) return;
      await navigateAfterAuth(context, ref, user);
    }

  }

  // Uses the Criza Labs website response Date header as a
  // trusted clock — local device time is spoofable and would defeat this gate.
  Future<bool> _testGatePasses(AppEditionConfig cfg, User user) async {
    DateTime serverTime;
    try {
      final resp = await http
          .head(Uri.parse(TestBuildConfig.clockUrl))
          .timeout(const Duration(seconds: 5));
      final dateHeader = resp.headers['date'];
      if (dateHeader == null) throw const HttpException('missing Date header');
      serverTime = HttpDate.parse(dateHeader);
    } catch (_) {
      if (!mounted) return false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestGateScreen(
            reason: TestGateReason.noInternet,
            onRetry: () => _afterLoginNavigate(cfg, user),
          ),
        ),
      );
      return false;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(TestBuildConfig.buildEpochSeconds * 1000)
        .add(const Duration(days: TestBuildConfig.testExpiryDays));
    if (serverTime.isAfter(expiry)) {
      if (!mounted) return false;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TestGateScreen(reason: TestGateReason.expired)),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(appEditionConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Phone: card fills the width (minus side padding) since there's no
    // room to spare. Tablet/desktop: a fixed comfortable width instead of
    // the old `width * 0.25`, which shrank to an unusably narrow card on
    // tablet portrait widths (e.g. ~190px at 768px wide).
    final isPhone = screenWidth < 600;
    final cardWidth = isPhone ? screenWidth - 48 : 420.0;
    final cardPadding = isPhone ? 20.0 : 32.0;
    final logoWidth = (cardWidth * 0.65).clamp(140.0, 230.0);
    return Scaffold(
      backgroundColor: null, // theme canvas: Paper (light) / Ink (dark)
      body: Stack(
        children: [
          SafeArea(
            child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Container(
                    width: cardWidth,
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          isDark
                              ? BrandAssets.lockupDark
                              : BrandAssets.lockupLight,
                          width: logoWidth,
                          height: 56,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          semanticLabel: AppConfig.name,
                        ),
                        AppSpacing.hSmall,
                        if (!cfg.isCloud && _defaultAdmin != null) ...[
                          _buildSetupCard(),
                          AppSpacing.hLarge,
                        ],
                        if (_companies.length > 1) ...[
                          DropdownButtonFormField<String>(
                            value: _activeCompanyId,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .loginCompanySelectorLabel,
                              prefixIcon: const Icon(Icons.corporate_fare),
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              for (final company in _companies)
                                DropdownMenuItem(
                                  value: company.id,
                                  child: Text(company.name),
                                ),
                            ],
                            onChanged: _onCompanySelected,
                          ),
                          AppSpacing.hMedium,
                        ],
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: cfg.isCloud ? 'Email' : 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: cfg.isCloud
                              ? TextInputType.emailAddress
                              : TextInputType.text,
                        ),
                        AppSpacing.hMedium,
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onSubmitted: (_) => _login(cfg),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        AppSpacing.hXlarge,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _login(cfg),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                        AppSpacing.hSmall,
                        if (!cfg.isCloud)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen()),
                              ),
                              child: Text(AppLocalizations.of(context)!.loginForgotPassword),
                            ),
                          ),
                        AppSpacing.hLarge,
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => launchUrl(Uri.parse(AppConfig.website),
                                mode: LaunchMode.externalApplication),
                            child: Text(
                              '${AppConfig.madeBy} · ${AppConfig.websiteLabel}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  textStyle: const TextStyle(fontSize: 12)),
                              onPressed: () => LegalDocumentScreen.open(context,
                                  title: AppLocalizations.of(context)!.termsOfUseTitle,
                                  asset: AppConfig.termsAsset),
                              child: Text(AppLocalizations.of(context)!.termsOfUseTitle),
                            ),
                            Text('·', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            TextButton(
                              style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 32),
                                  textStyle: const TextStyle(fontSize: 12)),
                              onPressed: () => LegalDocumentScreen.open(context,
                                  title: AppLocalizations.of(context)!.privacyPolicyTitle,
                                  asset: AppConfig.privacyAsset),
                              child: Text(AppLocalizations.of(context)!.privacyPolicyTitle),
                            ),
                          ],
                        ),
                        Text(
                          AppConfig.version,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => showHelpSearchDialog(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.support_agent_outlined,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Need help? Contact Support',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
          if (!cfg.isCloud)
            Positioned(
              right: 16,
              bottom: 16,
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.loginCompanyGearTooltip,
                icon: const Icon(Icons.settings),
                onPressed: _openCompanyManagement,
              ),
            ),
        ],
      ),
    );
  }
}
