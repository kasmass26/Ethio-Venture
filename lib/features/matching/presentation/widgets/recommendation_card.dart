import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/presentation/widgets/match_breakdown_dialog.dart';
import 'package:ethioventure/features/matching/presentation/widgets/match_score_badge.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationEntity recommendation;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onContact;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onBookmarkToggle,
    this.onContact,
  });

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final startup = recommendation.startup;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(
          color: recommendation.grade == MatchGrade.excellent
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
          width: recommendation.grade == MatchGrade.excellent ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Match Score + Tags + Bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MatchScoreBadge(
                  score: recommendation.compatibilityScore,
                  grade: recommendation.grade,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    recommendation.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: recommendation.isBookmarked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  onPressed: onBookmarkToggle,
                  tooltip: 'Save to watchlist',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Startup Name & Tagline
            Text(
              startup.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              startup.tagline,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Tags: Industry, Funding Stage, Location
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTag(startup.industry, const Color(0xFF1B4332)),
                _buildTag(startup.fundingStage, const Color(0xFF2D6A4F)),
                _buildTag(startup.location, const Color(0xFF52796F), icon: Icons.location_on_outlined),
                _buildTag(
                  'Target: ${_formatCurrency(startup.targetFunding)}',
                  const Color(0xFFB08968),
                  icon: Icons.monetization_on_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // "Why this startup matches" callout
            if (recommendation.matchReasons.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 5),
                        Text(
                          'Why It Matches Your Thesis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...recommendation.matchReasons.take(2).map(
                      (reason) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => MatchBreakdownDialog(recommendation: recommendation),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('View Breakdown'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContact ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Connected with ${startup.name} founder!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
