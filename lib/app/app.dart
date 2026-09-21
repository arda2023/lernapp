import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class LernApp extends StatelessWidget {
  const LernApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'lernapp',
      theme: appTheme,
      darkTheme: appTheme,
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        AppFlowyEditorLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
