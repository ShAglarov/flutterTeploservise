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
        onSurface: Color(0xFF1C1C1E), // Soft black for better readability
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withAlpha(20),
        thickness: 0.5,
      ),
      cardTheme: CardThemeData(
        color: secondaryLightBackground,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardCornerRadius),
          side: const BorderSide(
            color: Color(0xFFD1D1D6), // iOS separator color
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: secondaryLightBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1C1C1E)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1C1C1E),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Color(0xFF3C3C43), // secondaryLabel
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          color: Color(0xFF8E8E93), // tertiaryLabel
        ),
      ),
    );
  }
}
