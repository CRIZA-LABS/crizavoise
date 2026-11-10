import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/utils/formatters.dart';

/// Reads text aloud with the operating system's voices (Windows SAPI /
/// macOS / Linux speech-dispatcher). For people who can't read: invoices,
/// totals and screen help can be spoken in the app language.
class SpeechService {
  static final FlutterTts _tts = FlutterTts();
  static bool _speaking = false;

  static bool get isSpeaking => _speaking;

  /// BCP-47 voice tag for the app locale ("hi" -> "hi-IN").
  static String voiceTag(Locale locale) => switch (locale.languageCode) {
        'hi' => 'hi-IN',
        'gu' => 'gu-IN',
        'ne' => 'ne-NP',
        'en' => 'en-IN',
        final c => c,
      };

  /// Speaks [text]; falls back to the default voice if the language isn't
  /// installed. Never throws — speech is a helper, not a requirement.
  static Future<void> speak(String text, Locale locale) async {
    try {
      await _tts.stop();
      final tag = voiceTag(locale);
      final ok = await _tts.isLanguageAvailable(tag);
      if (ok == true) await _tts.setLanguage(tag);
      await _tts.setSpeechRate(0.45); // a little slower than default: clearer
      _speaking = true;
      _tts.setCompletionHandler(() => _speaking = false);
      await _tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  static Future<void> stop() async {
    _speaking = false;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// The sentence read for an invoice: number, customer, total, status and
  /// due date — numbers written so voices read them naturally.
  static String invoiceSentence(AppLocalizations l10n, Invoice invoice,
      {required String numberText, required String localeName}) {
    final amount = AmountFormat.money(invoice.total).replaceAll(RegExp(r'\.00$'), '');
    final parts = <String>[
      l10n.speakInvoiceIntro(numberText.replaceFirst(RegExp(r'^\D*0*'), ''),
          invoice.customer.name.trim().isEmpty ? '—' : invoice.customer.name.trim()),
      l10n.speakInvoiceTotal(amount, _currencyWord(l10n, invoice.currencyCode)),
    ];
    final paid = invoice.payments.fold<double>(0, (s, p) => s + p.amountPaid);
    final due = invoice.total - paid;
    if (paid > 0.005 && due > 0.005) {
      parts.add(l10n.speakInvoicePartlyPaid(
          AmountFormat.money(due).replaceAll(RegExp(r'\.00$'), '')));
    } else if (due <= 0.005) {
      parts.add(l10n.speakInvoicePaid);
    }
    if (invoice.dueDate != null && due > 0.005) {
      parts.add(l10n.speakInvoiceDue(_monthDay(invoice.dueDate!, localeName)));
    }
    return parts.join(' ');
  }

  /// 'September 20' in the app language; English if that locale's date
  /// data isn't loaded (speech must never fail).
  static String _monthDay(DateTime d, String localeName) {
    try {
      return DateFormat.MMMMd(localeName).format(d);
    } catch (_) {
      return DateFormat.MMMMd('en_US').format(d);
    }
  }

  static String _currencyWord(AppLocalizations l10n, String code) =>
      code == 'INR' ? l10n.speakRupees : code;
}

/// Speaker button: reads [text] aloud; tap again to stop.
class ReadAloudButton extends StatefulWidget {
  final String Function() text;
  final double size;
  const ReadAloudButton({super.key, required this.text, this.size = 20});

  @override
  State<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends State<ReadAloudButton> {
  bool _on = false;

  @override
  void dispose() {
    if (_on) SpeechService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: _on ? l10n.speakStop : l10n.speakReadAloud,
      icon: Icon(_on ? Icons.stop_circle_outlined : Icons.volume_up_outlined, size: widget.size),
      onPressed: () async {
        if (_on) {
          await SpeechService.stop();
          if (mounted) setState(() => _on = false);
          return;
        }
        setState(() => _on = true);
        await SpeechService.speak(widget.text(), Localizations.localeOf(context));
        // Reset the icon after a while even if no completion event arrives.
        Future.delayed(const Duration(seconds: 12), () {
          if (mounted) setState(() => _on = false);
        });
      },
    );
  }
}
