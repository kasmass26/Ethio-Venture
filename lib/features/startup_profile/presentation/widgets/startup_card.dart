import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:flutter/material.dart';

/// Card displaying a summary of a [StartupProfileEntity] in the discovery list.
///
/// Displays: name, summary, industry badge, stage badge, location, and
/// funding target. Tapping the card calls [onTap] (reserved for the detail
/// page in a later step).
class StartupCard extends StatelessWidget {
  const StartupCard({
    super.key,
    required this.startup,
    this.onTap,
  });

  final StartupProfileEntity startup;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: name + badges ───────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company initial avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      startup.startupName.isNotEmpty
                          ? startup.startupName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.startupName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Wrap(
                          spacing: AppSizes.xs,
                          runSpacing: AppSizes.xs,
                          children: [
                            _Badge(
                              label: startup.industry,
                              color: isDark
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              background: isDark
                                  ? AppColors.primaryDark.withAlpha(77)
                                  : AppColors.primarySoft,
                            ),
                            _Badge(
                              label: startup.fundingStage,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              background: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Summary ────────────────────────────────────────────────
              if (startup.description.isNotEmpty) ...[
                const SizedBox(height: AppSizes.md),
                Text(
                  startup.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: AppSizes.md),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.md),

              // ── Row 2: location + funding target ───────────────────────
              Row(
                children: [
                  if (startup.location.isNotEmpty) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconSm,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        startup.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  const SizedBox(width: AppSizes.sm),
                  Icon(
                    Icons.trending_up,
                    size: AppSizes.iconSm,
                    color: isDark ? AppColors.primary : AppColors.secondary,
                  ),
                  const SizedBox(width: AppSizes.xs),
                  Text(
                    _formatFunding(startup.fundingAmountNeeded),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatFunding(double amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '\$${m == m.truncateToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '\$${k == k.truncateToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }
}

// ── Small private badge widget ─────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
