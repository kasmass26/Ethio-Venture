import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular badge showing the overall match percentage (e.g. "85%").
class MatchScoreBadge extends StatelessWidget {
  const MatchScoreBadge({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = _colorForScore(score);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '$score%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }

  static Color _colorForScore(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.textSecondary;
  }
}
