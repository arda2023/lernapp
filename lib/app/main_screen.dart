import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../core/layout_prefs.dart';
import '../features/editor/editor_pane.dart';
import '../features/library/library_sidebar.dart';
import '../features/pdf/pdf_pane.dart';

const _sidebarAreaId = 'sidebar';
const _pdfAreaId = 'pdf';
const _editorAreaId = 'editor';

/// Resizable three-pane layout: sidebar | PDF pane | editor pane. Pane sizes
/// and the sidebar's collapsed state are persisted via [LayoutPrefs].
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final LayoutPrefs _prefs = ref.read(layoutPrefsProvider);
  late bool _sidebarCollapsed = _prefs.sidebarCollapsed;
  late final MultiSplitViewController _controller =
      MultiSplitViewController(areas: _buildAreas());

  List<Area> _buildAreas() {
    return [
      if (!_sidebarCollapsed)
        Area(size: _prefs.sidebarWidth, min: 180, max: 480, data: _sidebarAreaId),
      Area(flex: _prefs.pdfWeight, min: 200, data: _pdfAreaId),
      Area(flex: _prefs.editorWeight, min: 200, data: _editorAreaId),
    ];
  }

  void _persistAreas() {
    for (final area in _controller.areas) {
      switch (area.data) {
        case _sidebarAreaId:
          final size = area.size;
          if (size != null) _prefs.sidebarWidth = size;
        case _pdfAreaId:
          final flex = area.flex;
          if (flex != null) _prefs.pdfWeight = flex;
        case _editorAreaId:
          final flex = area.flex;
          if (flex != null) _prefs.editorWeight = flex;
      }
    }
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarCollapsed = !_sidebarCollapsed;
      _prefs.sidebarCollapsed = _sidebarCollapsed;
      _controller.areas = _buildAreas();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Toolbar(
              sidebarCollapsed: _sidebarCollapsed,
              onToggleSidebar: _toggleSidebar,
            ),
            const Divider(height: 1),
            Expanded(
              child: MultiSplitView(
                controller: _controller,
                onDividerDragEnd: (_) => _persistAreas(),
                builder: (context, area) {
                  switch (area.data) {
                    case _sidebarAreaId:
                      return const LibrarySidebar();
                    case _pdfAreaId:
                      return const PdfPane();
                    default:
                      return const EditorPane();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.sidebarCollapsed, required this.onToggleSidebar});

  final bool sidebarCollapsed;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              sidebarCollapsed ? Icons.view_sidebar_outlined : Icons.view_sidebar,
            ),
            tooltip: sidebarCollapsed ? 'Show sidebar' : 'Hide sidebar',
            onPressed: onToggleSidebar,
          ),
          Text('lernapp', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
