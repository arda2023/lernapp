import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../tables/documents.dart';
import '../tables/folders.dart';

part 'app_database.g.dart';

/// File name (without directory) of the production database.
const kDatabaseName = 'lernapp';
const kDatabaseFileName = '$kDatabaseName.sqlite';

@DriftDatabase(tables: [Folders, Documents])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the production database in the application support directory.
  AppDatabase.file()
      : super(
          driftDatabase(
            name: kDatabaseName,
            native: DriftNativeOptions(
              databaseDirectory: getApplicationSupportDirectory,
            ),
          ),
        );

  @override
  int get schemaVersion => 1;

  /// Timestamps are stored as ISO-8601 UTC text so they survive timezone
  /// changes; see ARCHITECTURE.md.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Schema v1 is the initial version; no upgrades exist yet.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
