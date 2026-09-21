import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/folder_repository.dart';
import '../../data/tables/documents.dart';

part 'library_providers.g.dart';

// Hand-written, not @riverpod: riverpod_generator's code emitter currently
// crashes (InvalidTypeException) on any provider whose declared return type
// mentions a drift-generated data class (Folder/Document), even nested. Plain
// providers referencing them are unaffected since the generator never
// inspects them.
final allFoldersProvider = StreamProvider<List<Folder>>((ref) {
  return ref.watch(folderRepositoryProvider).watchAll();
});

final allDocumentsProvider = StreamProvider<List<Document>>((ref) {
  return ref.watch(documentRepositoryProvider).watchAll();
});

/// A folder plus its live subfolders and documents.
class FolderNode {
  const FolderNode(this.folder, this.subfolders, this.documents);

  final Folder folder;
  final List<FolderNode> subfolders;
  final List<Document> documents;
}

/// The whole library, built client-side from the flat folder/document
/// streams so the sidebar can render it as a tree.
class LibraryTree {
  const LibraryTree(this.rootFolders, this.rootDocuments);

  final List<FolderNode> rootFolders;
  final List<Document> rootDocuments;
}

@riverpod
LibraryTree? libraryTree(Ref ref) {
  final folders = ref.watch(allFoldersProvider).value;
  final documents = ref.watch(allDocumentsProvider).value;
  if (folders == null || documents == null) return null;

  final foldersByParent = <String?, List<Folder>>{};
  for (final folder in folders) {
    foldersByParent.putIfAbsent(folder.parentId, () => []).add(folder);
  }
  for (final siblings in foldersByParent.values) {
    siblings.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
  }

  final documentsByFolder = <String?, List<Document>>{};
  for (final document in documents) {
    documentsByFolder.putIfAbsent(document.folderId, () => []).add(document);
  }
  for (final siblings in documentsByFolder.values) {
    siblings.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
  }

  List<FolderNode> buildFolders(String? parentId) {
    return [
      for (final folder in foldersByParent[parentId] ?? const <Folder>[])
        FolderNode(
          folder,
          buildFolders(folder.id),
          documentsByFolder[folder.id] ?? const [],
        ),
    ];
  }

  return LibraryTree(buildFolders(null), documentsByFolder[null] ?? const []);
}

/// Id of the row currently highlighted in the sidebar (folder or document).
///
/// keepAlive: without it this is autoDispose, and setting it right after
/// creating the very first root item (before any row exists to watch it)
/// gets silently reset once the write's listener-free moment disposes it.
@Riverpod(keepAlive: true)
class SelectedItemId extends _$SelectedItemId {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

/// Id of the row currently showing its inline rename text field. See
/// [SelectedItemId] for why this must be keepAlive too.
@Riverpod(keepAlive: true)
class EditingItemId extends _$EditingItemId {
  @override
  String? build() => null;

  void start(String id) => state = id;
  void stop() => state = null;
}

/// The selected document when it's a note, so the editor pane can show it.
/// Hand-written for the same reason as [allFoldersProvider] above.
final selectedNoteDocumentProvider = Provider<Document?>((ref) {
  final selectedId = ref.watch(selectedItemIdProvider);
  if (selectedId == null) return null;

  final documents = ref.watch(allDocumentsProvider).value;
  if (documents == null) return null;

  for (final document in documents) {
    if (document.id == selectedId && document.kind == DocumentKind.note) {
      return document;
    }
  }
  return null;
});
