import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/screens/auth/auth_layout.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Shows a new recovery code once and makes the person confirm they kept it.
class RecoveryCodeScreen extends StatefulWidget {
  final String code;
  final String username;
  final String? companyName;
  final VoidCallback onDone;

  /// Shows "Later" (for existing accounts being offered a code).
  final VoidCallback? onLater;

  const RecoveryCodeScreen({
    super.key,
    required this.code,
    required this.username,
    required this.onDone,
    this.companyName,
    this.onLater,
  });

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  bool _saved = false;

  String _fileText(AppLocalizations l10n) =>
      '${AppConfig.name} — ${l10n.recoveryCodeTitle}\n'
      '\n'
      '${widget.companyName != null ? '${widget.companyName}\n' : ''}'
      '${l10n.authUsernameLabel}: ${widget.username}\n'
      '${l10n.recoveryCodeTitle}: ${widget.code}\n'
      '\n'
      '${l10n.recoveryCodeFileHelp}\n';

  Future<void> _copy(AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.recoveryCodeCopied)));
  }

  Future<void> _saveFile(AppLocalizations l10n) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: l10n.recoveryCodeSave,
      fileName: '${AppConfig.name}-recovery-code-${widget.username}.txt',
      type: FileType.custom,
      allowedExtensions: const ['txt'],
    );
    if (path == null) return;
    await File(path).writeAsString(_fileText(l10n));
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.recoveryCodeSavedTo(path))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AuthLayout(
      canPop: false,
      title: l10n.recoveryCodeTitle,
      subtitle: l10n.recoveryCodeIntro,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: CvSpace.md + 4, horizontal: CvSpace.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(CvRadius.md),
            border: Border.all(color: scheme.outline),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SelectableText(
              widget.code,
              textAlign: TextAlign.center,
              semanticsLabel: widget.code.split('').join(' '),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Consolas', 'Menlo', 'DejaVu Sans Mono'],
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: CvSpace.md),
        Wrap(
          spacing: CvSpace.sm,
          runSpacing: CvSpace.sm,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(l10n.actionCopy),
              onPressed: () => _copy(l10n),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(l10n.recoveryCodeSave),
              onPressed: () => _saveFile(l10n),
            ),
          ],
        ),
        const SizedBox(height: CvSpace.md),
        _Point(icon: Icons.edit_note_rounded, text: l10n.recoveryCodeTipWrite),
        _Point(
            icon: Icons.lock_outline_rounded,
            text: l10n.recoveryCodeTipPrivate),
        _Point(icon: Icons.autorenew_rounded, text: l10n.recoveryCodeTipOnce),
        const SizedBox(height: CvSpace.sm),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _saved,
          onChanged: (v) => setState(() => _saved = v ?? false),
          title: Text(l10n.recoveryCodeConfirm),
        ),
        const SizedBox(height: CvSpace.sm),
        FilledButton(
          onPressed: _saved ? widget.onDone : null,
          child: Text(l10n.actionContinue),
        ),
        if (widget.onLater != null)
          TextButton(
              onPressed: widget.onLater, child: Text(l10n.recoveryCodeLater)),
      ],
    );
  }
}

class _Point extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Point({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: CvSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: CvSpace.sm),
          Expanded(
              child:
                  Text(text, style: TextStyle(color: scheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}
