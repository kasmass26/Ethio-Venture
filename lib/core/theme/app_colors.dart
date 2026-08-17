import 'package:flutter/material.dart';

/// Ethio Venture's brand tokens. Use these values instead of raw colors in UI.
class AppColors {
  AppColors._();

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
}
