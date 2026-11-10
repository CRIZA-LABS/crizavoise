import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/services/help_search/fuzzy_score.dart';
import 'package:crizavoise/services/help_search/help_search_service.dart';
import 'package:crizavoise/services/help_search/searchable_item.dart';

void main() {
  group('FuzzyScore', () {
    test('identical and empty', () {
      expect(FuzzyScore.weighted('Invoice', 'invoice'), 100);
      expect(FuzzyScore.weighted('', 'invoice'), 0);
    });

    test('edit distance', () {
      expect(FuzzyScore.levenshtein('kitten', 'sitting'), 3);
      expect(FuzzyScore.levenshtein('', 'abc'), 3);
    });

    test('tolerates typos', () {
      expect(FuzzyScore.weighted('invioce', 'invoice'), greaterThanOrEqualTo(70));
      expect(FuzzyScore.weighted('backp', 'backup'), greaterThanOrEqualTo(65));
    });

    test('word order does not matter', () {
      expect(FuzzyScore.weighted('number invoice', 'invoice number'), greaterThanOrEqualTo(90));
    });

    test('finds a phrase inside a longer question', () {
      expect(FuzzyScore.weighted('print invoice', 'How do I print an invoice?'), greaterThanOrEqualTo(70));
    });

    test('unrelated text stays below the help cutoff (65)', () {
      expect(FuzzyScore.weighted('backup', 'change the theme colour'), lessThan(65));
      expect(FuzzyScore.weighted('gst', 'restore a deleted customer'), lessThan(65));
    });

    test('works for non-Latin scripts', () {
      expect(FuzzyScore.weighted('बैकअप', 'बैकअप कैसे लें'), greaterThanOrEqualTo(80));
    });

    test('extractAllSorted filters by cutoff and sorts best first', () {
      final r = FuzzyScore.extractAllSorted<String>(
        query: 'upi qr',
        choices: ['Add a UPI QR code to invoices', 'Change language', 'UPI apps that work'],
        getter: (s) => s,
        cutoff: 65,
      );
      expect(r.first.choice, 'Add a UPI QR code to invoices');
      expect(r.map((e) => e.choice), isNot(contains('Change language')));
    });
  });

  group('help search (now without the GPL dependency)', () {
    final index = [
      SearchableItem(id: 'backup', type: SearchableItemType.faq, question: 'How do I back up my data?', answer: '', keywords: const ['backup', 'restore']),
      SearchableItem(id: 'upi', type: SearchableItemType.faq, question: 'Can I add a UPI QR code to my invoice?', answer: '', keywords: const ['upi', 'qr']),
      SearchableItem(id: 'theme', type: SearchableItemType.faq, question: 'Does CrizaVoise support dark mode?', answer: '', keywords: const ['dark mode', 'theme']),
    ];

    test('typo still finds the right answer first', () {
      final r = HelpSearchService.search(index, 'bakup');
      expect(r.first.item.id, 'backup');
    });

    test('keyword match', () {
      expect(HelpSearchService.search(index, 'qr code').first.item.id, 'upi');
    });

    test('nonsense finds nothing', () {
      expect(HelpSearchService.search(index, 'zzzqqq'), isEmpty);
    });
  });
}
