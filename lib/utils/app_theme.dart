import 'package:flutter/material.dart';

class AppTheme {
  // Colors derived from iOS implementation
  static const Color darkBackground = Color(0xFF000000);
  static const Color secondaryDarkBackground = Color(0xFF1C1C1E); // secondarySystemBackground
  static const Color tertiaryDarkBackground = Color(0xFF2C2C2E); // tertiarySystemBackground
  
  static const Color primaryBlue = Color(0xFF0A84FF); // systemBlue
  static const Color successGreen = Color(0xFF30D158); // systemGreen
  static const Color warningOrange = Color(0xFFFF9F0A); // systemOrange
  static const Color errorRed = Color(0xFFFF453A); // systemRed
  static const Color cardBackground = Color(0xFF1C1C1E); // same as secondaryDarkBackground
  
  static const double cardPadding = 12.0;
  static const double cardCornerRadius = 25.0;
  static const double cardBorderWidth = 1.0;

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
}
