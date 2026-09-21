import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database/app_database.dart';

/// How many date-stamped backups are kept.
const kBackupsToKeep = 7;

/// Copies the database into `<appSupport>/backups/lernapp-YYYY-MM-DD.sqlite`
/// and prunes everything but the [kBackupsToKeep] newest copies.
///
/// Uses `VACUUM INTO` instead of a file copy so the snapshot is consistent even
/// though the database is already open. Called once on app start.
Future<File?> createStartupBackup(AppDatabase db) async {
  final supportDir = await getApplicationSupportDirectory();
  final backupDir = Directory(p.join(supportDir.path, 'backups'));
  await backupDir.create(recursive: true);

  // Force the database file to exist before snapshotting it.
  await db.customSelect('SELECT 1').get();

  final stamp = DateTime.now().toUtc().toIso8601String().substring(0, 10);
  final target = File(p.join(backupDir.path, 'lernapp-$stamp.sqlite'));
  if (target.existsSync()) {
    await target.delete();
  }

  try {
    await db.customStatement(
      "VACUUM INTO '${target.path.replaceAll("'", "''")}'",
    );
  } on Object {
    // A failed backup must never keep the app from starting.
    return null;
  }

  await _pruneBackups(backupDir);
  return target;
}

Future<void> _pruneBackups(Directory backupDir) async {
  final backups = backupDir
      .listSync()
      .whereType<File>()
      .where((f) => p.basename(f.path).startsWith('lernapp-'))
      .toList()
    // Date-stamped names sort chronologically, newest first.
    ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));

  for (final stale in backups.skip(kBackupsToKeep)) {
    await stale.delete();
  }
}
