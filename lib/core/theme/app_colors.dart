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

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color error = Color(0xFFBA1A1A);

  static const Color success = Color(0xFF11845B);

  static const Color successSoft = Color(0xFFE1F5EE);

  static const Color warning = Color(0xFF9A6700);

  static const Color warningSoft = Color(0xFFFFF4D6);

  // ---------------------------------------------------------------------------
  // Compatibility / general-purpose theme tokens
  // ---------------------------------------------------------------------------

  static const Color primary = emerald;

  static const Color primaryDark = Color(0xFF0A5945);

  static const Color primarySoft = emeraldTint;

  static const Color secondary = violet;

  static const Color secondaryLight = Color(0xFF6862B8);

  static const Color secondarySoft = violetTint;

  static const Color background = fog;

  static const Color surface = white;

  static const Color surfaceVariant = Color(0xFFEAE8E0);

  static const Color onSurface = ink;

  static const Color textPrimary = ink;

  static const Color textSecondary = slate;

  static const Color border = hairline;

  static const Color divider = hairline;

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static const Color backgroundDark = Color(0xFF1F211F);

  static const Color surfaceDark = Color(0xFF292B29);

  static const Color textPrimaryDark = Color(0xFFF5F3EC);

  static const Color textSecondaryDark = Color(0xFFC6C4BC);

  static const Color borderDark = Color(0xFF484A46);
}
