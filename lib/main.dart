import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [
        AppFlowyEditorLocalizations.delegate,
      ],
      home: Scaffold(
        body: SafeArea(
          child: TestScreen(),
        ),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final EditorState _editorState;
  late final EditorScrollController _editorScrollController;
  String? _pdfPath;

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

  Future<void> _pickPdf() async {
    const typeGroup = XTypeGroup(
      label: 'PDFs',
      extensions: <String>['pdf'],
    );
    final file = await openFile(acceptedTypeGroups: const [typeGroup]);
    if (file != null) {
      setState(() {
        _pdfPath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FloatingToolbar(
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
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _pickPdf,
                  child: const Text('Open PDF'),
                ),
              ),
              Expanded(
                child: _pdfPath != null
                    ? PdfViewer.file(_pdfPath!)
                    : const Center(
                        child: Text('No PDF selected'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
