import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/match_result_entity.dart';
import 'match_criteria_row.dart';
import 'match_score_badge.dart';

/// A card displaying a recommended startup with:
///   • Startup business name, industry, funding stage, location, amount
///   • Overall match score badge
///   • Criteria breakdown (industry / stage / amount / location)
class RecommendationCard extends StatefulWidget {
  const RecommendationCard({
    super.key,
    required this.result,
    this.onMessageTap,
    this.isOpeningConversation = false,
  });

  final MatchResultEntity result;
  final VoidCallback? onMessageTap;

  /// When true, the Message button shows a loading spinner — set while the
  /// cubit is calling getOrCreateConversation for this specific card.
  final bool isOpeningConversation;

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;
    final s = result.startup;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs + 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: avatar + name + score ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StartupAvatar(name: s.businessName),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.businessName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (s.industry != null || s.fundingStage != null) ...[
                        const SizedBox(height: 4),
                        _ChipRow(
                          items: [
                            if (s.industry != null) s.industry!,
                            if (s.fundingStage != null)
                              _formatStage(s.fundingStage!),
                          ],
                        ),
                      ],
                      if (s.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              s.location!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (s.fundingAmountSought != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              _formatAmount(s.fundingAmountSought!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                MatchScoreBadge(score: result.overallScore),
              ],
            ),

            // ── Description ────────────────────────────────────────────────
            if (s.description != null && s.description!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                s.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: AppSizes.sm),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSizes.sm),

            // ── Match criteria breakdown ────────────────────────────────────
            MatchCriteriaRow(
              label: 'Industry',
              matched: result.industryMatch,
              matchText: result.industryMatch ? 'Match' : 'No match',
            ),
            MatchCriteriaRow(
              label: 'Funding Stage',
              matched: result.stageMatch,
              matchText: result.stageMatch ? 'Match' : 'No match',
            ),
            MatchCriteriaRow(
              label: 'Investment Amount',
              matched: result.amountCompatible,
              matchText:
                  result.amountCompatible ? 'Compatible' : 'Out of range',
            ),
            MatchCriteriaRow(
              label: 'Location',
              matched: result.locationMatch,
              matchText: result.locationMatch ? 'Match' : 'No match',
            ),

            // ── Actions ────────────────────────────────────────────────────
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(
                      _expanded ? 'Less' : 'Details',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () =>
                        setState(() => _expanded = !_expanded),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    icon: widget.isOpeningConversation
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Icon(Icons.chat_bubble_outline, size: 16),
                    label: Text(
                      widget.isOpeningConversation ? 'Opening…' : 'Message',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: widget.isOpeningConversation
                        ? null
                        : widget.onMessageTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatStage(String stage) {
    return stage
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}

// ── helpers ────────────────────────────────────────────────────────────────

class _StartupAvatar extends StatelessWidget {
  const _StartupAvatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.secondarySoft,
      child: Text(
        _initials(name),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.xs,
      runSpacing: AppSizes.xs,
      children: items
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
