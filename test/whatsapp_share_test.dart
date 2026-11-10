import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/models/customer.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/models/product.dart';
import 'package:crizavoise/services/whatsapp_share_service.dart';

void main() {
  group('phone numbers for wa.me', () {
    String? n(String s, [String c = 'INR']) => WhatsAppShareService.normalizePhone(s, currencyCode: c);

    test('Indian mobiles get +91', () {
      expect(n('98765 43210'), '919876543210');
      expect(n('098765-43210'), '919876543210');
      expect(n('91 98765 43210'), '919876543210');
    });
    test('international numbers keep their code', () {
      expect(n('+44 20 7946 0958'), '442079460958');
      expect(n('0044 20 7946 0958', 'GBP'), '442079460958');
    });
    test('unusable numbers give null (WhatsApp then asks for the chat)', () {
      expect(n(''), isNull);
      expect(n('12345'), isNull);
    });
  });

  test('wa.me link encodes the message', () {
    final u = WhatsAppShareService.whatsAppUri('919876543210', 'Invoice INV-7 & total ₹100');
    expect(u.host, 'wa.me');
    expect(u.path, '/919876543210');
    expect(u.queryParameters['text'], 'Invoice INV-7 & total ₹100');
    expect(WhatsAppShareService.whatsAppUri(null, 'x').path, '/');
  });

  testWidgets('message includes customer, number, amount, company and UPI', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (c) {
        l10n = AppLocalizations.of(c)!;
        return const SizedBox();
      }),
    ));
    final inv = Invoice(
      id: 'i1',
      invoiceNumber: '00000007',
      customer: Customer(id: 'c', name: 'Ravi Kumar', email: '', phone: '', address: '', gstin: ''),
      items: [
        InvoiceItem(
            product: Product(id: 'p', name: 'Tea', description: '', price: 250, stock: 5, hsncode: '', tax_rate: 0),
            quantity: 2)
      ],
      date: DateTime(2026, 11, 10),
      type: 'Invoice',
    );
    final msg = WhatsAppShareService.buildMessage(l10n, inv,
        companyName: 'Sharma General Store', numberText: 'INV-00000007', upiId: 'sharma@okhdfc');
    expect(msg, contains('Ravi Kumar'));
    expect(msg, contains('INV-00000007'));
    expect(msg, contains('500'));
    expect(msg, contains('Sharma General Store'));
    expect(msg, contains('sharma@okhdfc'));
  });

  testWidgets('payment reminder: unpaid invoices only; shows balance and due date', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (c) {
        l10n = AppLocalizations.of(c)!;
        return const SizedBox();
      }),
    ));
    Invoice make({bool draft = false, String type = 'Invoice'}) => Invoice(
          id: 'i2',
          invoiceNumber: '9',
          customer: Customer(id: 'c', name: 'Ravi', email: '', phone: '', address: '', gstin: ''),
          items: [
            InvoiceItem(
                product: Product(id: 'p', name: 'Tea', description: '', price: 300, stock: 5, hsncode: '', tax_rate: 0),
                quantity: 1)
          ],
          date: DateTime(2026, 11, 1),
          type: type,
          isDraft: draft,
        );
    expect(PaymentReminder.canRemind(make()), isTrue);
    expect(PaymentReminder.canRemind(make(draft: true)), isFalse);
    expect(PaymentReminder.canRemind(make(type: 'Quotation')), isFalse);
    final msg = PaymentReminder.buildMessage(l10n, make(),
        companyName: 'Shop', numberText: 'INV-9', dueText: '15/11/2026', upiId: 'shop@upi');
    expect(msg, contains('300'));
    expect(msg, contains('INV-9'));
    expect(msg, contains('15/11/2026'));
    expect(msg, contains('shop@upi'));
    expect(msg.split('\n').length, 4);
  });
}
