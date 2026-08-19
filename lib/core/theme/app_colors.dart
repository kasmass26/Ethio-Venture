import 'package:flutter/material.dart';

/// Ethio Venture design-system color tokens.
///
/// Use these tokens throughout the application instead of defining
/// raw colors inside feature widgets.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Action Cyan: primary calls to action and active states.
  static const Color primary = Color(0xFF00D1FF);
  static const Color primaryDark = Color(0xFF009BC2);
  static const Color primarySoft = Color(0xFFE1F8FF);

  /// Trust Navy: brand, headings, and structural emphasis.
  static const Color secondary = Color(0xFF0A2540);
  static const Color secondaryLight = Color(0xFF21496E);
  static const Color secondarySoft = Color(0xFFE8F0F8);

  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5FC);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color textPrimary = onSurface;
  static const Color textSecondary = Color(0xFF536273);
  static const Color border = Color(0xFFCBDBF5);
  static const Color divider = Color(0xFFE0EAF8);

  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF11845B);
  static const Color successSoft = Color(0xFFE0F6EC);
  static const Color warning = Color(0xFF9A6700);
  static const Color warningSoft = Color(0xFFFFF4D6);

  static const Color backgroundDark = Color(0xFF071827);
  static const Color surfaceDark = Color(0xFF0D2134);
  static const Color textPrimaryDark = Color(0xFFF5FAFF);
  static const Color textSecondaryDark = Color(0xFFB7C7D8);
  static const Color borderDark = Color(0xFF294661);

  /// Founder / startup identity.
  static const Color emerald = Color(0xFF0F6E56);

  /// Soft emerald background.
  static const Color emeraldTint = Color(0xFFE1F5EE);

  /// Investor identity.
  static const Color violet = Color(0xFF7F77DD);

  /// Soft violet background.
  static const Color violetTint = Color(0xFFEEEDFE);

  /// Supporting action/accent color.
  static const Color coral = Color(0xFFD85A30);

  // ---------------------------------------------------------------------------
  // Neutral
  // ---------------------------------------------------------------------------

  static const Color ink = Color(0xFF2C2C2A);

  static const Color slate = Color(0xFF5F5E5A);

  static const Color hairline = Color(0xFFD3D1C7);

  static const Color fog = Color(0xFFF1EFE8);

  static const Color white = Color(0xFFFFFFFF);
}

