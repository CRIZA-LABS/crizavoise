import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:crizavoise/database/database_helper.dart';
import 'package:crizavoise/database/recovery_code_service.dart';
import 'package:crizavoise/database/user_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: DatabaseHelper().dbVersion,
      onCreate: (db, v) => DatabaseHelper().createDbForTest(db, v),
    );
    DatabaseHelper.setTestDatabase(db);
  });
  tearDown(() async {
    DatabaseHelper.setTestDatabase(null);
    await db.close();
  });

  test('codes are 16 Crockford characters in groups of four', () {
    final c = RecoveryCodeService.generate();
    expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}(-[0-9A-HJKMNP-TV-Z]{4}){3}$').hasMatch(c), isTrue);
    expect(RecoveryCodeService.generate(), isNot(c));
  });

  test('the default admin starts without a code', () async {
    final admin = await UserService.getUserByUsername('admin');
    expect(admin, isNotNull);
    expect(await RecoveryCodeService.hasCode(admin!.id), isFalse);
  });

  test('code is stored hashed and verifies with typing slips', () async {
    final admin = (await UserService.getUserByUsername('admin'))!;
    final code = await RecoveryCodeService.createFor(admin.id);
    final row = (await db.query('users', where: 'id = ?', whereArgs: [admin.id])).first;
    expect(row['recovery_hash'], isNot(contains(code.replaceAll('-', ''))));
    expect(await RecoveryCodeService.hasCode(admin.id), isTrue);

    final typed = code.toLowerCase().replaceAll('-', ' ').replaceAll('0', 'o');
    expect((await RecoveryCodeService.verify('ADMIN', typed))?.id, admin.id);
  });

  test('wrong code, wrong user, cleared or replaced code all fail', () async {
    final admin = (await UserService.getUserByUsername('admin'))!;
    final first = await RecoveryCodeService.createFor(admin.id);
    expect(await RecoveryCodeService.verify('admin', 'AAAA-BBBB-CCCC-DDDD'), isNull);
    expect(await RecoveryCodeService.verify('nobody', first), isNull);

    final second = await RecoveryCodeService.createFor(admin.id);
    expect(await RecoveryCodeService.verify('admin', first), isNull);
    expect(await RecoveryCodeService.verify('admin', second), isNotNull);

    await RecoveryCodeService.clear(admin.id);
    expect(await RecoveryCodeService.verify('admin', second), isNull);
    expect(await RecoveryCodeService.hasCode(admin.id), isFalse);
  });
}
