import 'package:ai_nexus/core/theme/app_colors.dart';
import 'package:ai_nexus/core/theme/app_radius.dart';
import 'package:ai_nexus/core/theme/app_spacing.dart';
import 'package:ai_nexus/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      textTheme: AppTypography.textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSpacing.s56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(AppSpacing.s16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontFamily: AppTypography.fontFamily,
          fontSize: 16,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        disabledColor: Colors.white,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: AppTypography.fontFamily,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // =========================
  // DARK THEME
  // =========================
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF16152B);
    const darkBackground = Color(0xFF0C0B18);
    const lightBlueBorder = Color(0x3D3E63F5);

    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: darkSurface,
        outline: lightBlueBorder,
      ),

      scaffoldBackgroundColor: darkBackground,

      textTheme: AppTypography.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSpacing.s56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          textStyle: AppTypography.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF141328),
        contentPadding: const EdgeInsets.all(AppSpacing.s16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: lightBlueBorder,
            width: 1.2,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: lightBlueBorder,
            width: 1.2,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),

        hintStyle: const TextStyle(
          color: Colors.grey,
          fontFamily: AppTypography.fontFamily,
          fontSize: 16,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(
            color: lightBlueBorder,
            width: 1.2,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF191830),
        disabledColor: const Color(0xFF191830),
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: const BorderSide(
            color: lightBlueBorder,
          ),
        ),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontFamily: AppTypography.fontFamily,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: lightBlueBorder,
            width: 1.2,
          ),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: lightBlueBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
