import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core colors
  static const Color primary = Color(0xFF3E63F5);
  static const Color secondary = Color(0xFF5D7BFF);
  
  // Accents
  static const Color accentPink = Color(0xFFFF4D94);
  static const Color accentPurple = Color(0xFF8A4DFF);
  static const Color accentCyan = Color(0xFF5BE7FF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentPink,
      accentPurple,
      primary,
    ],
  );

  // Background and Surface
  static const Color background = Color(0xFFFAF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color bottomNavigation = Color(0xFF111111);
  static const Color inputBackground = Color(0xFFF7F9FC);
  static const Color stepIndicatorInactive = Color(0xFFD6DFFF);
  
  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textHint = Color(0xFFA1A1AA);
  
  // Lines
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFECECEC);
  
  // Status
  static const Color success = Color(0xFF39D353);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Badges & Indicators
  static const Color liveBadge = Color(0xFFFF2D2D);
  static const Color onlineIndicator = Color(0xFF30D158);
}
