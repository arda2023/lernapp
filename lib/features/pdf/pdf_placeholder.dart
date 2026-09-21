import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Placeholder PDF pane carried over from the spike: pick a file from disk and
/// render it. Nothing is persisted yet.
class PdfPlaceholder extends StatefulWidget {
  const PdfPlaceholder({super.key});

  @override
  State<PdfPlaceholder> createState() => _PdfPlaceholderState();
}

class _PdfPlaceholderState extends State<PdfPlaceholder> {
  String? _pdfPath;

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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: _pickPdf,
            child: const Text('Open PDF'),
          ),
        ),
        Expanded(
          child: _pdfPath != null
              ? PdfViewer.file(_pdfPath!)
              : const Center(child: Text('No PDF selected')),
        ),
      ],
    );
  }
}
