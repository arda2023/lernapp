import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Placeholder note editor carried over from the spike: a blank
/// [AppFlowyEditor] with the default floating toolbar.
class EditorPlaceholder extends StatefulWidget {
  const EditorPlaceholder({super.key});

  @override
  State<EditorPlaceholder> createState() => _EditorPlaceholderState();
}

class _EditorPlaceholderState extends State<EditorPlaceholder> {
  late final EditorState _editorState;
  late final EditorScrollController _editorScrollController;

  @override
  void initState() {
    super.initState();
    _editorState = EditorState.blank(withInitialText: true);
    _editorScrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap: false,
    );
  }

  @override
  void dispose() {
    _editorScrollController.dispose();
    _editorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingToolbar(
      items: [
        paragraphItem,
        ...headingItems,
        ...markdownFormatItems,
        quoteItem,
        bulletedListItem,
        numberedListItem,
        linkItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
      ],
      editorState: _editorState,
      editorScrollController: _editorScrollController,
      textDirection: TextDirection.ltr,
      child: AppFlowyEditor(
        editorState: _editorState,
        editorScrollController: _editorScrollController,
      ),
    );
  }
}
