import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/database/recovery_code_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/screens/auth/auth_layout.dart';
import 'package:crizavoise/screens/auth/recovery_code_screen.dart';
import 'package:crizavoise/services/backend_services.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/utils/contact_links.dart';
import 'package:crizavoise/utils/reset_code_verifier.dart';

enum _Step { choose, recoveryCode, supportCode, newPassword }

/// Forgot password, fully offline. Two ways back in:
/// 1. the person's own recovery code (shown when the account was created);
/// 2. a one-time code from Criza Labs support, tied to this installation.
/// Either way they then choose a new password and get a fresh recovery code.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  _Step _step = _Step.choose;
  final _username = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();

  String? _installationId;
  String? _companyName;
  String? _userId;
  String? _verifiedUsername;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = await BackendServices.installation.getOrCreateInstallationId();
    final info = await ref.read(companyInfoRepositoryProvider).getCompanyInfo();
    if (!mounted) return;
    setState(() {
      _installationId = id;
      _companyName = info?.name;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _go(_Step s) => setState(() {
        _step = s;
        _error = null;
        _code.clear();
      });

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _username.text.trim();
    final code = _code.text.trim();
    if (username.isEmpty || code.isEmpty) {
      setState(() => _error = l10n.forgotEnterUsernameAndCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    String? userId, name;
    if (_step == _Step.recoveryCode) {
      final user = await RecoveryCodeService.verify(username, code);
      userId = user?.id;
      name = user?.username;
    } else {
      final user = await ref.read(authRepositoryProvider).getUserByUsername(username);
      final ok = _installationId != null &&
          await ResetCodeVerifier.verifyResetCode(
              installationId: _installationId!, responseCode: code);
      if (ok && user != null) {
        userId = user.id;
        name = user.username;
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (userId == null) {
      // Same message either way, so it can't be used to discover usernames.
      setState(() => _error = l10n.forgotCodeInvalid);
      return;
    }
    setState(() {
      _userId = userId;
      _verifiedUsername = name;
      _step = _Step.newPassword;
      _error = null;
    });
  }

  Future<void> _setPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final issue = passwordIssue(l10n,
        password: _password.text, confirm: _confirm.text, username: _verifiedUsername ?? '');
    if (issue != null) {
      setState(() => _error = issue);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.updatePassword(_userId!, _password.text);
      await auth.markPasswordChanged(_userId!);
      // The old recovery code is used up: issue a new one.
      final code = await RecoveryCodeService.createFor(_userId!);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => RecoveryCodeScreen(
          code: code,
          username: _verifiedUsername!,
          companyName: _companyName,
          onDone: () {
            Navigator.of(ctx).pop();
            messenger.showSnackBar(SnackBar(content: Text(l10n.forgotPasswordDone)));
          },
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l10n.authSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final company = (_companyName?.isNotEmpty ?? false) ? _companyName : null;
    return switch (_step) {
      _Step.choose => AuthLayout(
          title: l10n.forgotTitle,
          subtitle: company == null ? l10n.forgotIntro : l10n.forgotIntroCompany(company),
          children: [
            _OptionTile(
              icon: Icons.key_rounded,
              title: l10n.forgotUseRecoveryCode,
              subtitle: l10n.forgotUseRecoveryCodeHelp,
              onTap: () => _go(_Step.recoveryCode),
            ),
            const SizedBox(height: CvSpace.sm),
            _OptionTile(
              icon: Icons.support_agent_rounded,
              title: l10n.forgotAskSupport,
              subtitle: l10n.forgotAskSupportHelp,
              onTap: () => _go(_Step.supportCode),
            ),
            const SizedBox(height: CvSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups_outlined,
                    size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: CvSpace.sm),
                Expanded(
                  child: Text(l10n.forgotAskAdmin,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
            const SizedBox(height: CvSpace.md),
            TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.forgotBackToLogin)),
          ],
        ),
      _Step.recoveryCode || _Step.supportCode => AuthLayout(
          canPop: false,
          title: _step == _Step.recoveryCode ? l10n.forgotUseRecoveryCode : l10n.forgotAskSupport,
          subtitle: _step == _Step.recoveryCode
              ? l10n.forgotRecoveryCodeIntro
              : l10n.forgotSupportIntro,
          children: [
            if (_step == _Step.supportCode) ...[
              _InstallationIdBox(id: _installationId),
              const SizedBox(height: CvSpace.sm),
              OutlinedButton.icon(
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: Text(l10n.forgotEmailSupport),
                onPressed: () => openContact(ContactChannel.support, topic: 'Password reset'),
              ),
              const SizedBox(height: CvSpace.lg),
            ],
            if (_error != null) AuthMessage(_error!),
            TextField(
              controller: _username,
              autofocus: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: InputDecoration(
                labelText: l10n.authUsernameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: CvSpace.md),
            TextField(
              controller: _code,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _busy ? null : _verify(),
              style: const TextStyle(fontFamily: 'monospace', fontFamilyFallback: ['Consolas']),
              decoration: InputDecoration(
                labelText: _step == _Step.recoveryCode
                    ? l10n.recoveryCodeTitle
                    : l10n.forgotSupportCodeLabel,
                hintText: _step == _Step.recoveryCode ? 'XXXX-XXXX-XXXX-XXXX' : null,
                prefixIcon: const Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: CvSpace.lg),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.forgotVerify),
            ),
            TextButton(onPressed: () => _go(_Step.choose), child: Text(l10n.actionBack)),
          ],
        ),
      _Step.newPassword => AuthLayout(
          canPop: false,
          title: l10n.forgotNewPasswordTitle,
          subtitle: l10n.forgotNewPasswordFor(_verifiedUsername ?? ''),
          children: [
            if (_error != null) AuthMessage(_error!),
            PasswordField(
              controller: _password,
              label: l10n.authNewPasswordLabel,
              helperText: l10n.authPasswordHelp,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _confirmFocus.requestFocus(),
            ),
            const SizedBox(height: CvSpace.md),
            PasswordField(
              controller: _confirm,
              focusNode: _confirmFocus,
              label: l10n.authConfirmPasswordLabel,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _busy ? null : _setPassword(),
            ),
            const SizedBox(height: CvSpace.lg),
            FilledButton(
              onPressed: _busy ? null : _setPassword,
              child: Text(l10n.forgotSetPassword),
            ),
          ],
        ),
    };
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: CvSpace.sm + 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CvRadius.md),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          foregroundColor: scheme.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _InstallationIdBox extends StatelessWidget {
  final String? id;
  const _InstallationIdBox({required this.id});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(CvSpace.md, CvSpace.sm, CvSpace.xs, CvSpace.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(CvRadius.sm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.forgotInstallationIdLabel,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                SelectableText(id ?? '…',
                    style: const TextStyle(
                        fontFamily: 'monospace', fontFamilyFallback: ['Consolas'], fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.actionCopy,
            icon: const Icon(Icons.copy_rounded),
            onPressed: id == null
                ? null
                : () async {
                    await Clipboard.setData(ClipboardData(text: id!));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.forgotInstallationIdCopied)));
                  },
          ),
        ],
      ),
    );
  }
}
