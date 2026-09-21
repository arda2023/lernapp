import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/folder_repository.dart';
import '../../data/tables/documents.dart';
import 'library_providers.dart';

enum _FolderAction { newSubfolder, newNote, rename, delete }

enum _DocumentAction { rename, delete }

class FolderRow extends ConsumerWidget {
  const FolderRow({required this.node, required this.depth, super.key});

  final FolderNode node;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = node.folder;
    final isEditing = ref.watch(editingItemIdProvider) == folder.id;
    final isSelected = ref.watch(selectedItemIdProvider) == folder.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TreeRow(
          depth: depth,
          selected: isSelected,
          onTap: () => ref.read(selectedItemIdProvider.notifier).select(folder.id),
          onSecondaryTapDown: (details) =>
              _showFolderMenu(context, ref, details.globalPosition, folder),
          leading: IconButton(
            icon: Icon(
              folder.isExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            visualDensity: VisualDensity.compact,
            splashRadius: 12,
            onPressed: () => ref
                .read(folderRepositoryProvider)
                .setExpanded(folder.id, !folder.isExpanded),
          ),
          child: isEditing
              ? _RenameField(
                  initialText: folder.title,
                  onSubmit: (text) {
                    ref.read(folderRepositoryProvider).rename(folder.id, text);
                    ref.read(editingItemIdProvider.notifier).stop();
                  },
                  onCancel: () => ref.read(editingItemIdProvider.notifier).stop(),
                )
              : Text(folder.title, overflow: TextOverflow.ellipsis),
        ),
        if (folder.isExpanded) ...[
          for (final child in node.subfolders)
            FolderRow(node: child, depth: depth + 1),
          for (final document in node.documents)
            DocumentRow(document: document, depth: depth + 1),
        ],
      ],
    );
  }
}

class DocumentRow extends ConsumerWidget {
  const DocumentRow({required this.document, required this.depth, super.key});

  final Document document;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editingItemIdProvider) == document.id;
    final isSelected = ref.watch(selectedItemIdProvider) == document.id;

    return _TreeRow(
      depth: depth,
      selected: isSelected,
      onTap: () => ref.read(selectedItemIdProvider.notifier).select(document.id),
      onSecondaryTapDown: (details) =>
          _showDocumentMenu(context, ref, details.globalPosition, document),
      leading: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          document.kind == DocumentKind.pdf
              ? Icons.picture_as_pdf_outlined
              : Icons.description_outlined,
          size: 14,
        ),
      ),
      child: isEditing
          ? _RenameField(
              initialText: document.title,
              onSubmit: (text) {
                ref.read(documentRepositoryProvider).rename(document.id, text);
                ref.read(editingItemIdProvider.notifier).stop();
              },
              onCancel: () => ref.read(editingItemIdProvider.notifier).stop(),
            )
          : Text(document.title, overflow: TextOverflow.ellipsis),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.depth,
    required this.selected,
    required this.onTap,
    required this.onSecondaryTapDown,
    required this.leading,
    required this.child,
  });

  final int depth;
  final bool selected;
  final VoidCallback onTap;
  final GestureTapDownCallback onSecondaryTapDown;
  final Widget leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.18)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onSecondaryTapDown: onSecondaryTapDown,
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.0 + depth * 16,
            right: 8,
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              SizedBox(width: 20, child: leading),
              const SizedBox(width: 4),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenameField extends StatefulWidget {
  const _RenameField({
    required this.initialText,
    required this.onSubmit,
    required this.onCancel,
  });

  final String initialText;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  @override
  State<_RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends State<_RenameField> {
  late final _controller = TextEditingController(text: widget.initialText)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialText.length,
    );
  bool _resolved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_resolved) return;
    final text = _controller.text.trim();
    _resolved = true;
    if (text.isEmpty) {
      widget.onCancel();
    } else {
      widget.onSubmit(text);
    }
  }

  void _cancel() {
    if (_resolved) return;
    _resolved = true;
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _cancel();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: _controller,
        autofocus: true,
        onSubmitted: (_) => _submit(),
        onTapOutside: (_) => _submit(),
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

Future<void> _showFolderMenu(
  BuildContext context,
  WidgetRef ref,
  Offset position,
  Folder folder,
) async {
  final action = await _showMenu<_FolderAction>(context, position, const [
    PopupMenuItem(value: _FolderAction.newSubfolder, child: Text('New subfolder')),
    PopupMenuItem(value: _FolderAction.newNote, child: Text('New note')),
    PopupMenuItem(value: _FolderAction.rename, child: Text('Rename')),
    PopupMenuItem(value: _FolderAction.delete, child: Text('Delete')),
  ]);
  if (action == null || !context.mounted) return;

  final folders = ref.read(folderRepositoryProvider);
  switch (action) {
    case _FolderAction.newSubfolder:
      final sub = await folders.create(title: 'New folder', parentId: folder.id);
      await folders.setExpanded(folder.id, true);
      ref.read(editingItemIdProvider.notifier).start(sub.id);
    case _FolderAction.newNote:
      final doc = await ref
          .read(documentRepositoryProvider)
          .create(title: 'New note', kind: DocumentKind.note, folderId: folder.id);
      await folders.setExpanded(folder.id, true);
      ref.read(editingItemIdProvider.notifier).start(doc.id);
    case _FolderAction.rename:
      ref.read(editingItemIdProvider.notifier).start(folder.id);
    case _FolderAction.delete:
      if (!context.mounted) return;
      final confirmed = await _confirmDelete(context, folder.title);
      if (confirmed) {
        await folders.softDelete(folder.id);
      }
  }
}

Future<void> _showDocumentMenu(
  BuildContext context,
  WidgetRef ref,
  Offset position,
  Document document,
) async {
  final action = await _showMenu<_DocumentAction>(context, position, const [
    PopupMenuItem(value: _DocumentAction.rename, child: Text('Rename')),
    PopupMenuItem(value: _DocumentAction.delete, child: Text('Delete')),
  ]);
  if (action == null || !context.mounted) return;

  switch (action) {
    case _DocumentAction.rename:
      ref.read(editingItemIdProvider.notifier).start(document.id);
    case _DocumentAction.delete:
      if (!context.mounted) return;
      final confirmed = await _confirmDelete(context, document.title);
      if (confirmed) {
        await ref.read(documentRepositoryProvider).softDelete(document.id);
      }
  }
}

Future<T?> _showMenu<T>(
  BuildContext context,
  Offset position,
  List<PopupMenuEntry<T>> items,
) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      position & const Size(1, 1),
      Offset.zero & overlay.size,
    ),
    items: items,
  );
}

Future<bool> _confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete?'),
      content: Text('Delete "$title"? This can only be undone from a backup.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
