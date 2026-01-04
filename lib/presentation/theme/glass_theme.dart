import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassTheme {
  static const Color primaryColor = Color(0xFF00D4FF);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4ECDC4);
  
  static final BoxDecoration glassDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  static final decorationBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0F0C29),
        const Color(0xFF24243e),
        const Color(0xFF302B63),
        const Color(0xFF0F0C29),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ),
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: const Color(0xFF1A1A2E), // Fallback
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
