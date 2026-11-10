import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/database/recovery_code_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/providers/repositories.dart';
import 'package:crizavoise/screens/auth/auth_layout.dart';
import 'package:crizavoise/screens/auth/recovery_code_screen.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/utils/post_auth_navigation.dart';

/// First run: the owner creates their own sign-in, replacing the built-in
/// admin/admin account (which is never shown to anyone). Then they get a
/// recovery code and go on to the setup wizard.
class CreateAccountScreen extends ConsumerStatefulWidget {
  /// The built-in admin account that is being taken over.
  final User defaultAdmin;
  const CreateAccountScreen({super.key, required this.defaultAdmin});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  String? _error;
  bool _busy = false;

  static final _usernamePattern = RegExp(r'^[A-Za-z0-9._@-]{3,32}$');

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _username.text.trim();
    String? issue;
    if (!_usernamePattern.hasMatch(username)) {
      issue = l10n.authUsernameRule;
    } else {
      issue = passwordIssue(l10n,
          password: _password.text, confirm: _confirm.text, username: username);
    }
    if (issue == null && username.toLowerCase() != widget.defaultAdmin.username.toLowerCase()) {
      final taken = await ref.read(authRepositoryProvider).getUserByUsername(username);
      if (taken != null) issue = l10n.authUsernameTaken;
    }
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
      final admin = widget.defaultAdmin;
      await auth.updateUser(User(
          id: admin.id,
          username: username,
          password: admin.password,
          userType: 'admin',
          salt: admin.salt));
      await auth.updatePassword(admin.id, _password.text);
      await auth.markPasswordChanged(admin.id);
      final user = await auth.getUserById(admin.id) ?? admin;
      final code = await RecoveryCodeService.createFor(admin.id);
      final company = (await ref.read(companyInfoRepositoryProvider).getCompanyInfo())?.name;
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (ctx) => RecoveryCodeScreen(
          code: code,
          username: username,
          companyName: (company?.isNotEmpty ?? false) ? company : null,
          onDone: () => navigateAfterAuth(ctx, ref, user),
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
    return AuthLayout(
      title: l10n.createAccountTitle,
      subtitle: l10n.createAccountIntro,
      children: [
        if (_error != null) AuthMessage(_error!),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _username,
                autofocus: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newUsername],
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: InputDecoration(
                  labelText: l10n.authUsernameLabel,
                  helperText: l10n.authUsernameHelp,
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: CvSpace.md),
              PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                label: l10n.authPasswordLabel,
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
                onSubmitted: (_) => _busy ? null : _create(),
              ),
            ],
          ),
        ),
        const SizedBox(height: CvSpace.lg),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: _busy
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.createAccountButton),
        ),
        const SizedBox(height: CvSpace.sm),
        Text(l10n.createAccountPrivacyNote,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
