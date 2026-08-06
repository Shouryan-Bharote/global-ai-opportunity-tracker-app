import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Poppins';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
    
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
    labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
