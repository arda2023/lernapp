import 'package:flutter/material.dart';

/// Not wired to the selected document yet; always shows an empty state.
class PdfPane extends StatelessWidget {
  const PdfPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No PDF open',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}
