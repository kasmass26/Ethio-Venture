import 'package:flutter/material.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';

class MatchScoreBadge extends StatelessWidget {
  final double score;
  final MatchGrade grade;
  final bool isCompact;

  const MatchScoreBadge({
    super.key,
    required this.score,
    required this.grade,
    this.isCompact = false,
  });

  Color _getBadgeColor() {
    switch (grade) {
      case MatchGrade.excellent:
        return const Color(0xFF1B4332); // Deep Forest Green
      case MatchGrade.high:
        return const Color(0xFF2D6A4F); // Vibrant Green
      case MatchGrade.moderate:
        return const Color(0xFFD97706); // Amber / Gold
      case MatchGrade.fair:
        return const Color(0xFF6B7280); // Slate Gray
    }
  }

  Color _getBackgroundColor() {
    switch (grade) {
      case MatchGrade.excellent:
        return const Color(0xFFE8F5E9);
      case MatchGrade.high:
        return const Color(0xFFE8F5E9);
      case MatchGrade.moderate:
        return const Color(0xFFFEF3C7);
      case MatchGrade.fair:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getBadgeColor();
    final bgColor = _getBackgroundColor();

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 12, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toInt()}% MATCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
