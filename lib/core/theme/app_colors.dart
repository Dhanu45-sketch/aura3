import 'package:flutter/material.dart';

class AppColors {
  // Liquid Glass Primary Colors
  static const primaryGlass = Color(0xFF6366F1); // Indigo
  static const secondaryGlass = Color(0xFF8B5CF6); // Purple
  static const tertiaryGlass = Color(0xFF06B6D4); // Cyan
  static const accentGlass = Color(0xFFEC4899); // Pink

  // Background Colors
  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const backgroundLight = Color(0xFF9E569A); // Slate 50
  static const surfaceGlass = Color(0x40FFFFFF); // 25% white for glass effect

  // Element Colors (with transparency for glass effect)
  static const earthGlass = Color(0x8022C55E); // Green 500
  static const fireGlass = Color(0x80EF4444); // Red 500
  static const waterGlass = Color(0x803B82F6); // Blue 500
  static const windGlass = Color(0x8094A3B8); // Gray 400

  // Solid Element Colors (for accents)
  static const earthSolid = Color(0xFF22C55E);
  static const fireSolid = Color(0xFFEF4444);
  static const waterSolid = Color(0xFF3B82F6);
  static const windSolid = Color(0xFF94A3B8);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70% white
  static const textTertiary = Color(0x80FFFFFF); // 50% white
  static const textDark = Color(0xFF0F172A);

  // Border Colors
  static const borderGlass = Color(0x33FFFFFF); // 20% white
  static const borderGlassStrong = Color(0x4DFFFFFF); // 30% white

  // Helper method to get element color
  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'earth':
        return earthGlass;
      case 'fire':
        return fireGlass;
      case 'water':
        return waterGlass;
      case 'wind':
        return windGlass;
      default:
        return primaryGlass;
    }
  }

  static Color getElementSolidColor(String element) {
    switch (element.toLowerCase()) {
      case 'earth':
        return earthSolid;
      case 'fire':
        return fireSolid;
      case 'water':
        return waterSolid;
      case 'wind':
        return windSolid;
      default:
        return primaryGlass;
    }
  }
}