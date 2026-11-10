import 'package:flutter/material.dart';

import 'package:crizavoise/database/pin_service.dart';
import 'package:crizavoise/database/recovery_code_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/screens/auth/change_password_screen.dart';
import 'package:crizavoise/screens/auth/pin_dialogs.dart';
import 'package:crizavoise/screens/auth/recovery_code_screen.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/utils/password_utils.dart';

/// "My account" from the sidebar: quick PIN, password and recovery code for
/// the person who is signed in.
Future<void> showMyAccountDialog(BuildContext context, User user) {
  return showDialog<void>(context: context, builder: (_) => _MyAccountDialog(user: user));
}

class _MyAccountDialog extends StatefulWidget {
  final User user;
  const _MyAccountDialog({required this.user});

  @override
  State<_MyAccountDialog> createState() => _MyAccountDialogState();
}

class _MyAccountDialogState extends State<_MyAccountDialog> {
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final has = await PinService.hasPin(widget.user.id);
    if (mounted) setState(() => _hasPin = has);
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _setPin() async {
    final l10n = AppLocalizations.of(context)!;
    if (await showSetPin(context, widget.user)) {
      _snack(l10n.pinSaved);
      await _refresh();
    }
  }

  Future<void> _removePin() async {
    final l10n = AppLocalizations.of(context)!;
    await PinService.clearPin(widget.user.id);
    _snack(l10n.pinRemoved);
    await _refresh();
  }

  Future<void> _newRecoveryCode() async {
    final ok = await _confirmPassword(context, widget.user);
    if (!ok || !mounted) return;
    final code = await RecoveryCodeService.createFor(widget.user.id);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => RecoveryCodeScreen(
        code: code,
        username: widget.user.username,
        onDone: () => Navigator.of(ctx).pop(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          UserAvatar(name: widget.user.username, radius: 22),
          const SizedBox(width: CvSpace.md),
          Expanded(child: Text(widget.user.username)),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: CvSpace.md),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dialpad_rounded),
              title: Text(l10n.pinTitle),
              subtitle: Text(_hasPin == true ? l10n.pinOnHelp : l10n.pinOffHelp),
              trailing: _hasPin == true
                  ? Wrap(spacing: 4, children: [
                      TextButton(onPressed: _setPin, child: Text(l10n.pinChange)),
                      TextButton(
                          onPressed: _removePin,
                          style: TextButton.styleFrom(foregroundColor: scheme.error),
                          child: Text(l10n.pinRemove)),
                    ])
                  : FilledButton.tonal(onPressed: _setPin, child: Text(l10n.pinSet)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.password_rounded),
              title: Text(l10n.myAccountChangePassword),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(user: widget.user)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_rounded),
              title: Text(l10n.myAccountNewRecoveryCode),
              subtitle: Text(l10n.myAccountNewRecoveryCodeHelp),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _newRecoveryCode,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionClose)),
      ],
    );
  }
}

/// Asks the signed-in person to type their password again before a
/// sensitive change.
Future<bool> _confirmPassword(BuildContext context, User user) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  String? error;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        void check() {
          if (PasswordUtils.verify(controller.text, user.password, user.salt)) {
            Navigator.pop(ctx, true);
          } else {
            setState(() => error = l10n.pinPasswordWrong);
          }
        }

        return AlertDialog(
          title: Text(l10n.myAccountConfirmPassword),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            onSubmitted: (_) => check(),
            decoration: InputDecoration(labelText: l10n.authPasswordLabel, errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.actionCancel)),
            FilledButton(onPressed: check, child: Text(l10n.actionContinue)),
          ],
        );
      },
    ),
  );
  controller.dispose();
  return ok ?? false;
}
