import 'package:flutter/material.dart';

class AppTheme {
  // ── Dark mode colors (derived from iOS implementation) ──
  static const Color darkBackground = Color(0xFF000000);
  static const Color secondaryDarkBackground = Color(0xFF1C1C1E); // secondarySystemBackground
  static const Color tertiaryDarkBackground = Color(0xFF2C2C2E); // tertiarySystemBackground

  // ── Light mode colors ──
  static const Color lightBackground = Color(0xFFF2F2F7); // systemGroupedBackground
  static const Color secondaryLightBackground = Color(0xFFFFFFFF);
  static const Color tertiaryLightBackground = Color(0xFFE5E5EA);
  
  // ── Semantic colors (shared / adjusted per brightness) ──
  static const Color primaryBlue = Color(0xFF0A84FF); // systemBlue (dark)
  static const Color primaryBlueLight = Color(0xFF007AFF); // systemBlue (light)
  static const Color successGreen = Color(0xFF30D158); // systemGreen
  static const Color warningOrange = Color(0xFFFF9F0A); // systemOrange
  static const Color errorRed = Color(0xFFFF453A); // systemRed (dark)
  static const Color errorRedLight = Color(0xFFFF3B30); // systemRed (light)
  static const Color cardBackground = Color(0xFF1C1C1E); // same as secondaryDarkBackground
  
  static const double cardPadding = 12.0;
  static const double cardCornerRadius = 25.0;
  static const double cardBorderWidth = 1.0;

  // ── Dark Theme ──
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: secondaryDarkBackground,
        error: errorRed,
        onSurface: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: secondaryDarkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardCornerRadius),
          side: BorderSide(
            color: Colors.white.withAlpha(25), // Subtle border
            width: cardBorderWidth,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Colors.white70,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          color: Colors.white54,
        ),
      ),
    );
  }

  // ── Light Theme ──
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlueLight,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlueLight,
        secondary: primaryBlueLight,
        surface: secondaryLightBackground,
        error: errorRedLight,
        onSurface: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: secondaryLightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardCornerRadius),
          side: BorderSide(
            color: Colors.black.withAlpha(20),
            width: cardBorderWidth,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          color: Colors.black54,
        ),
      ),
    );
  }
}
