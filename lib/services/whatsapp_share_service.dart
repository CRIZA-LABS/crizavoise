import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:crizavoise/common/common.dart';
import 'package:crizavoise/database/invoice_number_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/services/backend_services.dart';
import 'package:crizavoise/services/pdf/pdf_service.dart';
import 'package:crizavoise/utils/formatters.dart';

/// Share an invoice on WhatsApp from the desktop.
///
/// WhatsApp links (wa.me) can carry text but not files, so the flow is:
/// 1. save the PDF to Documents/CrizaVoise/Shared,
/// 2. show it in the file manager,
/// 3. open WhatsApp at the customer's chat with a ready message,
/// 4. a short picture guide tells the user to drag the PDF into the chat.
class WhatsAppShareService {
  /// Digits-only international number for wa.me, or null if unusable.
  /// Indian 10-digit mobiles (and 0-prefixed 11-digit ones) get +91 when the
  /// invoice is in INR; numbers already starting with + or 00 keep their code.
  static String? normalizePhone(String raw, {String currencyCode = 'INR'}) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    var d = t.replaceAll(RegExp(r'\D'), '');
    if (t.startsWith('00')) d = d.substring(2);
    if (t.startsWith('+') || t.startsWith('00')) return d.length >= 8 ? d : null;
    if (currencyCode == 'INR') {
      if (d.length == 11 && d.startsWith('0')) d = d.substring(1);
      if (d.length == 10) return '91$d';
      if (d.length == 12 && d.startsWith('91')) return d;
    }
    return d.length >= 8 && d.length <= 15 ? d : null;
  }

  /// wa.me link that opens the chat (or the contact picker without a number).
  static Uri whatsAppUri(String? phoneDigits, String message) => Uri.parse(
      'https://wa.me/${phoneDigits ?? ''}?text=${Uri.encodeComponent(message)}');

  /// The message sent with the invoice, in the user's language.
  static String buildMessage(AppLocalizations l10n, Invoice invoice,
      {required String companyName, required String numberText, String? upiId}) {
    final amount = '${invoice.currencySymbol}${AmountFormat.money(invoice.total)}';
    var msg = l10n.whatsAppMessage(
        invoice.customer.name.trim().isEmpty ? '' : invoice.customer.name.trim(),
        numberText, amount, companyName);
    if (upiId != null && upiId.trim().isNotEmpty) {
      msg += '\n${l10n.whatsAppMessageUpi(upiId.trim())}';
    }
    return msg;
  }

  /// Where shared PDFs are saved.
  static Future<Directory> sharedFolder() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'CrizaVoise', 'Shared'));
    await dir.create(recursive: true);
    return dir;
  }

  /// Highlights [file] in the system file manager.
  static Future<void> revealInFolder(File file) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', ['/select,', file.path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', ['-R', file.path]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [file.parent.path]);
      }
    } catch (_) {/* the guide still shows the path */}
  }

  /// Runs the whole flow for [invoice].
  static Future<void> share(BuildContext context, Invoice invoice) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dateFmt = await BackendServices.settings.getDateFormat();
      final pdf = await PDFService.generateInvoicePDF(invoice, datePattern: dateFmt.key);
      final bytes = await pdf.save();
      final dir = await sharedFolder();
      final file = File(p.join(dir.path, PDFService.buildPdfFilename(invoice)));
      await file.writeAsBytes(bytes, flush: true);

      final company = await BackendServices.companyInfo.getCompanyInfo();
      final prefix = await InvoiceNumberService.prefixFor(invoice.type);
      final upi = invoice.upiId; // the UPI ID chosen on this invoice
      if (!context.mounted) return;
      final message = buildMessage(l10n, invoice,
          companyName: company?.name ?? '',
          numberText: '$prefix${invoice.invoiceNumber ?? invoice.id}',
          upiId: upi);
      final phone = normalizePhone(invoice.customer.phone, currencyCode: invoice.currencyCode);

      await revealInFolder(file);
      await launchUrl(whatsAppUri(phone, message), mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _ShareGuideDialog(filePath: file.path, hasPhone: phone != null),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(l10n.whatsAppShareFailed),
      ));
    }
  }
}

class _ShareGuideDialog extends StatelessWidget {
  final String filePath;
  final bool hasPhone;
  const _ShareGuideDialog({required this.filePath, required this.hasPhone});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final steps = <(IconData, String)>[
      (Icons.picture_as_pdf_outlined, l10n.whatsAppStepSaved),
      (Icons.chat_outlined, hasPhone ? l10n.whatsAppStepChatOpened : l10n.whatsAppStepPickChat),
      (Icons.drag_indicator, l10n.whatsAppStepDrag),
      (Icons.send_outlined, l10n.whatsAppStepSend),
    ];
    return AlertDialog(
      title: Text(l10n.whatsAppGuideTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Icon(steps[i].$1, color: scheme.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text('${i + 1}. ${steps[i].$2}')),
                ]),
              ),
            SelectableText(filePath,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => WhatsAppShareService.revealInFolder(File(filePath)),
          child: Text(l10n.whatsAppShowFile),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.whatsAppDone),
        ),
      ],
    );
  }
}
