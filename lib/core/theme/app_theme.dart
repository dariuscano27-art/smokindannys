import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Client Recommended Signature Palette:
  // 60% White (#FFFFFF) - Background & Surfaces
  // 30% Maroon (#800020) - Header, Primary Buttons, Navigation
  // 10% Champagne Gold (#D4AF37) - Highlights, Badges, Ratings, Accents
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryMaroon = Color(0xFF800020);
  static const Color champagneGold = Color(0xFFD4AF37);
  
  static const Color deepMaroon = Color(0xFF5C0017);
  static const Color lightMaroon = Color(0xFF990026);
  static const Color softMaroon = Color(0xFFFBF4F5);
  static const Color borderMaroon = Color(0xFFE2C4C9);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mutedText = Color(0xFF6E6A75);
  static const Color errorColor = Color(0xFFD32F2F);

  // Compatibility aliases
  static const Color primaryRed = primaryMaroon;
  static const Color accentRed = primaryMaroon;
  static const Color cardBg = surface;
  static const Color darkBg = background;
  static const Color surfaceBg = surface;
  static const Color borderDark = borderMaroon;
  static const Color textWhite = darkText;
  static const Color textMuted = mutedText;
  static const Color primaryPink = primaryMaroon;
  static const Color softPink = softMaroon;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMaroon,
        brightness: Brightness.light,
        primary: primaryMaroon,
        secondary: champagneGold,
        surface: surface,
        error: errorColor,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
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
        titleLarge: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: darkText),
        bodyMedium: GoogleFonts.inter(color: darkText),
        bodySmall: GoogleFonts.inter(color: mutedText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: mutedText, fontSize: 14),
        labelStyle: const TextStyle(color: darkText, fontSize: 14),
        prefixIconColor: primaryMaroon,
        suffixIconColor: mutedText,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderMaroon, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderMaroon, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryMaroon, width: 1.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
          side: const BorderSide(color: borderMaroon, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon,
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

  static ThemeData get darkTheme => lightTheme;
}

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final screenWidth = MediaQuery.of(context).size.width;
    final toastWidth = screenWidth > 500 ? 440.0 : screenWidth * 0.9;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: toastWidth,
        elevation: 8,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.champagneGold, width: 1.2),
        ),
        backgroundColor: backgroundColor ?? AppTheme.primaryMaroon,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppTheme.champagneGold,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
