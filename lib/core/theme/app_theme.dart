import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF), // Vibrant Purple
        brightness: Brightness.light,
        primary: const Color(0xFF6C63FF),
        secondary: const Color(0xFF00BFA5), // Teal Accent
        tertiary: const Color(0xFFFF6584), // Pink/Red Accent
        surface: const Color(0xFFF8F9FA),
        surfaceContainer: const Color(0xFFFFFFFF),
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: const AppBarTheme(centerTitle: false, backgroundColor: Colors.transparent, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        color: Colors.white,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFF6C63FF),
        labelType: NavigationRailLabelType.all,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
        primary: const Color(0xFF8A84FF), // Lighter Purple for Dark Mode
        secondary: const Color(0xFF64FFDA), // Lighter Teal
        tertiary: const Color(0xFFFF869E), // Lighter Pink
        surface: const Color(0xFF121212),
        surfaceContainer: const Color(0xFF1E1E1E),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false, backgroundColor: Colors.transparent, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF121212),
        indicatorColor: Color(0xFF6C63FF),
        labelType: NavigationRailLabelType.all,
      ),
    );
  }
}
