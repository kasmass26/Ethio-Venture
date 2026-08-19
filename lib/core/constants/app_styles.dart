import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Centralized typography so screens never hardcode TextStyle values.
class AppTextStyles {
  AppTextStyles._();

  static const String _mono = 'monospace';

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    letterSpacing: -0.3,
  );

  static const TextStyle greeting = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle cardLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle bigStat = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    letterSpacing: -0.5,
  );

  static const TextStyle bigStatUnit = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle deltaPositive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
    fontFamily: _mono,
  );

  static const TextStyle checklistDone = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle checklistPending = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    fontFamily: _mono,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    letterSpacing: -0.3,
  );

  static const TextStyle investorName = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static const TextStyle investorLocation = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle tag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryLight,
    fontFamily: _mono,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    fontFamily: _mono,
  );

  static const TextStyle buttonOutline = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    fontFamily: _mono,
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    fontFamily: _mono,
  );

  // --- Investor dashboard ---------------------------------------------------

  static const TextStyle statLabelCaps = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    fontFamily: _mono,
    letterSpacing: 0.6,
  );

  static const TextStyle deltaNeutral = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle deltaWarning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
    fontFamily: _mono,
  );

  static const TextStyle linkAction = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
    fontFamily: _mono,
  );

  static const TextStyle matchScore = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    fontFamily: _mono,
  );

  static const TextStyle startupName = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    letterSpacing: -0.2,
  );

  static const TextStyle startupTagline = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle activityBody = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle activityActor = TextStyle(
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static const TextStyle activityTimestamp = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle trackedStartupName = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
  );

  static const TextStyle trackedStartupGoal = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle progressLabel = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    fontFamily: _mono,
  );

  static const TextStyle progressPercent = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.secondary,
    fontFamily: _mono,
  );
}


