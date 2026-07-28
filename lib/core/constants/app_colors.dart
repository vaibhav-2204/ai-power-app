import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color primaryLight = Color(0xFF8B85FF);

  // Accent / Neon
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentPink = Color(0xFFFF4081);

  // Background
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color bgCard = Color(0xFF1A1F38);
  static const Color bgCardLight = Color(0xFF252A45);
  static const Color bgSurface = Color(0xFF111631);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3C5);
  static const Color textHint = Color(0xFF6C7093);

  // Functional
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [bgDark, Color(0xFF141A3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [bgCard, bgCardLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [accentOrange, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
