import 'dart:math';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/utils/password_utils.dart';

/// Personal recovery codes for "Forgot password", fully offline.
///
/// Each account can have one code (e.g. `K7QM-2XPA-9DWE-4HTC`, 80 random
/// bits). Only a salted hash is stored. A code works once: using it to set a
/// new password replaces it with a fresh one that's shown to the person.
class RecoveryCodeService {
  RecoveryCodeService._();

  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'; // no I, L, O, U

  /// A new random code, formatted in groups of four.
  static String generate([Random? random]) {
    final r = random ?? Random.secure();
    final chars = List.generate(16, (_) => _alphabet[r.nextInt(32)]).join();
    return [for (var i = 0; i < 16; i += 4) chars.substring(i, i + 4)].join('-');
  }

  /// Ignores case, spaces, dashes and the look-alikes O/0 and I/L/1.
  static String normalize(String code) => code
      .toUpperCase()
      .replaceAll(RegExp(r'[\s-]'), '')
      .replaceAll('O', '0')
      .replaceAll(RegExp('[IL]'), '1');

  /// Creates (or replaces) the code for [userId] and returns it in plain
  /// text: the only time it exists unhashed.
  static Future<String> createFor(String userId) async {
    final code = generate();
    final salt = PasswordUtils.generateSalt();
    final db = await DatabaseHelper().database;
    await db.update(
      'users',
      {'recovery_hash': PasswordUtils.hashWithSalt(normalize(code), salt), 'recovery_salt': salt},
      where: 'id = ?',
      whereArgs: [userId],
    );
    return code;
  }

  static Future<void> clear(String userId) async {
    final db = await DatabaseHelper().database;
    await db.update('users', {'recovery_hash': null, 'recovery_salt': null},
        where: 'id = ?', whereArgs: [userId]);
  }

  static Future<bool> hasCode(String userId) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('users',
        columns: ['recovery_hash'], where: 'id = ?', whereArgs: [userId]);
    return rows.isNotEmpty && (rows.first['recovery_hash'] as String?)?.isNotEmpty == true;
  }

  /// The account for [username] if [code] is its recovery code, else null.
  static Future<User?> verify(String username, String code) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('users',
        where: 'username = ? COLLATE NOCASE', whereArgs: [username.trim()], limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final hash = row['recovery_hash'] as String?;
    final salt = row['recovery_salt'] as String?;
    if (hash == null || salt == null || hash.isEmpty) return null;
    final given = PasswordUtils.hashWithSalt(normalize(code), salt);
    if (!_constantTimeEquals(given, hash)) return null;
    return User.fromMap(row);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
