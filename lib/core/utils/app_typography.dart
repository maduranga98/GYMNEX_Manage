import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings
  static TextStyle h1 = GoogleFonts.bebasNeue(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primaryText,
  );

  static TextStyle h2 = GoogleFonts.bebasNeue(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.primaryText,
  );

  static TextStyle h3 = GoogleFonts.bebasNeue(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.primaryText,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  // Buttons
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.buttonText,
  );

  // Labels
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.secondaryText,
  );

  // Captions
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  // Tabs/Navigation
  static TextStyle navLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Input Fields
  static TextStyle inputText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static TextStyle inputHint = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
  );

  // Helper methods
  static TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
  static TextStyle withSize(TextStyle style, double size) =>
      style.copyWith(fontSize: size);
}
