import 'package:flutter/material.dart';

class GymColorScheme {
  final String name;
  final Color backgroundColor;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color headingColor;
  final Color accentColor;
  final Color buttonColor;
  final Color borderColor;

  const GymColorScheme({
    required this.name,
    required this.backgroundColor,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.headingColor,
    required this.accentColor,
    required this.buttonColor,
    required this.borderColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'backgroundColor': backgroundColor.value,
      'cardColor': cardColor.value,
      'primaryTextColor': primaryTextColor.value,
      'secondaryTextColor': secondaryTextColor.value,
      'headingColor': headingColor.value,
      'accentColor': accentColor.value,
      'buttonColor': buttonColor.value,
      'borderColor': borderColor.value,
    };
  }

  factory GymColorScheme.fromMap(Map<String, dynamic> map) {
    return GymColorScheme(
      name: map['name'] ?? 'Custom',
      backgroundColor: Color(map['backgroundColor']),
      cardColor: Color(map['cardColor']),
      primaryTextColor: Color(map['primaryTextColor']),
      secondaryTextColor: Color(map['secondaryTextColor']),
      headingColor: Color(map['headingColor']),
      accentColor: Color(map['accentColor']),
      buttonColor: Color(map['buttonColor']),
      borderColor: Color(map['borderColor']),
    );
  }

  GymColorScheme copyWith({
    String? name,
    Color? backgroundColor,
    Color? cardColor,
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? headingColor,
    Color? accentColor,
    Color? buttonColor,
    Color? borderColor,
  }) {
    return GymColorScheme(
      name: name ?? this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      headingColor: headingColor ?? this.headingColor,
      accentColor: accentColor ?? this.accentColor,
      buttonColor: buttonColor ?? this.buttonColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}
