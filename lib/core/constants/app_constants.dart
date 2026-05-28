import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  static Color primaryColor = Color.fromARGB(255, 86, 2, 221);
  static Color secondaryColor = primaryColor.withValues(alpha: 0.7);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color.fromARGB(255, 0, 0, 0);
  static const Color greyColor = Color.fromARGB(255, 78, 78, 78);

  //Text Styles
  static TextStyle get headingStyle => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppConstants.textColor,
  );

  static TextStyle get titleStyle => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppConstants.textColor,
  );

  static TextStyle get bodyStyle =>
      GoogleFonts.outfit(fontSize: 16, color: textColor);

  //Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultborderRadius = 26.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Duration
  static const Duration defaultDuration = Duration(milliseconds: 300);
}
