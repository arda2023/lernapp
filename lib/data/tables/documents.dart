import 'package:drift/drift.dart';

import 'folders.dart';

/// Stored as the enum index; append new values at the end only.
enum DocumentKind { note, pdf }

/// Notes and PDFs. `folderId == null` means the document sits at the library
/// root. Rows are never hard-deleted; see `deletedAt`.
class Documents extends Table {
  /// Client-generated UUID v4.
  TextColumn get id => text()();

  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  IntColumn get kind => intEnum<DocumentKind>()();

  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  /// UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// UTC.
  DateTimeColumn get updatedAt => dateTime()();

  /// UTC. Non-null marks the row as soft-deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
