import 'package:flutter/material.dart';
import '../models/color_scheme_model.dart';

class PresetColorSchemes {
  static const List<GymColorScheme> presets = [
    // Dark Modern (Default)
    GymColorScheme(
      name: 'Dark Modern',
      backgroundColor: Color(0xFF0F0F0F),
      cardColor: Color(0xFF1E1E1E),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFB0B0B0),
      headingColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFE63946),
      buttonColor: Color(0xFFE63946),
      borderColor: Color(0xFF3C3C3C),
    ),

    // Light Professional
    GymColorScheme(
      name: 'Light Professional',
      backgroundColor: Color(0xFFF8F9FA),
      cardColor: Color(0xFFFFFFFF),
      primaryTextColor: Color(0xFF212529),
      secondaryTextColor: Color(0xFF6C757D),
      headingColor: Color(0xFF343A40),
      accentColor: Color(0xFF007BFF),
      buttonColor: Color(0xFF007BFF),
      borderColor: Color(0xFFDEE2E6),
    ),

    // Fitness Green
    GymColorScheme(
      name: 'Fitness Green',
      backgroundColor: Color(0xFF0D1B0F),
      cardColor: Color(0xFF1A2E1D),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFB8C5BB),
      headingColor: Color(0xFF4CAF50),
      accentColor: Color(0xFF4CAF50),
      buttonColor: Color(0xFF4CAF50),
      borderColor: Color(0xFF2E5233),
    ),

    // Energetic Orange
    GymColorScheme(
      name: 'Energetic Orange',
      backgroundColor: Color(0xFF1A0F0A),
      cardColor: Color(0xFF2D1B13),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFC5B8AD),
      headingColor: Color(0xFFFF6B35),
      accentColor: Color(0xFFFF6B35),
      buttonColor: Color(0xFFFF6B35),
      borderColor: Color(0xFF4A2F1F),
    ),

    // Electric Blue
    GymColorScheme(
      name: 'Electric Blue',
      backgroundColor: Color(0xFF0A0F1A),
      cardColor: Color(0xFF13202D),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFADB8C5),
      headingColor: Color(0xFF00D4FF),
      accentColor: Color(0xFF00D4FF),
      buttonColor: Color(0xFF00D4FF),
      borderColor: Color(0xFF1F3A4A),
    ),

    // Purple Power
    GymColorScheme(
      name: 'Purple Power',
      backgroundColor: Color(0xFF15091A),
      cardColor: Color(0xFF25132D),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFC0ADC5),
      headingColor: Color(0xFF9C27B0),
      accentColor: Color(0xFF9C27B0),
      buttonColor: Color(0xFF9C27B0),
      borderColor: Color(0xFF3E1F4A),
    ),

    // Gold Elite
    GymColorScheme(
      name: 'Gold Elite',
      backgroundColor: Color(0xFF1A1510),
      cardColor: Color(0xFF2D2318),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFC5BFA8),
      headingColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFFD700),
      buttonColor: Color(0xFFFFD700),
      borderColor: Color(0xFF4A3F28),
    ),

    // Midnight Blue
    GymColorScheme(
      name: 'Midnight Blue',
      backgroundColor: Color(0xFF0C1426),
      cardColor: Color(0xFF1A2332),
      primaryTextColor: Color(0xFFFFFFFF),
      secondaryTextColor: Color(0xFFB3C1D1),
      headingColor: Color(0xFF64B5F6),
      accentColor: Color(0xFF64B5F6),
      buttonColor: Color(0xFF64B5F6),
      borderColor: Color(0xFF2A3A4F),
    ),
  ];

  static List<Color> get quickColors => [
    const Color(0xFFE63946), // Red
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFFD700), // Gold
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFF44336), // Dark Red
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFE91E63), // Pink
    const Color(0xFF009688), // Teal
  ];
}
