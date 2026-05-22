import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores del sistema UrQuest
class AppColors {
  AppColors._();

  static const Color background   = Color(0xFF080B10); // Negro profundo
  static const Color surface      = Color(0xFF0F1520); // Gris oscuro superficies
  static const Color cardBg       = Color(0xFF111827); // Fondo de cards
  static const Color neonCyan     = Color(0xFF00E5FF); // Acento cian eléctrico
  static const Color neonBlue     = Color(0xFF1565FF); // Azul neón
  static const Color neonRed      = Color(0xFFFF1744); // HP / peligro
  static const Color neonGold     = Color(0xFFFFD700); // Grit / moneda
  static const Color textPrimary  = Color(0xFFE0E6F0); // Blanco suave
  static const Color textSecondary= Color(0xFF8899A6); // Gris claro
  static const Color divider      = Color(0xFF1E2D40);

  // Atributos del hexágono
  static const Color attrInt  = Color(0xFF00E5FF); // Cian — Intelecto
  static const Color attrLog  = Color(0xFF3D5AFE); // Azul — Lógica
  static const Color attrCrea = Color(0xFFE040FB); // Violeta — Creatividad
  static const Color attrEsp  = Color(0xFF00E676); // Verde — Espiritualidad
  static const Color attrVit  = Color(0xFFFF1744); // Rojo — Vitalidad
  static const Color attrSoc  = Color(0xFFFFAB40); // Ámbar — Social
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface:   AppColors.surface,
        primary:   AppColors.neonCyan,
        secondary: AppColors.neonBlue,
        error:     AppColors.neonRed,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.background,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: 2),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          headlineMedium:TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, letterSpacing: 1),
          titleMedium:   TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: AppColors.textPrimary),
          bodyMedium:    TextStyle(color: AppColors.textSecondary),
          labelLarge:    TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.neonCyan),
        titleTextStyle: TextStyle(
          color: AppColors.neonCyan,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      dividerColor: AppColors.divider,
      iconTheme: const IconThemeData(color: AppColors.neonCyan),
    );
  }
}

