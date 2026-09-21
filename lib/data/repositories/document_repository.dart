import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/ids.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../tables/documents.dart';

part 'document_repository.g.dart';

/// The only place that reads or writes the `documents` table.
///
/// Every query filters out soft-deleted rows; timestamps are written in UTC.
class DocumentRepository {
  DocumentRepository(this._db);

  final AppDatabase _db;

  /// Live list of the documents inside [folderId] (`null` = library root),
  /// ordered by `sortIndex`.
  Stream<List<Document>> watchInFolder(String? folderId) {
    return (_db.select(_db.documents)
          ..where((d) => d.deletedAt.isNull())
          ..where(
            (d) => folderId == null
                ? d.folderId.isNull()
                : d.folderId.equals(folderId),
          )
          ..orderBy([(d) => OrderingTerm(expression: d.sortIndex)]))
        .watch();
  }

  /// Live list of every document, ordered by `sortIndex`.
  Stream<List<Document>> watchAll() {
    return (_db.select(_db.documents)
          ..where((d) => d.deletedAt.isNull())
          ..orderBy([(d) => OrderingTerm(expression: d.sortIndex)]))
        .watch();
  }

  Future<Document?> findById(String id) {
    return (_db.select(_db.documents)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Document> create({
    required String title,
    required DocumentKind kind,
    String? folderId,
  }) async {
    final now = DateTime.now().toUtc();
    return _db.into(_db.documents).insertReturning(
          DocumentsCompanion.insert(
            id: newId(),
            folderId: Value(folderId),
            title: title,
            kind: kind,
            sortIndex: Value(await _nextSortIndex(folderId)),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> rename(String id, String title) {
    return _update(id, DocumentsCompanion(title: Value(title)));
  }

  /// Moves the document into [folderId] (`null` = library root) and appends it
  /// to the end of that folder unless [sortIndex] is given.
  Future<void> move({
    required String id,
    String? folderId,
    int? sortIndex,
  }) async {
    final index = sortIndex ?? await _nextSortIndex(folderId);
    return _update(
      id,
      DocumentsCompanion(folderId: Value(folderId), sortIndex: Value(index)),
    );
  }

  /// Writes `sortIndex` for a sibling list in the order given.
  Future<void> reorder(List<String> orderedIds) {
    return _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await _update(orderedIds[i], DocumentsCompanion(sortIndex: Value(i)));
      }
    });
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.documents)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .write(
      DocumentsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<int> _nextSortIndex(String? folderId) async {
    final max = _db.documents.sortIndex.max();
    final query = _db.selectOnly(_db.documents)
      ..addColumns([max])
      ..where(
        _db.documents.deletedAt.isNull() &
            (folderId == null
                ? _db.documents.folderId.isNull()
                : _db.documents.folderId.equals(folderId)),
      );
    final current = await query.map((row) => row.read(max)).getSingle();
    return current == null ? 0 : current + 1;
  }

  Future<void> _update(String id, DocumentsCompanion changes) async {
    await (_db.update(_db.documents)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .write(
      changes.copyWith(updatedAt: Value(DateTime.now().toUtc())),
    );
  }
}

@Riverpod(keepAlive: true)
DocumentRepository documentRepository(Ref ref) {
  return DocumentRepository(ref.watch(appDatabaseProvider));
}
