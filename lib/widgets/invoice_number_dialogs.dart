import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:crizavoise/database/invoice_number_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/theme/tokens.dart';

String invoiceNumberIssueText(AppLocalizations l10n, InvoiceNumberIssue issue) => switch (issue) {
      InvoiceNumberIssue.empty => l10n.invoiceNumberIssueEmpty,
      InvoiceNumberIssue.invalidCharacters => l10n.invoiceNumberIssueInvalid,
      InvoiceNumberIssue.tooLong => l10n.invoiceNumberIssueTooLong,
      InvoiceNumberIssue.duplicate => l10n.invoiceNumberIssueDuplicate,
    };

/// Result of [showCustomNumberDialog].
sealed class CustomNumberChoice {
  const CustomNumberChoice();
}

class UseAutomaticNumber extends CustomNumberChoice {
  const UseAutomaticNumber();
}

class UseTypedNumber extends CustomNumberChoice {
  final String number;
  const UseTypedNumber(this.number);
}

/// Lets a permitted user type the number for a NEW document. Returns null if
/// cancelled. The number is fully validated (format + uniqueness) here and
/// again when the invoice is saved.
Future<CustomNumberChoice?> showCustomNumberDialog(
  BuildContext context, {
  required String type,
  required String prefix,
  required String autoNumber,
  String? current,
}) {
  return showDialog<CustomNumberChoice>(
    context: context,
    builder: (_) => _CustomNumberDialog(
        type: type, prefix: prefix, autoNumber: autoNumber, current: current),
  );
}

class _CustomNumberDialog extends StatefulWidget {
  final String type, prefix, autoNumber;
  final String? current;
  const _CustomNumberDialog(
      {required this.type, required this.prefix, required this.autoNumber, this.current});

  @override
  State<_CustomNumberDialog> createState() => _CustomNumberDialogState();
}

class _CustomNumberDialogState extends State<_CustomNumberDialog> {
  late final _ctrl = TextEditingController(text: widget.current ?? '');
  InvoiceNumberIssue? _issue;
  bool _checking = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _checking = true);
    final issue = await InvoiceNumberService.validate(widget.type, _ctrl.text, prefix: widget.prefix);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _issue = issue;
    });
    if (issue == null) Navigator.of(context).pop(UseTypedNumber(_ctrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.invoiceNumberDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.invoiceNumberAutoLabel('${widget.prefix}${widget.autoNumber}'),
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: CvSpace.md),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLength: InvoiceNumberService.maxLength,
              decoration: InputDecoration(
                labelText: l10n.invoiceNumberCustomFieldLabel,
                hintText: l10n.invoiceNumberFieldHint,
                prefixText: widget.prefix.isEmpty ? null : widget.prefix,
                errorText: _issue == null ? null : invoiceNumberIssueText(l10n, _issue!),
                errorMaxLines: 3,
              ),
              onChanged: (v) => setState(() =>
                  _issue = v.isEmpty ? null : InvoiceNumberService.checkFormat(v, prefix: widget.prefix)),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(const UseAutomaticNumber()),
          child: Text(l10n.invoiceNumberUseAutoAction),
        ),
        FilledButton(
          onPressed: _checking ? null : _submit,
          child: Text(l10n.invoiceNumberUseThisAction),
        ),
      ],
    );
  }
}

/// Admin-only: change the number of an EXISTING document, with a reason and
/// password confirmation. Shows the change history. Returns the new number if
/// it was changed.
Future<String?> showChangeInvoiceNumberDialog(
  BuildContext context, {
  required String invoiceId,
  required String type,
  required String currentNumber,
  required String prefix,
  required User user,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ChangeNumberDialog(
        invoiceId: invoiceId, type: type, currentNumber: currentNumber, prefix: prefix, user: user),
  );
}

class _ChangeNumberDialog extends StatefulWidget {
  final String invoiceId, type, currentNumber, prefix;
  final User user;
  const _ChangeNumberDialog(
      {required this.invoiceId,
      required this.type,
      required this.currentNumber,
      required this.prefix,
      required this.user});

  @override
  State<_ChangeNumberDialog> createState() => _ChangeNumberDialogState();
}

class _ChangeNumberDialogState extends State<_ChangeNumberDialog> {
  final _number = TextEditingController();
  final _reason = TextEditingController();
  final _password = TextEditingController();
  String? _numberError, _reasonError, _passwordError, _generalError;
  bool _busy = false;
  late final Future<List<InvoiceNumberChange>> _history =
      InvoiceNumberService.history(widget.invoiceId);

  @override
  void dispose() {
    _number.dispose();
    _reason.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _numberError = _reasonError = _passwordError = _generalError = null;
    });
    try {
      await InvoiceNumberService.changeNumber(
        invoiceId: widget.invoiceId,
        newNumber: _number.text,
        reason: _reason.text,
        user: widget.user,
        password: _password.text,
        prefix: widget.prefix,
      );
      if (mounted) Navigator.of(context).pop(_number.text.trim());
    } on InvoiceNumberValidationException catch (e) {
      setState(() => _numberError = invoiceNumberIssueText(l10n, e.issue));
    } on InvoiceNumberReasonException {
      setState(() => _reasonError = l10n.invoiceNumberReasonMissing);
    } on InvoiceNumberPasswordException {
      setState(() => _passwordError = l10n.invoiceNumberPasswordWrong);
    } on InvoiceNumberPermissionException {
      setState(() => _generalError = l10n.invoiceNumberNoPermission);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat.yMMMd().add_jm();
    return AlertDialog(
      title: Text(l10n.invoiceNumberChangeAction),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(CvSpace.sm + 4),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(CvRadius.sm),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.policy_outlined, color: scheme.error, size: 20),
                  const SizedBox(width: CvSpace.sm),
                  Expanded(child: Text(l10n.invoiceNumberChangeWarning)),
                ]),
              ),
              const SizedBox(height: CvSpace.md),
              Text(l10n.invoiceNumberCurrentLabel('${widget.prefix}${widget.currentNumber}'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: CvSpace.md),
              TextField(
                controller: _number,
                autofocus: true,
                maxLength: InvoiceNumberService.maxLength,
                decoration: InputDecoration(
                  labelText: l10n.invoiceNumberNewLabel,
                  hintText: l10n.invoiceNumberFieldHint,
                  prefixText: widget.prefix.isEmpty ? null : widget.prefix,
                  errorText: _numberError,
                  errorMaxLines: 3,
                ),
              ),
              const SizedBox(height: CvSpace.sm),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.invoiceNumberReasonLabel, errorText: _reasonError),
              ),
              const SizedBox(height: CvSpace.md),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.invoiceNumberPasswordLabel,
                  prefixIcon: const Icon(Icons.lock_outline),
                  errorText: _passwordError,
                ),
                onSubmitted: (_) => _save(),
              ),
              if (_generalError != null) ...[
                const SizedBox(height: CvSpace.sm),
                Text(_generalError!, style: TextStyle(color: scheme.error)),
              ],
              const SizedBox(height: CvSpace.lg),
              Text(l10n.invoiceNumberHistoryTitle, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: CvSpace.xs),
              FutureBuilder<List<InvoiceNumberChange>>(
                future: _history,
                builder: (context, snap) {
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return Text(l10n.invoiceNumberHistoryNone,
                        style: TextStyle(color: scheme.onSurfaceVariant));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final c in items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            l10n.invoiceNumberHistoryEntry(c.oldNumber ?? '—', c.newNumber, c.changedBy,
                                    dateFmt.format(c.changedAt)) +
                                (c.reason == null ? '' : ' — "${c.reason}"'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.actionSave)),
      ],
    );
  }
}
