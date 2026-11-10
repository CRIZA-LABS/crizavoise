import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/theme/app_theme.dart';

void main() {
  Future<void> pushPage(WidgetTester tester, {required bool reduce}) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce), child: child!),
      home: const Scaffold(body: Text('home')),
    ));
    nav.currentState!.push(MaterialPageRoute(builder: (_) => const Scaffold(body: Text('next'))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('reduced motion: page change is a plain fade (no slide/scale)', (tester) async {
    await pushPage(tester, reduce: true);
    final next = find.text('next');
    expect(find.ancestor(of: next, matching: find.byType(FadeTransition)), findsWidgets);
    expect(find.ancestor(of: next, matching: find.byType(SlideTransition)), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('normal motion uses the fade-forward transition', (tester) async {
    await pushPage(tester, reduce: false);
    expect(find.text('next'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);
  });
}
