import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

part 'layout_prefs.g.dart';

/// Sidebar width, sidebar collapsed state and the PDF/editor split ratio,
/// persisted so the three-pane layout survives a restart.
class LayoutPrefs {
  LayoutPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _sidebarWidthKey = 'layout.sidebarWidth';
  static const _sidebarCollapsedKey = 'layout.sidebarCollapsed';
  static const _pdfWeightKey = 'layout.pdfWeight';
  static const _editorWeightKey = 'layout.editorWeight';

  double get sidebarWidth => _prefs.getDouble(_sidebarWidthKey) ?? 280;
  set sidebarWidth(double value) => _prefs.setDouble(_sidebarWidthKey, value);

  bool get sidebarCollapsed => _prefs.getBool(_sidebarCollapsedKey) ?? false;
  set sidebarCollapsed(bool value) =>
      _prefs.setBool(_sidebarCollapsedKey, value);

  double get pdfWeight => _prefs.getDouble(_pdfWeightKey) ?? 1;
  set pdfWeight(double value) => _prefs.setDouble(_pdfWeightKey, value);

  double get editorWeight => _prefs.getDouble(_editorWeightKey) ?? 1;
  set editorWeight(double value) => _prefs.setDouble(_editorWeightKey, value);
}

@riverpod
LayoutPrefs layoutPrefs(Ref ref) {
  return LayoutPrefs(ref.watch(sharedPreferencesProvider));
}
