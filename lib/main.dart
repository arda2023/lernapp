import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core/db_backup.dart';
import 'core/shared_preferences_provider.dart';
import 'core/window_state.dart';
import 'data/database/database_provider.dart';

const _defaultWindowSize = Size(1280, 800);
const _minimumWindowSize = Size(720, 480);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  await windowManager.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final windowPrefs = WindowStatePrefs(prefs);
  final savedBounds = windowPrefs.bounds;

  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: savedBounds?.size ?? _defaultWindowSize,
      minimumSize: _minimumWindowSize,
      center: savedBounds == null,
      title: 'lernapp',
    ),
    () async {
      if (savedBounds != null) {
        await windowManager.setPosition(savedBounds.topLeft);
      }
      await windowManager.show();
      await windowManager.focus();
    },
  );
  windowManager.addListener(WindowBoundsListener(windowPrefs));

  // Built here so the startup backup and the widget tree share one database.
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  await createStartupBackup(container.read(appDatabaseProvider));

  runApp(
    UncontrolledProviderScope(container: container, child: const LernApp()),
  );
}
