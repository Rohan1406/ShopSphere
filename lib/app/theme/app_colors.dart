import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand Primary & Accents
  static const primary = Color(0xFF4F46E5); // Modern Electric Indigo
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);
  static const primarySurface = Color(0xFFEEF2FF);

  static const secondary = Color(0xFFEC4899); // Vibrant Rose
  static const secondaryLight = Color(0xFFF472B6);
  static const secondarySurface = Color(0xFFFDF2F8);

  static const coral = Color(0xFFF43F5E); // Hot Coral / New Badge
  static const coralSurface = Color(0xFFFFF1F2);

  static const accent = Color(0xFF06B6D4); // Cyan
  static const accentLight = Color(0xFF67E8F9);

  static const amber = Color(0xFFF59E0B); // Gold / Rating
  static const amberLight = Color(0xFFFEF3C7);

  // Background & Surfaces
  static const background = Color(0xFFF8FAFC); // Clean Slate Canvas
  static const surface = Colors.white;
  static const surfaceSubtle = Color(0xFFF1F5F9);
  static const surfaceHighlight = Color(0xFFF8FAFC);
  static const surfaceDark = Color(0xFF0F172A);

  // Typography & Content
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const textInverse = Colors.white;

  // Feedback & Status
  static const error = Color(0xFFEF4444);
  static const errorSurface = Color(0xFFFEF2F2);
  static const success = Color(0xFF10B981);
  static const successSurface = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Border & Dividers
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunsetGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
