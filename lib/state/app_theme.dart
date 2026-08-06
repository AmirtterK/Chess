import 'package:flutter/material.dart';

class AppThemePreset {
  final String name;
  final Color lightTile;
  final Color darkTile;
  final Color accent;
  final String pieceTheme;
  final LinearGradient background;

  const AppThemePreset({
    required this.name,
    required this.lightTile,
    required this.darkTile,
    required this.accent,
    required this.pieceTheme,
    required this.background,
  });
}

const List<AppThemePreset> appThemes = [
  AppThemePreset(
    name: 'Black & Purple',
    lightTile: Color(0xFFE9E6EA),
    darkTile: Color(0xFF5D5A60),
    accent: Color(0xFFDC3FDF),
    pieceTheme: 'neon',
    background: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF08080A), Color(0xFF120D16), Color(0xFF21112A)],
    ),
  ),
  AppThemePreset(
    name: 'Slate Night',
    lightTile: Color(0xFFE7EBF0),
    darkTile: Color(0xFF34414F),
    accent: Color(0xFF9EB4C8),
    pieceTheme: 'metal',
    background: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF11161C), Color(0xFF1B2430), Color(0xFF28313D)],
    ),
  ),
  AppThemePreset(
    name: 'Amber Sand',
    lightTile: Color(0xFFF7E6C9),
    darkTile: Color(0xFF7E5A2D),
    accent: Color(0xFFE0A94A),
    pieceTheme: 'wood',
    background: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1C1510), Color(0xFF2C2218), Color(0xFF433221)],
    ),
  ),
  AppThemePreset(
    name: 'Ink Violet',
    lightTile: Color(0xFFF1E7FF),
    darkTile: Color(0xFF3F2E66),
    accent: Color(0xFFB79BFF),
    pieceTheme: 'glass',
    background: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF140F1F), Color(0xFF241A35), Color(0xFF33254C)],
    ),
  ),
  AppThemePreset(
    name: 'Gradient',
    lightTile: Color(0xFFE9E6EA),
    darkTile: Color(0xFF5D5A60),
    accent: Color(0xFFDC3FDF),
    pieceTheme: 'tournament',
    background: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF08080A), Color(0xFF21112A)],
    ),
  ),
  AppThemePreset(
    name: 'Simple Black',
    lightTile: Color(0xFFE9E6EA),
    darkTile: Color(0xFF5D5A60),
    accent: Color(0xFFDC3FDF),
    pieceTheme: 'classic',
    background: LinearGradient(
      colors: [Color(0xFF08080A), Color(0xFF08080A)],
    ),
  ),
];
