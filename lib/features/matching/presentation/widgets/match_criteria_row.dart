import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// A single criterion row showing label + match/no-match indicator.
/// Used inside the match card to explain WHY a startup was recommended.
///
/// Example:
///   ✓  Industry          Match
///   ✓  Funding Stage     Match
///   ✓  Investment Amount Compatible
///   ✗  Location          No match
class MatchCriteriaRow extends StatelessWidget {
  const MatchCriteriaRow({
    super.key,
    required this.label,
    required this.matched,
    required this.matchText,
  });

  final String label;
  final bool matched;
  final String matchText;

  @override
  Widget build(BuildContext context) {
    final color = matched ? AppColors.success : AppColors.textSecondary;
    final icon = matched ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            matchText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
