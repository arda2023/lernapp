import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../library/library_providers.dart';
import 'editor_placeholder.dart';

/// Shows the editor for the selected note, keyed by its id so switching
/// documents rebuilds it; otherwise an empty-state hint.
class EditorPane extends ConsumerWidget {
  const EditorPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(selectedNoteDocumentProvider);
    if (document == null) {
      return Center(
        child: Text(
          'Select or create a note',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      );
    }
    return EditorPlaceholder(key: ValueKey(document.id));
  }
}
