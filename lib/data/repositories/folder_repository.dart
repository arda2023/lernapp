import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/ids.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

part 'folder_repository.g.dart';

/// The only place that reads or writes the `folders` table.
///
/// Every query filters out soft-deleted rows; timestamps are written in UTC.
class FolderRepository {
  FolderRepository(this._db);

  final AppDatabase _db;

  /// Live list of the children of [parentId] (`null` = library root),
  /// ordered by `sortIndex`.
  Stream<List<Folder>> watchChildren(String? parentId) {
    return (_db.select(_db.folders)
          ..where((f) => f.deletedAt.isNull())
          ..where(
            (f) => parentId == null
                ? f.parentId.isNull()
                : f.parentId.equals(parentId),
          )
          ..orderBy([(f) => OrderingTerm(expression: f.sortIndex)]))
        .watch();
  }

  /// Live list of every folder in the tree, ordered by `sortIndex`.
  Stream<List<Folder>> watchAll() {
    return (_db.select(_db.folders)
          ..where((f) => f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm(expression: f.sortIndex)]))
        .watch();
  }

  Future<Folder?> findById(String id) {
    return (_db.select(_db.folders)
          ..where((f) => f.id.equals(id) & f.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Folder> create({required String title, String? parentId}) async {
    final now = DateTime.now().toUtc();
    return _db.into(_db.folders).insertReturning(
          FoldersCompanion.insert(
            id: newId(),
            parentId: Value(parentId),
            title: title,
            sortIndex: Value(await _nextSortIndex(parentId)),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> rename(String id, String title) {
    return _update(id, FoldersCompanion(title: Value(title)));
  }

  /// Moves the folder under [parentId] (`null` = library root) and appends it
  /// to the end of its new sibling list unless [sortIndex] is given.
  Future<void> move({
    required String id,
    String? parentId,
    int? sortIndex,
  }) async {
    final index = sortIndex ?? await _nextSortIndex(parentId);
    return _update(
      id,
      FoldersCompanion(parentId: Value(parentId), sortIndex: Value(index)),
    );
  }

  Future<void> setExpanded(String id, bool isExpanded) {
    return _update(id, FoldersCompanion(isExpanded: Value(isExpanded)));
  }

  /// Writes `sortIndex` for a sibling list in the order given.
  Future<void> reorder(List<String> orderedIds) {
    return _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await _update(orderedIds[i], FoldersCompanion(sortIndex: Value(i)));
      }
    });
  }

  /// Soft-deletes the folder plus every descendant folder and document.
  Future<void> softDelete(String id) {
    return _db.transaction(() async {
      final now = DateTime.now().toUtc();
      final ids = await _subtreeIds(id);

      await (_db.update(_db.folders)
            ..where((f) => f.id.isIn(ids) & f.deletedAt.isNull()))
          .write(FoldersCompanion(deletedAt: Value(now), updatedAt: Value(now)));

      await (_db.update(_db.documents)
            ..where((d) => d.folderId.isIn(ids) & d.deletedAt.isNull()))
          .write(
        DocumentsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    });
  }

  /// [id] plus all of its live descendants, breadth-first.
  Future<List<String>> _subtreeIds(String id) async {
    final collected = <String>[id];
    var frontier = <String>[id];

    while (frontier.isNotEmpty) {
      final children = await (_db.select(_db.folders)
            ..where((f) => f.parentId.isIn(frontier) & f.deletedAt.isNull()))
          .get();
      frontier = children.map((f) => f.id).toList();
      collected.addAll(frontier);
    }
    return collected;
  }

  Future<int> _nextSortIndex(String? parentId) async {
    final max = _db.folders.sortIndex.max();
    final query = _db.selectOnly(_db.folders)
      ..addColumns([max])
      ..where(
        _db.folders.deletedAt.isNull() &
            (parentId == null
                ? _db.folders.parentId.isNull()
                : _db.folders.parentId.equals(parentId)),
      );
    final current = await query.map((row) => row.read(max)).getSingle();
    return current == null ? 0 : current + 1;
  }

  Future<void> _update(String id, FoldersCompanion changes) async {
    await (_db.update(_db.folders)
          ..where((f) => f.id.equals(id) & f.deletedAt.isNull()))
        .write(
      changes.copyWith(updatedAt: Value(DateTime.now().toUtc())),
    );
  }
}

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  return FolderRepository(ref.watch(appDatabaseProvider));
}
