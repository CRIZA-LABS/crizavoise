import 'package:flutter/material.dart';

import 'package:crizavoise/database/pin_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/theme/tokens.dart';
import 'package:crizavoise/theme/swatch.dart';
import 'package:crizavoise/utils/password_utils.dart';
import 'package:crizavoise/widgets/number_pad.dart';

/// Round initial avatar, coloured per person so staff recognise themselves.
class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const UserAvatar({super.key, required this.name, this.radius = 28});

  @override
  Widget build(BuildContext context) {
    // Stable across runs (String.hashCode is not).
    final sum = name.toLowerCase().codeUnits.fold<int>(0, (a, b) => a + b);
    final color = CvSwatch.avatars[sum % CvSwatch.avatars.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.18),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(color: color, fontSize: radius * 0.8, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Signs [user] in with their PIN. Returns true when the PIN was right.
Future<bool> showPinSignIn(BuildContext context, User user) async {
  return await showDialog<bool>(
          context: context, builder: (_) => _PinSignInDialog(user: user)) ??
      false;
}

class _PinSignInDialog extends StatefulWidget {
  final User user;
  const _PinSignInDialog({required this.user});

  @override
  State<_PinSignInDialog> createState() => _PinSignInDialogState();
}

class _PinSignInDialogState extends State<_PinSignInDialog> {
  String _pin = '';
  String? _error;
  bool _locked = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    PinService.isLocked(widget.user.id).then((l) {
      if (mounted && l) setState(() => _locked = true);
    });
  }

  void _digit(String d) {
    if (_pin.length >= 6 || _locked) return;
    setState(() {
      _pin += d;
      _error = null;
    });
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pin.length < 4 || _busy || _locked) return;
    setState(() => _busy = true);
    final r = await PinService.verify(widget.user.id, _pin);
    if (!mounted) return;
    if (r == PinCheck.ok) {
      Navigator.pop(context, true);
      return;
    }
    final left = await PinService.attemptsLeft(widget.user.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
      _locked = r == PinCheck.locked;
      _error = _locked ? null : l10n.pinWrong(left);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(CvSpace.lg, CvSpace.lg, CvSpace.lg, CvSpace.sm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(name: widget.user.username),
          const SizedBox(height: CvSpace.sm),
          Text(widget.user.username, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: CvSpace.xs),
          Text(_locked ? l10n.pinLocked : l10n.pinEnterPrompt,
              textAlign: TextAlign.center,
              style: TextStyle(color: _locked ? scheme.error : scheme.onSurfaceVariant)),
          const SizedBox(height: CvSpace.md),
          if (!_locked) ...[
            PinDots(length: _pin.length < 4 ? 4 : _pin.length, filled: _pin.length, error: _error != null),
            SizedBox(
              height: 28,
              child: _error == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: CvSpace.sm),
                      child: Semantics(
                          liveRegion: true,
                          child: Text(_error!, style: TextStyle(color: scheme.error))),
                    ),
            ),
            NumberPad(onDigit: _digit, onBackspace: _back, onDone: _pin.length >= 4 ? _submit : null),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_locked ? l10n.pinUsePassword : l10n.actionCancel)),
      ],
    );
  }
}

/// Lets the signed-in [user] set (or change) their PIN after confirming
/// their password. Returns true when a PIN was saved.
Future<bool> showSetPin(BuildContext context, User user) async {
  return await showDialog<bool>(context: context, builder: (_) => _SetPinDialog(user: user)) ??
      false;
}

enum _SetStage { password, first, confirm }

class _SetPinDialog extends StatefulWidget {
  final User user;
  const _SetPinDialog({required this.user});

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  _SetStage _stage = _SetStage.password;
  final _password = TextEditingController();
  String _first = '';
  String _pin = '';
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _checkPassword() {
    final l10n = AppLocalizations.of(context)!;
    if (PasswordUtils.verify(_password.text, widget.user.password, widget.user.salt)) {
      setState(() {
        _stage = _SetStage.first;
        _error = null;
      });
    } else {
      setState(() => _error = l10n.pinPasswordWrong);
    }
  }

  Future<void> _next() async {
    final l10n = AppLocalizations.of(context)!;
    if (_pin.length < 4) return;
    if (_stage == _SetStage.first) {
      if (PinService.isTooSimple(_pin)) {
        setState(() {
          _error = l10n.pinTooSimple;
          _pin = '';
        });
        return;
      }
      setState(() {
        _first = _pin;
        _pin = '';
        _stage = _SetStage.confirm;
        _error = null;
      });
      return;
    }
    if (_pin != _first) {
      setState(() {
        _error = l10n.pinMismatch;
        _pin = '';
        _first = '';
        _stage = _SetStage.first;
      });
      return;
    }
    await PinService.setPin(widget.user.id, _pin);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final errorText = _error == null
        ? const SizedBox(height: 20)
        : Padding(
            padding: const EdgeInsets.only(top: CvSpace.sm),
            child: Semantics(
                liveRegion: true, child: Text(_error!, style: TextStyle(color: scheme.error))),
          );
    return AlertDialog(
      title: Text(l10n.pinSetTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              switch (_stage) {
                _SetStage.password => l10n.pinSetPasswordPrompt,
                _SetStage.first => l10n.pinSetChoose,
                _SetStage.confirm => l10n.pinSetConfirm,
              },
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: CvSpace.md),
            if (_stage == _SetStage.password) ...[
              TextField(
                controller: _password,
                obscureText: true,
                autofocus: true,
                onSubmitted: (_) => _checkPassword(),
                decoration: InputDecoration(
                  labelText: l10n.authPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
              errorText,
            ] else ...[
              PinDots(length: _pin.length < 4 ? 4 : _pin.length, filled: _pin.length, error: _error != null),
              errorText,
              const SizedBox(height: CvSpace.sm),
              NumberPad(
                key: ValueKey(_stage),
                onDigit: (d) {
                  if (_pin.length < 6) setState(() => _pin += d);
                },
                onBackspace: () {
                  if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
                },
                onDone: _pin.length >= 4 ? _next : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.actionCancel)),
        if (_stage == _SetStage.password)
          FilledButton(onPressed: _checkPassword, child: Text(l10n.actionContinue)),
      ],
    );
  }
}
