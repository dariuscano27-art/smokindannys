import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryMaroon = Color(0xFF800000);
  static const Color darkMaroonBg = Color(0xFF140709);
  static const Color darkCardBg = Color(0xFF1C0A0D);
  static const Color darkInputBg = Color(0xFF261014);
  static const Color darkInputBorder = Color(0xFF3D191F);
  static const Color accentGold = Color(0xFFFFC107);
  static const Color goldButtonStart = Color(0xFFFFC837);
  static const Color goldButtonEnd = Color(0xFFFF8008);
  static const Color softMaroon = Color(0xFFF9ECEE);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF25212A);
  static const Color mutedText = Color(0xFF9E8B8E);
  static const Color errorColor = Color(0xFFE53935);

  // Compatibility aliases
  static const Color primaryPink = primaryMaroon;
  static const Color softPink = softMaroon;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMaroon,
        primary: primaryMaroon,
        secondary: softMaroon,
        surface: surface,
        error: errorColor,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: darkText),
        bodyMedium: GoogleFonts.inter(color: darkText),
        bodySmall: GoogleFonts.inter(color: mutedText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
