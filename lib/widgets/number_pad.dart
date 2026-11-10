import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Large on-screen number pad (64 px keys) for PINs and amounts, for touch
/// screens and people who find small fields hard. The physical keyboard
/// works too: digits, Backspace and Enter.
class NumberPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onDone;
  final String? doneLabel;
  final bool allowDecimal;

  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onDone,
    this.doneLabel,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget key(String d) => _PadKey(label: d, onTap: () => onDigit(d));
    return Focus(
      autofocus: true,
      onKeyEvent: (node, e) {
        if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
        final ch = e.character;
        if (ch != null && RegExp(r'^\d$').hasMatch(ch)) {
          onDigit(ch);
          return KeyEventResult.handled;
        }
        if (allowDecimal && ch == '.') {
          onDigit('.');
          return KeyEventResult.handled;
        }
        if (e.logicalKey == LogicalKeyboardKey.backspace) {
          onBackspace();
          return KeyEventResult.handled;
        }
        if ((e.logicalKey == LogicalKeyboardKey.enter ||
                e.logicalKey == LogicalKeyboardKey.numpadEnter) &&
            onDone != null) {
          onDone!();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: 3 * 72 + 2 * CvSpace.sm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ]) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [for (final d in row) key(d)],
              ),
              const SizedBox(height: CvSpace.sm),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                allowDecimal
                    ? key('.')
                    : _PadKey(
                        icon: Icons.check_rounded,
                        semantics: doneLabel ?? l10n.actionContinue,
                        onTap: onDone,
                        filled: true,
                      ),
                key('0'),
                _PadKey(
                  icon: Icons.backspace_outlined,
                  semantics: l10n.numberPadDelete,
                  onTap: onBackspace,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final String? semantics;
  final VoidCallback? onTap;
  final bool filled;

  const _PadKey({this.label, this.icon, this.semantics, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = filled ? scheme.onPrimary : scheme.onSurface;
    return Semantics(
      button: true,
      label: semantics ?? label,
      excludeSemantics: true,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Material(
          color: onTap == null ? bg.withValues(alpha: 0.4) : bg,
          borderRadius: BorderRadius.circular(CvRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(CvRadius.md),
            canRequestFocus: false,
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: fg)
                  : Text(label!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dots showing how many PIN digits were typed.
class PinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool error;
  const PinDots({super.key, required this.length, required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = error ? scheme.error : scheme.primary;
    return Semantics(
      label: '$filled / $length',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < length; i++)
            AnimatedContainer(
              duration: CvMotion.fast,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? c : Colors.transparent,
                border: Border.all(color: i < filled ? c : scheme.outline, width: 2),
              ),
            ),
        ],
      ),
    );
  }
}
