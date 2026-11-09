import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:crizavoise/utils/app_logger.dart';

const _tag = 'LegacyDataMigration';

/// Where builds of the original app stored their data before the CrizaVoise
/// rename changed the app ID / publisher. These are internal path fragments
/// used only to find and import an existing user's data — never shown in the
/// UI. (They are the only "legacy name" strings allowed outside
/// THIRD_PARTY_NOTICES.md; see CLAUDE.md.)
class LegacyAppPaths {
  /// Windows: `%APPDATA%\CompanyName\ProductName` from the old Runner.rc.
  static const windowsCompany = 'anoopp';
  static const windowsProduct = 'invoiso';

  /// Linux: `$XDG_DATA_HOME/APPLICATION_ID`, plus the executable-name folder
  /// used by older path_provider versions.
  static const linuxAppIds = ['com.anooppandikashala.invoiso', 'invoiso'];

  /// macOS bundle identifier.
  static const macBundleId = 'com.example.invoiso';
}

/// What happened during the copy phase, persisted in [markerFileName].
enum MigrationStatus { none, copied, done, skipped, failed }

/// One-time import of the original app's data directory into CrizaVoise's.
///
/// 1. [runCopyPhase] (before anything opens the database or
///    SharedPreferences): zips the legacy dir into `backups/`, then COPIES it
///    into the new dir. The legacy dir is left untouched.
/// 2. [finalizeAfterSuccessfulOpen] (after the database opened fine on this
///    launch): deletes the legacy dir and marks the migration done.
///
/// Every step is appended to `migration.log` in the new dir.
class LegacyDataMigration {
  static const markerFileName = '.cv_migration.json';
  static const logFileName = 'migration.log';

  final Directory newDir;
  final List<Directory> legacyCandidates;
  final DateTime Function() _now;

  LegacyDataMigration({
    required this.newDir,
    required this.legacyCandidates,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Builds the migration for the running platform.
  static Future<LegacyDataMigration> forCurrentPlatform() async {
    final newDir = await getApplicationSupportDirectory();
    return LegacyDataMigration(
      newDir: newDir,
      legacyCandidates: legacyDirsForPlatform(newDir),
    );
  }

  static List<Directory> legacyDirsForPlatform(Directory newDir) {
    final home = Platform.environment['HOME'] ?? '';
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData == null) return const [];
      return [
        Directory(p.join(appData, LegacyAppPaths.windowsCompany,
            LegacyAppPaths.windowsProduct)),
      ];
    }
    if (Platform.isLinux) {
      final dataHome = Platform.environment['XDG_DATA_HOME'] ??
          p.join(home, '.local', 'share');
      return [for (final id in LegacyAppPaths.linuxAppIds) Directory(p.join(dataHome, id))];
    }
    if (Platform.isMacOS) {
      const id = LegacyAppPaths.macBundleId;
      return [
        Directory(p.join(home, 'Library', 'Application Support', id)),
        Directory(p.join(home, 'Library', 'Containers', id, 'Data', 'Library',
            'Application Support', id)),
      ];
    }
    return const []; // Android/iOS: new app ID = new sandbox; use Backup → Restore.
  }

  File get _marker => File(p.join(newDir.path, markerFileName));
  File get _logFile => File(p.join(newDir.path, logFileName));

