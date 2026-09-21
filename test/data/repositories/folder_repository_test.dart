import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lernapp/data/database/app_database.dart';
import 'package:lernapp/data/repositories/document_repository.dart';
import 'package:lernapp/data/repositories/folder_repository.dart';
import 'package:lernapp/data/tables/documents.dart';

void main() {
  late AppDatabase db;
  late FolderRepository folders;
  late DocumentRepository documents;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folders = FolderRepository(db);
    documents = DocumentRepository(db);
  });

  tearDown(() => db.close());

  test('create assigns a UUID, UTC timestamps and an appended sortIndex',
      () async {
    final first = await folders.create(title: 'Semester 1');
    final second = await folders.create(title: 'Semester 2');

    expect(first.id, hasLength(36));
    expect(first.parentId, isNull);
    expect(first.isExpanded, isFalse);
    expect(first.deletedAt, isNull);
    expect(first.createdAt.isUtc, isTrue);
    expect(first.updatedAt.isUtc, isTrue);
    expect(first.sortIndex, 0);
    expect(second.sortIndex, 1);
  });

  test('rename, move and setExpanded update the row', () async {
    final parent = await folders.create(title: 'Parent');
    final child = await folders.create(title: 'Child');

    await folders.rename(child.id, 'Renamed');
    await folders.move(id: child.id, parentId: parent.id);
    await folders.setExpanded(parent.id, true);

    final updatedChild = await folders.findById(child.id);
    expect(updatedChild!.title, 'Renamed');
    expect(updatedChild.parentId, parent.id);
    expect(updatedChild.updatedAt.isAfter(child.updatedAt), isTrue);
    expect((await folders.findById(parent.id))!.isExpanded, isTrue);
  });

  test('reorder writes sortIndex in the given order', () async {
    final a = await folders.create(title: 'A');
    final b = await folders.create(title: 'B');
    final c = await folders.create(title: 'C');

    await folders.reorder([c.id, a.id, b.id]);

    final ordered = await folders.watchChildren(null).first;
    expect(ordered.map((f) => f.title), ['C', 'A', 'B']);
  });

  test('soft delete cascades to descendant folders and documents', () async {
    final root = await folders.create(title: 'Root');
    final child = await folders.create(title: 'Child');
    await folders.move(id: child.id, parentId: root.id);
    final grandChild = await folders.create(title: 'Grandchild');
    await folders.move(id: grandChild.id, parentId: child.id);

    final doc = await documents.create(
      title: 'Note in grandchild',
      kind: DocumentKind.note,
      folderId: grandChild.id,
    );
    final sibling = await folders.create(title: 'Untouched');

    await folders.softDelete(root.id);

    for (final id in [root.id, child.id, grandChild.id]) {
      expect(await folders.findById(id), isNull, reason: 'folder $id');
    }
    expect(await documents.findById(doc.id), isNull);
    expect((await folders.findById(sibling.id))!.title, 'Untouched');

    // Soft, not hard: the rows are still there, just stamped.
    final rows = await db.select(db.folders).get();
    expect(rows, hasLength(4));
    expect(
      rows.where((f) => f.deletedAt != null).map((f) => f.id),
      containsAll([root.id, child.id, grandChild.id]),
    );
    expect(rows.every((f) => f.deletedAt?.isUtc ?? true), isTrue);
  });

  test('watch streams exclude soft-deleted rows', () async {
    final keep = await folders.create(title: 'Keep');
    final drop = await folders.create(title: 'Drop');

    final settled = expectLater(
      folders.watchChildren(null),
      emitsThrough(
        predicate<List<Folder>>(
          (list) => list.length == 1 && list.single.id == keep.id,
        ),
      ),
    );

    expect(await folders.watchAll().first, hasLength(2));
    await folders.softDelete(drop.id);

    await settled;
    expect(await folders.watchAll().first, hasLength(1));
    expect(await folders.findById(drop.id), isNull);
  });
}
