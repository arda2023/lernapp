import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// Persists the window's bounds so it reopens where it was left.
class WindowStatePrefs {
  WindowStatePrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _xKey = 'window.x';
  static const _yKey = 'window.y';
  static const _widthKey = 'window.width';
  static const _heightKey = 'window.height';

  Rect? get bounds {
    final x = _prefs.getDouble(_xKey);
    final y = _prefs.getDouble(_yKey);
    final width = _prefs.getDouble(_widthKey);
    final height = _prefs.getDouble(_heightKey);
    if (x == null || y == null || width == null || height == null) {
      return null;
    }
    return Rect.fromLTWH(x, y, width, height);
  }

  Future<void> saveBounds(Rect bounds) async {
    await _prefs.setDouble(_xKey, bounds.left);
    await _prefs.setDouble(_yKey, bounds.top);
    await _prefs.setDouble(_widthKey, bounds.width);
    await _prefs.setDouble(_heightKey, bounds.height);
  }
}

/// Saves the window's bounds whenever a resize or move finishes.
class WindowBoundsListener extends WindowListener {
  WindowBoundsListener(this._prefs);

  final WindowStatePrefs _prefs;

  @override
  void onWindowResized() => _persist();

  @override
  void onWindowMoved() => _persist();

  Future<void> _persist() async {
    final bounds = await windowManager.getBounds();
    await _prefs.saveBounds(bounds);
  }
}
