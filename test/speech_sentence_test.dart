import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/customer.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/models/invoice_payment.dart';
import 'package:crizavoise/models/product.dart';
import 'package:crizavoise/services/speech_service.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Invoice inv({double paid = 0, DateTime? due}) {
    final i = Invoice(
      id: 'i1',
      invoiceNumber: '00001008',
      customer: Customer(id: 'c', name: 'Ravi Kumar', email: '', phone: '', address: '', gstin: ''),
      items: [
        InvoiceItem(
            product: Product(id: 'p', name: 'Rice', description: '', price: 1000, stock: 9, hsncode: '', tax_rate: 0),
            quantity: 3)
      ],
      date: DateTime(2026, 9, 5),
      dueDate: due,
      type: 'Invoice',
    );
    if (paid > 0) {
      i.payments = [
        InvoicePayment(
          id: 'pay1', invoiceId: 'i1', invoiceNumber: '00001008', receiptNumber: 'R1',
          amountPaid: paid, taxAmountPaid: 0, previouslyPaid: 0,
          balanceAfter: i.total - paid, datePaid: DateTime(2026, 9, 6)),
      ];
    }
    return i;
  }

  String say(Invoice i) =>
      SpeechService.invoiceSentence(l10n, i, numberText: 'INV-00001008', localeName: 'en');

  test('unpaid with due date', () {
    final s = say(inv(due: DateTime(2026, 9, 20)));
    expect(s, contains('Invoice 1008 for Ravi Kumar.'));
    expect(s, matches(RegExp(r'Total 3,?000 rupees.')));
    expect(s, contains('Due on September 20.'));
  });

  test('partly paid says what is left', () {
    expect(say(inv(paid: 1000, due: DateTime(2026, 9, 20))), matches(RegExp(r'2,?000 still to pay.')));
  });

  test('fully paid, no due date read', () {
    final s = say(inv(paid: 3000, due: DateTime(2026, 9, 20)));
    expect(s, contains('Fully paid.'));
    expect(s, isNot(contains('Due on')));
  });

  test('voice tags', () {
    expect(SpeechService.voiceTag(const Locale('hi')), 'hi-IN');
    expect(SpeechService.voiceTag(const Locale('en')), 'en-IN');
  });
}
