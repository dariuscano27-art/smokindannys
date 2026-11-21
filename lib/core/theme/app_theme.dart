import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Food Studio / Premium Dark Theme Palette
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF181818);
  static const Color surfaceBg = Color(0xFF222222);
  static const Color primaryRed = Color(0xFFE50914);
  static const Color accentRed = Color(0xFFFF1E1E);
  static const Color borderDark = Color(0xFF2C2C2C);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFE53935);

  // Compatibility aliases
  static const Color primaryMaroon = primaryRed;
  static const Color deepMaroon = Color(0xFF5A0000);
  static const Color lightMaroon = Color(0xFFA01818);
  static const Color softMaroon = Color(0xFF331416);
  static const Color borderMaroon = borderDark;
  static const Color background = darkBg;
  static const Color surface = cardBg;
  static const Color darkText = textWhite;
  static const Color mutedText = textMuted;

  static const Color primaryPink = primaryRed;
  static const Color softPink = softMaroon;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.dark,
        primary: primaryRed,
        surface: cardBg,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: textWhite),
        bodyMedium: GoogleFonts.inter(color: textWhite),
        bodySmall: GoogleFonts.inter(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  // Keep lightTheme as fallback
  static ThemeData get lightTheme => darkTheme;
}
