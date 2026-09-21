import 'package:drift/drift.dart';

/// Tree of library folders. `parentId == null` means the folder sits at the
/// library root. Rows are never hard-deleted; see `deletedAt`.
class Folders extends Table {
  /// Client-generated UUID v4.
  TextColumn get id => text()();

  TextColumn get parentId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  BoolColumn get isExpanded => boolean().withDefault(const Constant(false))();

  /// UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// UTC.
  DateTimeColumn get updatedAt => dateTime()();

  /// UTC. Non-null marks the row as soft-deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
