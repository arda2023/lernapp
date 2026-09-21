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

  test('create stores kind, UTC timestamps and an appended sortIndex',
      () async {
    final note = await documents.create(
      title: 'Lecture notes',
      kind: DocumentKind.note,
    );
    final pdf = await documents.create(
      title: 'Script.pdf',
      kind: DocumentKind.pdf,
    );

    expect(note.id, hasLength(36));
    expect(note.kind, DocumentKind.note);
    expect(pdf.kind, DocumentKind.pdf);
    expect(note.folderId, isNull, reason: 'null folderId means library root');
    expect(note.createdAt.isUtc, isTrue);
    expect(note.sortIndex, 0);
    expect(pdf.sortIndex, 1);
  });

  test('sortIndex counts per folder and move re-appends', () async {
    final folder = await folders.create(title: 'Folder');
    final root = await documents.create(
      title: 'Root doc',
      kind: DocumentKind.note,
    );
    final inFolder = await documents.create(
      title: 'Nested doc',
      kind: DocumentKind.note,
      folderId: folder.id,
    );
    expect(inFolder.sortIndex, 0);

    await documents.move(id: root.id, folderId: folder.id);

    final moved = await documents.findById(root.id);
    expect(moved!.folderId, folder.id);
    expect(moved.sortIndex, 1);
    expect(await documents.watchInFolder(null).first, isEmpty);
  });

  test('rename and reorder update the rows', () async {
    final a = await documents.create(title: 'A', kind: DocumentKind.note);
    final b = await documents.create(title: 'B', kind: DocumentKind.pdf);

    await documents.rename(a.id, 'A renamed');
    await documents.reorder([b.id, a.id]);

    final ordered = await documents.watchInFolder(null).first;
    expect(ordered.map((d) => d.title), ['B', 'A renamed']);
  });

  test('soft delete hides the row from watch streams but keeps it', () async {
    final keep = await documents.create(title: 'Keep', kind: DocumentKind.note);
    final drop = await documents.create(title: 'Drop', kind: DocumentKind.note);

    final settled = expectLater(
      documents.watchInFolder(null),
      emitsThrough(
        predicate<List<Document>>(
          (list) => list.length == 1 && list.single.id == keep.id,
        ),
      ),
    );

    await documents.softDelete(drop.id);
    await settled;

    expect(await documents.findById(drop.id), isNull);
    expect(await documents.watchAll().first, hasLength(1));

    final raw = await (db.select(db.documents)
          ..where((d) => d.id.equals(drop.id)))
        .getSingle();
    expect(raw.deletedAt, isNotNull);
    expect(raw.deletedAt!.isUtc, isTrue);
  });
}
