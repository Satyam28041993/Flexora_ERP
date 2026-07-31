import 'package:flutter/material.dart';

/// Shared visual language across all Flexora ERP modules.
///
/// Upgraded with vibrant modern gradients, rich dark sidebar tokens, glowing status highlights,
/// and executive typography per Doc/Flexora-Master-Requirements-v1.2.md.
class AppTheme {
  static const Color primary = Color(0xFF4F46E5); // Indigo Primary
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color sidebarBg = Color(0xFF0F172A); // Dark Slate Sidebar
  static const Color surface = Color(0xFFF8FAFC); // Clean Slate Canvas
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Vibrant Functional Accents
  static const Color accentBlue = Color(0xFF2563EB); // Orders / PO
  static const Color accentAmber = Color(0xFFD97706); // Job Cards / Active
  static const Color accentEmerald = Color(0xFF059669); // Customers / Approved
  static const Color accentPurple = Color(0xFF7C3AED); // Stores Rolls / Stock
  static const Color accentRose = Color(0xFFE11D48); // Shade Cards / Urgent
  static const Color accentIndigo = Color(0xFF4F46E5); // QC & ISO
  static const Color accentTeal = Color(0xFF0D9488); // Tooling / Dies

  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: surface,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        surface: surfaceCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceCard,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  // Gradient Helper for KPI Cards
  static LinearGradient createGradient(Color baseColor) {
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withAlpha(200),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
