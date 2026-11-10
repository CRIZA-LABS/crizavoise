// Performance baseline on a busy shop's data: 5,000 invoices, 500
// customers, 300 products in a real SQLite file. Prints timings; run with
//   BENCH=1 flutter test test/benchmarks/db_benchmark_test.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/customer_service.dart';
import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/invoice_number_service.dart';
import 'package:crizavoise/database/invoice_service.dart';
import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/models/customer.dart';
import 'package:crizavoise/models/invoice.dart';
import 'package:crizavoise/models/invoice_item.dart';
import 'package:crizavoise/models/product.dart';

final _enabled = Platform.environment.containsKey('BENCH');

Future<Duration> _time(Future<void> Function() f, {int runs = 5}) async {
  final sw = Stopwatch();
  final samples = <int>[];
  for (var i = 0; i < runs; i++) {
    sw
      ..reset()
      ..start();
    await f();
    sw.stop();
    samples.add(sw.elapsedMicroseconds);
  }
  samples.sort();
  return Duration(microseconds: samples[samples.length ~/ 2]); // median
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('database timings with 5,000 invoices', () async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final tmp = Directory.systemTemp.createTempSync('cv_bench');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), (call) async => tmp.path);
    await DatabaseHelper().switchToFile('bench.db');

    final seed = Stopwatch()..start();
    final products = [
      for (var i = 0; i < 300; i++)
        Product(
            id: 'p$i', name: 'Product $i ${i.isEven ? 'Rice' : 'Oil'}', description: '',
            price: 50.0 + i, stock: 100000, hsncode: '${1000 + i}', tax_rate: 5,
            quickCode: 'Q$i'),
    ];
    for (final p in products) {
      await ProductService.insertProduct(p);
    }
    final customers = [
      for (var i = 0; i < 500; i++)
        Customer(id: 'c$i', name: 'Customer $i', email: '', phone: '98${i.toString().padLeft(8, '0')}', address: '', gstin: ''),
    ];
    for (final c in customers) {
      await CustomerService.insertCustomer(c);
    }
    final start = DateTime(2025, 1, 1);
    for (var i = 0; i < 5000; i++) {
      await InvoiceService.insertInvoice(Invoice(
        id: 'i$i',
        invoiceNumber: (i + 1).toString().padLeft(8, '0'),
        customer: customers[i % customers.length],
        items: [
          for (var k = 0; k < 3; k++)
            InvoiceItem(product: products[(i * 7 + k) % products.length], quantity: 1.0 + k),
        ],
        date: start.add(Duration(hours: i * 2)),
        type: 'Invoice',
        taxRate: 5,
      ));
    }
    seed.stop();

    final results = <String, Duration>{
      'Invoice list: first page (20)': await _time(() async {
        await InvoiceService.getInvoicesPaginated(filterType: 'Invoice', pageSize: 20);
      }),
      'Invoice list: search "Customer 42"': await _time(() async {
        await InvoiceService.getInvoicesPaginated(filterType: 'Invoice', searchQuery: 'Customer 42', pageSize: 20);
      }),
      'Next invoice number': await _time(() => InvoiceService.generateNextInvoiceNumber('Invoice')),
      'Duplicate-number check': await _time(() => InvoiceNumberService.isTaken('Invoice', '4999')),
      'Product search (New Invoice) "rice"': await _time(() async {
        await ProductService.getProductsPaginated(offset: 0, limit: 30, query: 'rice');
      }),
      'Product search by quick code "Q150"': await _time(() async {
        await ProductService.getProductsPaginated(offset: 0, limit: 30, query: 'Q150');
      }),
    };

    final out = StringBuffer('\nSeeded 300 products, 500 customers, 5,000 invoices '
        '(15,000 lines) in ${(seed.elapsedMilliseconds / 1000).toStringAsFixed(1)} s\n');
    results.forEach((k, v) => out.writeln('  ${k.padRight(38)} ${(v.inMicroseconds / 1000).toStringAsFixed(1).padLeft(8)} ms'));
    // ignore: avoid_print
    print(out);
    File('build/benchmark.txt')
      ..createSync(recursive: true)
      ..writeAsStringSync(out.toString());

    await DatabaseHelper().close();
    for (final v in results.values) {
      expect(v.inMilliseconds, lessThan(500)); // interactive budget
    }
  }, skip: !_enabled, timeout: const Timeout(Duration(minutes: 10)));
}
