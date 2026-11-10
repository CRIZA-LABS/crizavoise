// Product quick codes: saved with the product, unique (case-insensitive),
// suggested from the name, and ranked first in every product search.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tmp = Directory.systemTemp.createTempSync('cv_quick_code');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), (call) async => tmp.path);
  });

  tearDownAll(() async {
    await DatabaseHelper().close();
    tmp.deleteSync(recursive: true);
  });

  var n = 0;
  setUp(() async {
    await DatabaseHelper().switchToFile('quick_${n++}.db');
    for (final p in [
      Product(id: 'a', name: 'Basmati Rice 5 kg', description: '', price: 545, stock: 9, hsncode: '1006', tax_rate: 5, quickCode: 'R5'),
      Product(id: 'b', name: 'Rava 1 kg', description: '', price: 60, stock: 9, hsncode: '1101', tax_rate: 5, quickCode: 'R51'),
      Product(id: 'c', name: 'R5 Cleaner', description: '', price: 90, stock: 9, hsncode: '3402', tax_rate: 18),
      Product(id: 'd', name: 'Tea 500 g', description: 'premium r5 blend', price: 260, stock: 9, hsncode: '0902', tax_rate: 5, quickCode: '101'),
      Product(id: 'e', name: 'Sugar 100% pure', description: '', price: 245, stock: 9, hsncode: '1701', tax_rate: 5),
    ]) {
      await ProductService.insertProduct(p);
    }
  });

  test('quick code is saved and read back', () async {
    final p = (await ProductService.getProductById('a'))!;
    expect(p.quickCode, 'R5');
    final none = (await ProductService.getProductById('c'))!;
    expect(none.quickCode, isNull);
  });

  test('exact code first, then code prefix, then name match (invoice search)', () async {
    final r = await ProductService.getProductsPaginated(offset: 0, limit: 10, query: 'r5');
    expect(r.map((p) => p.id).take(3), ['a', 'b', 'c']);
    expect(r.map((p) => p.id), contains('d')); // description match still found, last
    expect(r.last.id, 'd');
  });

  test('numeric code finds its product first', () async {
    final r = await ProductService.getProductsPaginated(offset: 0, limit: 10, query: '101');
    expect(r.first.id, 'd');
  });

  test('products list search matches quick codes', () async {
    final r = await ProductService.getProductsPaginated(offset: 0, limit: 10, query: 'R51');
    expect(r.single.id, 'b');
    expect(await ProductService.getProductCount('R51'), 1);
  });

  test('% and _ in a search are literal, not wildcards', () async {
    final r = await ProductService.getProductsPaginated(offset: 0, limit: 10, query: '100%');
    expect(r.single.id, 'e');
  });

  test('uniqueness is case-insensitive and ignores the product itself', () async {
    expect(await ProductQuickCode.isTaken('r5'), isTrue);
    expect(await ProductQuickCode.isTaken('R5', excludeProductId: 'a'), isFalse);
    expect(await ProductQuickCode.isTaken('Z9'), isFalse);
    expect(await ProductQuickCode.isTaken(''), isFalse);
  });

  test('format: up to 12 letters, digits or -', () {
    expect(ProductQuickCode.formatIssue(''), isNull);
    expect(ProductQuickCode.formatIssue('R-5'), isNull);
    expect(ProductQuickCode.formatIssue('R 5'), 'invalid');
    expect(ProductQuickCode.formatIssue('ABCDEFGHIJKLM'), 'tooLong');
  });

  test('suggestions come from the name and are unique', () async {
    expect(await ProductQuickCode.suggest('Toor Dal 1 kg'), 'TD1K');
    // "R5" is taken by product a -> next free variant
    expect(await ProductQuickCode.suggest('Rice 5'), 'R52');
  });

  test('blank code is stored as null', () async {
    await ProductService.insertProduct(Product(
        id: 'f', name: 'Salt', description: '', price: 20, stock: 1, hsncode: '', tax_rate: 0, quickCode: '  '));
    expect((await ProductService.getProductById('f'))!.quickCode, isNull);
  });
}
