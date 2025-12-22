import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF4361EE),
      secondary: const Color(0xFF4CC9F0),
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      onSurface: const Color(0xFF212529),
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4361EE),
      secondary: const Color(0xFF4CC9F0),
      surface: const Color(0xFF1E1E2E),
      background: const Color(0xFF121212),
      onSurface: Colors.white70,
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
  );
}
