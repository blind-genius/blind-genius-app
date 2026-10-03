import 'package:flutter/material.dart';

/// AppTheme provides high-contrast, WCAG AAA compliant colors and 
/// large accessible touch targets for blind and visually impaired users.
class AppTheme {
  // Primary brand palette - High Contrast OLED Black & Vibrant Gold/Amber
  static const Color background = Color(0xFF0C0D11);
  static const Color surface = Color(0xFF161922);
  static const Color surfaceHighlight = Color(0xFF222736);
  static const Color border = Color(0xFF3B4254);
  
  // Accessible Accent Colors (WCAG AAA contrast against dark background)
  static const Color goldAccent = Color(0xFFFFD54F); // Vibrant Warm Amber Gold
  static const Color goldAccentDark = Color(0xFFFFB300);
  static const Color cyanAccent = Color(0xFF00E5FF); // Bright Electric Cyan
  static const Color mintGreen = Color(0xFF00E676);  // Success / Active
  static const Color errorRed = Color(0xFFFF5252);   // Clear Error Red

  // High contrast text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD6D9E0);
  static const Color textMuted = Color(0xFFA0A6B5);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: goldAccent,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        onPrimary: Colors.black,
        secondary: cyanAccent,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textPrimary,
        error: errorRed,
        onError: Colors.black,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: goldAccent,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: Colors.black,
          minimumSize: const Size(64, 52), // Touch target at least 48dp+
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: goldAccent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHighlight,
        selectedColor: goldAccent,
        secondarySelectedColor: goldAccent,
        labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: goldAccent,
        inactiveTrackColor: border,
        thumbColor: goldAccent,
        overlayColor: Color(0x33FFD54F),
        trackHeight: 6.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
