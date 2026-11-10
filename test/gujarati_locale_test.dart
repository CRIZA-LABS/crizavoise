import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/providers/locale_provider.dart';
import 'package:crizavoise/widgets/language_picker.dart';

void main() {
  test('Gujarati is offered, shown in its own script', () {
    expect(supportedAppLocales, contains(const Locale('gu')));
    expect(appLanguageLabel(const Locale('gu')), 'ગુજરાતી');
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode), contains('gu'));
  });

  test('core strings are Gujarati; untranslated ones fall back to English', () async {
    final gu = await AppLocalizations.delegate.load(const Locale('gu'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(gu.navNewInvoice, 'નવું ઇન્વૉઇસ');
    expect(gu.speakRupees, 'રૂપિયા');
    expect(gu.whatsAppMessage('Ravi', 'INV-7', '₹500', 'Sharma Store'), contains('Ravi'));
    // Not translated yet -> English text, never a missing key.
    expect(gu.appInfoTitle, en.appInfoTitle);
  });
}
