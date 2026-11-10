import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/product_photo_service.dart';
import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/models/product.dart';
import 'package:crizavoise/services/image_import_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath,
        version: DatabaseHelper().dbVersion,
        onCreate: (db, v) => DatabaseHelper().createDbForTest(db, v));
    DatabaseHelper.setTestDatabase(db);
  });
  tearDown(() async {
    DatabaseHelper.setTestDatabase(null);
    await db.close();
  });

  test('big phone photo becomes a small JPEG (400 px)', () {
    final photo = img.Image(width: 3000, height: 2000);
    img.fill(photo, color: img.ColorRgb8(200, 120, 40));
    final r = ImageImportService.processSync(
        Uint8List.fromList(img.encodePng(photo)), ImageKind.productPhoto)!;
    expect(r.width, 400);
    expect(r.height, 267);
    expect(r.bytes.sublist(0, 2), [0xFF, 0xD8], reason: 'JPEG');
    expect(r.bytes.length, lessThan(40 * 1024));
  });

  test('set, read, cache, remove; deleted with the product', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    expect(await ProductPhotoService.get('p1'), isNull);
    await ProductPhotoService.set('p1', bytes);
    expect(await ProductPhotoService.get('p1'), bytes);

    ProductPhotoService.clearCache();
    expect(await ProductPhotoService.get('p1'), bytes, reason: 'reloaded from the database');

    await ProductPhotoService.remove('p1');
    expect(await ProductPhotoService.get('p1'), isNull);

    await ProductService.insertProduct(Product(
        id: 'p2', name: 'Tea', description: '', price: 1, stock: 1, hsncode: '', tax_rate: 0));
    await ProductPhotoService.set('p2', bytes);
    await ProductService.deleteProduct('p2');
    expect(await db.query('product_photos'), isEmpty);
  });
}
