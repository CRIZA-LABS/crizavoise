import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/models/user.dart';
import 'package:crizavoise/utils/password_utils.dart';

enum PinCheck { ok, wrong, locked }

/// Quick sign-in with a 4–6 digit PIN, set by each person for themselves.
///
/// A PIN is a convenience on top of the password, not a replacement: after
/// [maxFailures] wrong PINs it stops working until that person signs in with
/// their password once. Only a salted hash is stored.
class PinService {
  PinService._();

  static const maxFailures = 5;
  static final _pinPattern = RegExp(r'^\d{4,6}$');

  static bool isValidPin(String pin) => _pinPattern.hasMatch(pin);

  /// Rejects PINs that are too easy to guess (1111, 1234, 4321…).
  static bool isTooSimple(String pin) {
    if (pin.split('').toSet().length == 1) return true;
    const up = '01234567890', down = '09876543210';
    return up.contains(pin) || down.contains(pin);
  }

  static Future<void> setPin(String userId, String pin) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN must be 4–6 digits');
    final salt = PasswordUtils.generateSalt();
    final db = await DatabaseHelper().database;
    await db.update(
      'users',
      {'pin_hash': PasswordUtils.hashWithSalt(pin, salt), 'pin_salt': salt, 'pin_failures': 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  static Future<void> clearPin(String userId) async {
    final db = await DatabaseHelper().database;
    await db.update('users', {'pin_hash': null, 'pin_salt': null, 'pin_failures': 0},
        where: 'id = ?', whereArgs: [userId]);
  }

  static Future<bool> hasPin(String userId) async {
    final db = await DatabaseHelper().database;
    final rows =
        await db.query('users', columns: ['pin_hash'], where: 'id = ?', whereArgs: [userId]);
    return rows.isNotEmpty && (rows.first['pin_hash'] as String?)?.isNotEmpty == true;
  }

  /// People who can use quick sign-in on this company, for the avatar row.
  static Future<List<User>> usersWithPin() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('users',
        where: "pin_hash IS NOT NULL AND pin_hash != ''", orderBy: 'username COLLATE NOCASE');
    return rows.map(User.fromMap).toList();
  }

  static Future<bool> isLocked(String userId) async {
    final db = await DatabaseHelper().database;
    final rows =
        await db.query('users', columns: ['pin_failures'], where: 'id = ?', whereArgs: [userId]);
    return rows.isNotEmpty && ((rows.first['pin_failures'] as int?) ?? 0) >= maxFailures;
  }

  /// Wrong PINs left before the lock.
  static Future<int> attemptsLeft(String userId) async {
    final db = await DatabaseHelper().database;
    final rows =
        await db.query('users', columns: ['pin_failures'], where: 'id = ?', whereArgs: [userId]);
    final f = rows.isEmpty ? maxFailures : ((rows.first['pin_failures'] as int?) ?? 0);
    return (maxFailures - f).clamp(0, maxFailures);
  }

  static Future<PinCheck> verify(String userId, String pin) async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) return PinCheck.wrong;
    final r = rows.first;
    final failures = (r['pin_failures'] as int?) ?? 0;
    if (failures >= maxFailures) return PinCheck.locked;
    final hash = r['pin_hash'] as String?, salt = r['pin_salt'] as String?;
    if (hash == null || salt == null) return PinCheck.wrong;
    if (PasswordUtils.hashWithSalt(pin, salt) == hash) {
      if (failures != 0) await resetFailures(userId);
      return PinCheck.ok;
    }
    await db.rawUpdate(
        'UPDATE users SET pin_failures = pin_failures + 1 WHERE id = ?', [userId]);
    return failures + 1 >= maxFailures ? PinCheck.locked : PinCheck.wrong;
  }

  /// Called after a successful password sign-in: unlocks the PIN again.
  static Future<void> resetFailures(String userId) async {
    final db = await DatabaseHelper().database;
    await db.update('users', {'pin_failures': 0}, where: 'id = ?', whereArgs: [userId]);
  }
}
