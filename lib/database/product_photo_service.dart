import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import 'package:crizavoise/database/database_helper.dart';

/// Product photos, stored apart from products and cached in memory once
/// shown, so lists and search never pay for image data they don't draw.
class ProductPhotoService {
  ProductPhotoService._();

  // productId -> bytes, or null when known to have no photo.
  static final Map<String, Uint8List?> _cache = {};
  static Set<String>? _idsWithPhoto;

  /// Bumped on every change so widgets showing photos can rebuild.
  static int version = 0;

  static Future<Set<String>> idsWithPhoto() async {
    if (_idsWithPhoto != null) return _idsWithPhoto!;
    final db = await DatabaseHelper().database;
    final rows = await db.query('product_photos', columns: ['product_id']);
    return _idsWithPhoto = rows.map((r) => r['product_id'] as String).toSet();
  }

  static Future<Uint8List?> get(String productId) async {
    if (_cache.containsKey(productId)) return _cache[productId];
    final ids = await idsWithPhoto();
    if (!ids.contains(productId)) return _cache[productId] = null;
    final db = await DatabaseHelper().database;
    final rows = await db.query('product_photos',
        columns: ['photo'], where: 'product_id = ?', whereArgs: [productId], limit: 1);
    final bytes = rows.isEmpty ? null : base64Decode(rows.first['photo'] as String);
    return _cache[productId] = bytes;
  }

  static Future<void> set(String productId, Uint8List bytes) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      'product_photos',
      {
        'product_id': productId,
        'photo': base64Encode(bytes),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _cache[productId] = bytes;
    (await idsWithPhoto()).add(productId);
    version++;
  }

  static Future<void> remove(String productId) async {
    final db = await DatabaseHelper().database;
    await db.delete('product_photos', where: 'product_id = ?', whereArgs: [productId]);
    _cache[productId] = null;
    _idsWithPhoto?.remove(productId);
    version++;
  }

  /// After a restore or a company switch.
  static void clearCache() {
    _cache.clear();
    _idsWithPhoto = null;
    version++;
  }
}
