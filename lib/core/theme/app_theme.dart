import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = ThemeData.light().textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: AppColors.emerald,
        onPrimary: AppColors.white,
        secondary: AppColors.violet,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.ink,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.hairline,
      ),

      scaffoldBackgroundColor: AppColors.fog,

      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.ink,
          height: 1.45,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.ink,
          height: 1.45,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.slate,
          height: 1.4,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fog,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: _inputBorder(AppColors.hairline),
        enabledBorder: _inputBorder(AppColors.hairline),
        focusedBorder: _inputBorder(AppColors.emerald, width: 1.5),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.5),
        hintStyle: const TextStyle(
          color: AppColors.slate,
        ),
        labelStyle: const TextStyle(
          color: AppColors.slate,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(
            color: AppColors.hairline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.emerald,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.emeraldTint,
        selectedColor: AppColors.emerald,
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.radiusXl,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        space: 1,
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.emeraldTint,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          color: AppColors.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.emerald,
        onPrimary: AppColors.white,
        secondary: AppColors.violet,
        onSecondary: AppColors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        outline: AppColors.borderDark,
      ),

      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: const BorderSide(
            color: AppColors.borderDark,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: _inputBorder(AppColors.borderDark),
        enabledBorder: _inputBorder(AppColors.borderDark),
        focusedBorder: _inputBorder(
          AppColors.emerald,
          width: 1.5,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSizes.radiusMd,
            ),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppSizes.radiusMd,
      ),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
