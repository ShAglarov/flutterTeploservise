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
    // Slightly warmer/darker background so cards & fields stand out
    const scaffoldBg = Color(0xFFEBEBF0);  // was #F2F2F7 — теперь чуть темнее
    const surfaceColor = Color(0xFFFFFFFF); // карточки остаются белыми
    const fieldFill = Color(0xFFF7F7FA);    // поля ввода — чуть серее белого
    const borderColor = Color(0xFFCACACF);  // видимые бордеры полей
    const labelColor = Color(0xFF1C1C1E);   // основной текст
    const secondaryLabel = Color(0xFF3C3C43);
    const tertiaryLabel = Color(0xFF8E8E93);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlueLight,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: primaryBlueLight,
        secondary: primaryBlueLight,
        surface: surfaceColor,
        surfaceContainerHighest: fieldFill,
        error: errorRedLight,
        onSurface: labelColor,
        outline: borderColor,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withAlpha(20),
        thickness: 0.5,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardCornerRadius),
          side: const BorderSide(
            color: Color(0xFFD8D8DC),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      // Глобальная тема полей ввода — все InputDecoration наследуют
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlueLight, width: 1.5),
        ),
        labelStyle: const TextStyle(color: tertiaryLabel, fontSize: 14),
        hintStyle: const TextStyle(color: tertiaryLabel, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: primaryBlueLight),
      ),
      // Dropdown / Popup menus
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor, width: 0.8),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: labelColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: labelColor),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: labelColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: secondaryLabel,
        ),
        labelSmall: TextStyle(
          fontSize: 13,
          color: tertiaryLabel,
        ),
      ),
    );
  }
}
