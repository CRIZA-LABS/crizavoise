import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:crizavoise/migration/legacy_data_migration.dart';

void main() {
  late Directory root;
  late Directory legacy;
  late Directory fresh;

  LegacyDataMigration migration() =>
      LegacyDataMigration(newDir: fresh, legacyCandidates: [legacy]);

  Future<void> seedLegacy() async {
    await legacy.create(recursive: true);
    await File(p.join(legacy.path, 'invoice_manager.db')).writeAsString('db-v1');
    await File(p.join(legacy.path, 'invoice_manager.db-wal')).writeAsString('wal');
    await File(p.join(legacy.path, 'shared_preferences.json'))
        .writeAsString('{"flutter.active_company_id":"default"}');
    await Directory(p.join(legacy.path, 'backups', 'default')).create(recursive: true);
    await File(p.join(legacy.path, 'backups', 'default', 'b1.json')).writeAsString('{}');
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cv_migration_');
    // The legacy folder name is the one the original Windows build used
    // (see LegacyAppPaths); the test only needs any separate directory.
    legacy = Directory(p.join(root.path, 'old', LegacyAppPaths.windowsCompany,
        LegacyAppPaths.windowsProduct));
    fresh = Directory(p.join(root.path, 'new', 'Criza Labs', 'CrizaVoise'));
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('no legacy data: nothing happens', () async {
    expect(await migration().runCopyPhase(), MigrationStatus.none);
    expect(await File(p.join(fresh.path, LegacyDataMigration.markerFileName)).exists(),
        isFalse);
  });

  test('copies legacy data, writes a backup zip, keeps the old dir', () async {
    await seedLegacy();
    final m = migration();

    expect(await m.runCopyPhase(), MigrationStatus.copied);

    expect(await File(p.join(fresh.path, 'invoice_manager.db')).readAsString(), 'db-v1');
    expect(await File(p.join(fresh.path, 'invoice_manager.db-wal')).exists(), isTrue);
    expect(await File(p.join(fresh.path, 'shared_preferences.json')).exists(), isTrue);
    expect(await File(p.join(fresh.path, 'backups', 'default', 'b1.json')).exists(), isTrue);

    final zips = Directory(p.join(fresh.path, 'backups'))
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList();
    expect(zips, hasLength(1));
    expect(await zips.single.length(), greaterThan(0));

    // Copy only — the legacy dir must still be intact at this point.
    expect(await File(p.join(legacy.path, 'invoice_manager.db')).exists(), isTrue);
    expect(await File(p.join(fresh.path, LegacyDataMigration.logFileName)).exists(), isTrue);
  });

  test('deletes the legacy dir only after a successful open, then is done',
      () async {
    await seedLegacy();
    final m = migration();
    await m.runCopyPhase();

    expect(await m.finalizeAfterSuccessfulOpen(), MigrationStatus.done);
    expect(await legacy.exists(), isFalse);
    // The backup zip survives the cleanup.
    final zips = Directory(p.join(fresh.path, 'backups'))
        .listSync()
        .where((e) => e.path.endsWith('.zip'));
    expect(zips, isNotEmpty);

    // Later launches are no-ops.
    expect(await m.runCopyPhase(), MigrationStatus.done);
    expect(await m.finalizeAfterSuccessfulOpen(), MigrationStatus.done);
  });

  test('keeps the legacy dir if the backup zip went missing', () async {
    await seedLegacy();
    final m = migration();
    await m.runCopyPhase();
    for (final f in Directory(p.join(fresh.path, 'backups')).listSync()) {
      if (f.path.endsWith('.zip')) await f.delete();
    }

    expect(await m.finalizeAfterSuccessfulOpen(), MigrationStatus.copied);
    expect(await legacy.exists(), isTrue);
  });

  test('never overwrites existing CrizaVoise data', () async {
    await seedLegacy();
    await fresh.create(recursive: true);
    await File(p.join(fresh.path, 'invoice_manager.db')).writeAsString('db-new');

    final m = migration();
    expect(await m.runCopyPhase(), MigrationStatus.skipped);
    expect(await File(p.join(fresh.path, 'invoice_manager.db')).readAsString(), 'db-new');
    expect(await legacy.exists(), isTrue);

    // A skipped migration never deletes anything.
    expect(await m.finalizeAfterSuccessfulOpen(), MigrationStatus.skipped);
    expect(await legacy.exists(), isTrue);
  });
}
