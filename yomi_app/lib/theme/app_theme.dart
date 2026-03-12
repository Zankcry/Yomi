import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tachiyomi-style background colors
  static const Color darkBackground = Color(0xFF1a1a2e);
  static const Color cardBackground = Color(0xFF16213e);
  static const Color accentColor = Color(0xFF6C63FF); // Bright indigo/purple
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: accentColor,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: accentColor,
      surface: cardBackground,
      background: darkBackground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: accentColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
    ),
  );
}
