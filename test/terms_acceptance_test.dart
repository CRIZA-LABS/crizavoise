import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/screens/legal/legal_document_screen.dart';
import 'package:crizavoise/screens/legal/terms_acceptance_screen.dart';
import 'package:crizavoise/services/terms_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, VoidCallback onAccepted) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TermsAcceptanceScreen(onAccepted: onAccepted),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('cannot continue without ticking "I agree"', (tester) async {
    var accepted = false;
    await pump(tester, () => accepted = true);
    final button = find.widgetWithText(FilledButton, 'Agree and continue');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.tap(button);
    await tester.pump();
    expect(accepted, isFalse);
    expect(await TermsService.isAccepted(), isFalse);
  });

  testWidgets('accepting records the current version and continues', (tester) async {
    var accepted = false;
    await pump(tester, () => accepted = true);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Agree and continue'));
    await tester.pumpAndSettle();
    expect(accepted, isTrue);
    expect(await TermsService.isAccepted(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('terms_accepted_version'), AppConfig.termsVersion);
  });

  test('a new terms version asks again', () async {
    SharedPreferences.setMockInitialValues({'terms_accepted_version': '2000-01-01'});
    expect(await TermsService.isAccepted(), isFalse);
  });

  testWidgets('the full Terms render from the bundled asset', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const LegalDocumentScreen(title: 'Terms of Use', asset: AppConfig.termsAsset),
    ));
    await tester.pumpAndSettle();
    expect(find.text('CrizaVoise Terms of Use'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('6. Limitation of liability'), 400);
    expect(find.text('6. Limitation of liability'), findsOneWidget);
  });
}
