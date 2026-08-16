import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/matching/domain/entities/recommendation_entity.dart';
import 'package:ethioventure/features/matching/presentation/widgets/match_score_badge.dart';

class MatchBreakdownDialog extends StatelessWidget {
  final RecommendationEntity recommendation;

  const MatchBreakdownDialog({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final breakdown = recommendation.scoreBreakdown;
    final startup = recommendation.startup;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${startup.industry} • ${startup.fundingStage}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MatchScoreBadge(
                    score: recommendation.compatibilityScore,
                    grade: recommendation.grade,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              const Divider(),
              const SizedBox(height: AppSizes.sm),

              // Title
              const Text(
                'Compatibility Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Criteria 1: Industry
              _buildDimensionBar(
                title: 'Industry Match (35%)',
                score: breakdown.industryScore,
                maxScore: breakdown.maxIndustryScore,
                color: const Color(0xFF1B4332),
                icon: Icons.business,
              ),
              const SizedBox(height: 10),

              // Criteria 2: Funding Stage
              _buildDimensionBar(
                title: 'Funding Stage Match (25%)',
                score: breakdown.stageScore,
                maxScore: breakdown.maxStageScore,
                color: const Color(0xFF2D6A4F),
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 10),

              // Criteria 3: Investment Amount
              _buildDimensionBar(
                title: 'Investment Amount (25%)',
                score: breakdown.amountScore,
                maxScore: breakdown.maxAmountScore,
                color: const Color(0xFF52796F),
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 10),

              // Criteria 4: Location
              _buildDimensionBar(
                title: 'Location Match (15%)',
                score: breakdown.locationScore,
                maxScore: breakdown.maxLocationScore,
                color: const Color(0xFFB08968),
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: AppSizes.md),
              const Divider(),
              const SizedBox(height: AppSizes.sm),

              // Match Reasons
              const Text(
                'Why This Startup Matches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              if (recommendation.matchReasons.isEmpty)
                const Text(
                  'General platform discovery candidate.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                )
              else
                ...recommendation.matchReasons.map(
                  (reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: Color(0xFF2D6A4F)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Breakdown'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionBar({
    required String title,
    required double score,
    required double maxScore,
    required Color color,
    required IconData icon,
  }) {
    final fraction = maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    final percentage = (fraction * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${score.toInt()}/${maxScore.toInt()} pts ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: score > 0 ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              score > 0 ? color : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }
}
