// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Modo Oscuro (por defecto)
  static const Color darkBg = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceCard = Color(0xFF252525);
  static const Color darkNavBarBg = Color(0xFF1A1A1A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF333333);

  // Modo Claro
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFF5F5F5);
  static const Color lightNavBarBg = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Colores comunes
  static const Color accent = Color(0xFF00D4FF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFFCA5A5);
  static const Color warning = Color(0xFFF59E0B);

  // Propiedades dinámicas basadas en el tema
  static Color getBackground(bool isDark) => isDark ? darkBg : lightBg;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getSurfaceCard(bool isDark) => isDark ? darkSurfaceCard : lightSurfaceCard;
  static Color getNavBarBg(bool isDark) => isDark ? darkNavBarBg : lightNavBarBg;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;

  // Valores estáticos para compatibilidad
  static const Color background = darkBg;
  static const Color surface = darkSurface;
  static const Color surfaceCard = darkSurfaceCard;
  static const Color navBarBg = darkNavBarBg;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color border = darkBorder;

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: lightTextPrimary),
        bodySmall: TextStyle(color: lightTextSecondary),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: darkTextPrimary),
        bodySmall: TextStyle(color: darkTextSecondary),
      ),
    );
  }
}