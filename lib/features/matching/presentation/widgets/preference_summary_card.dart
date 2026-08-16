import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_entity.dart';

class PreferenceSummaryCard extends StatelessWidget {
  final InvestorEntity investor;
  final VoidCallback? onSwitchProfile;

  const PreferenceSummaryCard({
    super.key,
    required this.investor,
    this.onSwitchProfile,
  });

  String _formatAmount(double? amount) {
    if (amount == null) return 'Flexible';
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(0)}K';
    return '\$$amount';
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = (investor.minInvestmentAmount != null || investor.maxInvestmentAmount != null)
        ? '${_formatAmount(investor.minInvestmentAmount)} – ${_formatAmount(investor.maxInvestmentAmount)}'
        : 'Flexible Ticket';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Investor Name & Switch Button
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        investor.companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onSwitchProfile != null)
                  OutlinedButton.icon(
                    onPressed: onSwitchProfile,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Switch Profile', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Investment Thesis Summary Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Industries Tag
                _buildCriterionChip(
                  icon: Icons.category_outlined,
                  label: investor.preferredIndustries.isNotEmpty
                      ? investor.preferredIndustries.join(', ')
                      : 'All Industries',
                  color: AppColors.primary,
                ),
                // Stages Tag
                _buildCriterionChip(
                  icon: Icons.trending_up,
                  label: investor.preferredFundingStages.isNotEmpty
                      ? investor.preferredFundingStages.join(', ')
                      : 'All Stages',
                  color: const Color(0xFF2D6A4F),
                ),
                // Budget Range Tag
                _buildCriterionChip(
                  icon: Icons.attach_money,
                  label: rangeText,
                  color: const Color(0xFFB08968),
                ),
                // Locations Tag
                _buildCriterionChip(
                  icon: Icons.place_outlined,
                  label: investor.preferredLocations.isNotEmpty
                      ? investor.preferredLocations.join(', ')
                      : 'All Locations',
                  color: const Color(0xFF52796F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