  Future<Map<String, dynamic>> _readMarker() async {
    try {
      if (await _marker.exists()) {
        return jsonDecode(await _marker.readAsString()) as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.w(_tag, 'Unreadable marker: $e');
    }
    return {};
  }

  Future<MigrationStatus> status() async {
    final m = await _readMarker();
    return MigrationStatus.values.firstWhere((s) => s.name == m['status'],
        orElse: () => MigrationStatus.none);
  }

  Future<void> _writeMarker(MigrationStatus status, Map<String, Object?> extra) async {
    final m = await _readMarker()
      ..addAll(extra)
      ..['status'] = status.name
      ..['updatedAt'] = _now().toIso8601String();
    await _marker.writeAsString(const JsonEncoder.withIndent('  ').convert(m));
  }

  Future<void> _log(String message) async {
    AppLogger.d(_tag, message);
    try {
      await _logFile.writeAsString('${_now().toIso8601String()}  $message\n',
          mode: FileMode.append, flush: true);
    } catch (_) {/* logging must never break startup */}
  }

  static Future<bool> _hasDatabase(Directory dir) async {
    if (!await dir.exists()) return false;
    await for (final e in dir.list()) {
      final name = p.basename(e.path);
      if (e is File && name.startsWith('invoice_manager') && name.endsWith('.db')) {
        return true;
      }
    }
    return false;
  }

  Future<Directory?> _findLegacyDir() async {
    for (final d in legacyCandidates) {
      if (p.equals(d.path, newDir.path)) continue;
      if (await _hasDatabase(d)) return d;
    }
    return null;
  }

  /// Copy phase. Safe to call on every launch; does nothing once a marker
  /// exists or when there is nothing to import.
  Future<MigrationStatus> runCopyPhase() async {
    try {
      await newDir.create(recursive: true);
      final current = await status();
      if (current != MigrationStatus.none) return current;

      final legacy = await _findLegacyDir();
      if (legacy == null) return MigrationStatus.none;

      if (await _hasDatabase(newDir)) {
        await _log('Skipped: CrizaVoise data already exists; legacy data at '
            '${legacy.path} left untouched.');
        await _writeMarker(MigrationStatus.skipped, {'from': legacy.path});
        return MigrationStatus.skipped;
      }

      await _log('Found legacy data at ${legacy.path}');

      // 1) Safety net: zip the untouched legacy dir into backups/.
      final backups = Directory(p.join(newDir.path, 'backups'));
      await backups.create(recursive: true);
      final stamp = _now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final zipPath = p.join(backups.path, 'pre-crizavoise-import-$stamp.zip');
      await ZipFileEncoder().zipDirectory(legacy, filename: zipPath);
      await _log('Backup zip written: $zipPath');

      // 2) Copy (never overwrite anything already in the new dir).
      final copied = await _copyTree(legacy, newDir);
      await _log('Copied $copied file(s) into ${newDir.path}');

      await _writeMarker(MigrationStatus.copied, {
        'from': legacy.path,
        'backupZip': zipPath,
        'filesCopied': copied,
        'copiedAt': _now().toIso8601String(),
      });
      return MigrationStatus.copied;
    } catch (e, st) {
      AppLogger.e(_tag, 'Copy phase failed', e, st);
      await _log('FAILED during copy: $e — legacy data left untouched.');
      try {
        await _writeMarker(MigrationStatus.failed, {'error': '$e'});
      } catch (_) {}
      return MigrationStatus.failed;
    }
  }

  /// Call after the database has opened successfully on this launch. Deletes
  /// the legacy dir only if this install copied it and the copy is verified.
  Future<MigrationStatus> finalizeAfterSuccessfulOpen() async {
    try {
      final m = await _readMarker();
      if (m['status'] != MigrationStatus.copied.name) return await status();
      final from = m['from'] as String?;
      if (from == null) return MigrationStatus.copied;
      final legacy = Directory(from);

      if (!await _hasDatabase(newDir)) {
        await _log('Not deleting ${legacy.path}: no database in the new dir.');
        return MigrationStatus.copied;
      }
      final zip = m['backupZip'] as String?;
      if (zip == null || !await File(zip).exists()) {
        await _log('Not deleting ${legacy.path}: backup zip missing.');
        return MigrationStatus.copied;
      }

      if (await legacy.exists()) await legacy.delete(recursive: true);
      // Remove the now-empty Windows publisher folder too.
      final parent = legacy.parent;
      if (Platform.isWindows &&
          p.basename(parent.path) == LegacyAppPaths.windowsCompany &&
          await parent.exists() &&
          await parent.list().isEmpty) {
        await parent.delete();
      }
      await _log('Database opened fine; deleted legacy dir ${legacy.path}. '
          'Backup kept at $zip');
      await _writeMarker(MigrationStatus.done, {'deletedAt': _now().toIso8601String()});
      return MigrationStatus.done;
    } catch (e, st) {
      AppLogger.e(_tag, 'Finalize failed', e, st);
      await _log('Could not delete legacy dir yet ($e); will retry next launch.');
      return MigrationStatus.copied;
    }
  }

  static Future<int> _copyTree(Directory from, Directory to) async {
    var count = 0;
    await for (final entity in from.list(recursive: true, followLinks: false)) {
      final rel = p.relative(entity.path, from: from.path);
      final target = p.join(to.path, rel);
      if (entity is Directory) {
        await Directory(target).create(recursive: true);
      } else if (entity is File) {
        final dest = File(target);
        if (await dest.exists()) continue;
        await dest.parent.create(recursive: true);
        await entity.copy(target);
        count++;
      }
    }
    return count;
  }
}
