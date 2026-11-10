import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/pin_service.dart';
import 'package:crizavoise/database/user_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late String adminId;
  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath,
        version: DatabaseHelper().dbVersion,
        onCreate: (db, v) => DatabaseHelper().createDbForTest(db, v));
    DatabaseHelper.setTestDatabase(db);
    adminId = (await UserService.getUserByUsername('admin'))!.id;
  });
  tearDown(() async {
    DatabaseHelper.setTestDatabase(null);
    await db.close();
  });

  test('PIN rules', () {
    expect(PinService.isValidPin('1234'), isTrue);
    expect(PinService.isValidPin('123456'), isTrue);
    expect(PinService.isValidPin('123'), isFalse);
    expect(PinService.isValidPin('12a4'), isFalse);
    expect(PinService.isTooSimple('1111'), isTrue);
    expect(PinService.isTooSimple('1234'), isTrue);
    expect(PinService.isTooSimple('9876'), isTrue);
    expect(PinService.isTooSimple('2580'), isFalse);
  });

  test('set, verify, list and remove', () async {
    expect(await PinService.usersWithPin(), isEmpty);
    await PinService.setPin(adminId, '2580');
    expect(await PinService.hasPin(adminId), isTrue);
    expect((await PinService.usersWithPin()).single.username, 'admin');
    expect(await PinService.verify(adminId, '2580'), PinCheck.ok);
    final row = (await db.query('users', where: 'id = ?', whereArgs: [adminId])).first;
    expect(row['pin_hash'], isNot('2580'));
    await PinService.clearPin(adminId);
    expect(await PinService.usersWithPin(), isEmpty);
  });

  test('locks after 5 wrong PINs; a password sign-in unlocks', () async {
    await PinService.setPin(adminId, '2580');
    for (var i = 0; i < 4; i++) {
      expect(await PinService.verify(adminId, '0000'), PinCheck.wrong);
    }
    expect(await PinService.attemptsLeft(adminId), 1);
    expect(await PinService.verify(adminId, '0000'), PinCheck.locked);
    expect(await PinService.verify(adminId, '2580'), PinCheck.locked,
        reason: 'even the right PIN is refused while locked');
    await PinService.resetFailures(adminId);
    expect(await PinService.verify(adminId, '2580'), PinCheck.ok);
  });

  test('a correct PIN clears earlier wrong tries', () async {
    await PinService.setPin(adminId, '2580');
    await PinService.verify(adminId, '0000');
    await PinService.verify(adminId, '2580');
    expect(await PinService.attemptsLeft(adminId), PinService.maxFailures);
  });
}
