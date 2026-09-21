import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/folder_repository.dart';
import 'library_providers.dart';
import 'library_tree_row.dart';

/// Nested folder/document tree, with a "+" button to create a root folder.
class LibrarySidebar extends ConsumerWidget {
  const LibrarySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(libraryTreeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
          child: Row(
            children: [
              Text('Library', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                tooltip: 'New folder',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final folder =
                      await ref.read(folderRepositoryProvider).create(title: 'New folder');
                  ref.read(editingItemIdProvider.notifier).start(folder.id);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: tree == null
              ? const Center(child: CircularProgressIndicator())
              : tree.rootFolders.isEmpty && tree.rootDocuments.isEmpty
                  ? Center(
                      child: Text(
                        'No folders yet',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: [
                        for (final node in tree.rootFolders)
                          FolderRow(node: node, depth: 0),
                        for (final document in tree.rootDocuments)
                          DocumentRow(document: document, depth: 0),
                      ],
                    ),
        ),
      ],
    );
  }
}
