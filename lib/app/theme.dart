import 'package:flutter/material.dart';

const _accentColor = Color(0xFF7C6CF0);
const _backgroundColor = Color(0xFF1B1C1F);
const _surfaceColor = Color(0xFF232428);

/// Dark, minimal desktop theme: flat surfaces, one accent color, compact
/// list density.
final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _backgroundColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _accentColor,
    brightness: Brightness.dark,
  ).copyWith(primary: _accentColor, surface: _surfaceColor),
  visualDensity: VisualDensity.compact,
  splashFactory: NoSplash.splashFactory,
  dividerTheme: const DividerThemeData(space: 1, thickness: 1),
  listTileTheme: const ListTileThemeData(dense: true, minVerticalPadding: 2),
  iconTheme: const IconThemeData(size: 18),
  appBarTheme: const AppBarTheme(backgroundColor: _backgroundColor, elevation: 0),
);
