import 'package:flutter/material.dart';

class FacebookTheme {
  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color facebookDarkBlue = Color(0xFF166FE5);
  static const Color liveRed = Color(0xFFE41E3F);
  static const Color successGreen = Color(0xFF42B72A);

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: facebookBlue,
      secondary: facebookDarkBlue,
      surface: Colors.white,
      background: const Color(0xFFF0F2F5),
      onSurface: const Color(0xFF1C1E21),
    ),
    useMaterial3: true,
    fontFamily: 'SFPro',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1C1E21),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: facebookBlue,
      foregroundColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: facebookBlue,
      secondary: const Color(0xFF8B9DC3),
      surface: const Color(0xFF242526),
      background: const Color(0xFF18191A),
      onSurface: const Color(0xFFE4E6EB),
    ),
    useMaterial3: true,
    fontFamily: 'SFPro',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF242526),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF242526),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: facebookBlue,
      foregroundColor: Colors.white,
    ),
  );
}
