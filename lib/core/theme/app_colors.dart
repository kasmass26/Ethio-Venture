import 'package:flutter/material.dart';

/// Static token pattern — every widget references these tokens,
/// never a raw hex value. Fill in the real brand palette; placeholders below.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B4332);      // deep green - trust/growth
  static const Color primaryLight = Color(0xFF52796F);
  static const Color secondary = Color(0xFFB08968);     // warm gold accent
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2D6A4F);
  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color border = Color(0xFFE0E0E0);

  // Dark mode counterparts
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFF1F1F1);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
}
