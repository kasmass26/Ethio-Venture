import 'package:ethioventure/core/enums/app_enums.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Professional, responsive presentation widget displaying an Investor's Profile & Thesis.
class InvestorProfileDisplayWidget extends StatelessWidget {
  const InvestorProfileDisplayWidget({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  final InvestorProfileEntity profile;
  final VoidCallback onEdit;

  String _formatCurrency(double? amount) {
    if (amount == null) return 'N/A';
    final integerPart = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$integerPart';
  }

  String _formatInvestorType(String raw) {
    final type = InvestorType.fromString(raw);
    switch (type) {
      case InvestorType.angel:
        return 'Angel Investor';
      case InvestorType.vc:
        return 'Venture Capital';
      case InvestorType.firm:
        return 'Investment Firm / Syndicate';
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of EthioVenture?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
              Supabase.instance.client.auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final orgName = (profile.organizationName != null &&
            profile.organizationName!.trim().isNotEmpty)
        ? profile.organizationName!
        : 'Investor Entity';

    final initial = orgName.substring(0, 1).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Hero Header Banner ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.surfaceDark,
                      AppColors.backgroundDark,
                    ]
                  : [
                      AppColors.secondary,
                      AppColors.secondaryLight,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.secondary)
                    .withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Monogram
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                orgName,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 20,
                              color: Color(0xFFFFB800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: Text(
                            _formatInvestorType(profile.investorType),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.xs),
                  // Edit Action Button (using Material InkWell to avoid button theme constraint issues)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              // Geographic focus pill tags
              if (profile.geographicFocus.isNotEmpty) ...[
                Wrap(
                  spacing: AppSizes.xs,
                  runSpacing: AppSizes.xs,
                  children: profile.geographicFocus.map((geo) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            geo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // ── 2. Stat Summary Cards ─────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 520) {
              return Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.primaryDark,
                      title: 'Ticket Range',
                      value:
                          '${_formatCurrency(profile.ticketSizeMin)} - ${_formatCurrency(profile.ticketSizeMax)}',
                      subtitle: 'USD Range',
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.category_outlined,
                      iconColor: AppColors.secondary,
                      title: 'Industries',
                      value: '${profile.preferredIndustries.length} Sectors',
                      subtitle: 'Active Focus',
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.timeline_outlined,
                      iconColor: const Color(0xFFFFB800),
                      title: 'Target Stages',
                      value: '${profile.preferredStages.length} Stages',
                      subtitle: 'Deal Criteria',
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _MetricCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.primaryDark,
                  title: 'Ticket Range',
                  value:
                      '${_formatCurrency(profile.ticketSizeMin)} - ${_formatCurrency(profile.ticketSizeMax)}',
                  subtitle: 'USD Range',
                ),
                const SizedBox(height: AppSizes.sm),
                _MetricCard(
                  icon: Icons.category_outlined,
                  iconColor: AppColors.secondary,
                  title: 'Industries',
                  value: '${profile.preferredIndustries.length} Sectors',
                  subtitle: 'Active Focus',
                ),
                const SizedBox(height: AppSizes.sm),
                _MetricCard(
                  icon: Icons.timeline_outlined,
                  iconColor: const Color(0xFFFFB800),
                  title: 'Target Stages',
                  value: '${profile.preferredStages.length} Stages',
                  subtitle: 'Deal Criteria',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.lg),

        // ── 3. Investment Thesis Bio ──────────────────────────────────────────
        _SectionCard(
          title: 'Investment Thesis & Bio',
          icon: Icons.article_outlined,
          child: Text(
            (profile.bio != null && profile.bio!.trim().isNotEmpty)
                ? profile.bio!
                : 'No overview bio provided yet. Click "Edit Profile" to add details about your fund, thesis, and value-add.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: (profile.bio == null || profile.bio!.trim().isEmpty)
                  ? (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary),
              fontStyle: (profile.bio == null || profile.bio!.trim().isEmpty)
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // ── 4. Preferred Industries ───────────────────────────────────────────
        _SectionCard(
          title: 'Preferred Investment Sectors',
          icon: Icons.domain_outlined,
          child: profile.preferredIndustries.isEmpty
              ? Text(
                  'No preferred industries selected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                )
              : Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: profile.preferredIndustries.map((industry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.primarySoft,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            industry,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: AppSizes.lg),

        // ── 5. Target Funding Stages ──────────────────────────────────────────
        _SectionCard(
          title: 'Target Funding Stages',
          icon: Icons.stars_outlined,
          child: profile.preferredStages.isEmpty
              ? Text(
                  'No target stages selected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                )
              : Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: profile.preferredStages.map((stage) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariant
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 16,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: AppSizes.xl),

        // ── 6. Bottom Actions Card ────────────────────────────────────────────
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 480;

                final signOutBtn = OutlinedButton(
                  onPressed: () => _confirmLogout(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.coral),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: AppColors.coral,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(color: AppColors.coral),
                      ),
                    ],
                  ),
                );

                final editBtn = ElevatedButton(
                  onPressed: onEdit,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Thesis'),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: signOutBtn),
                      const SizedBox(width: AppSizes.md),
                      Expanded(child: editBtn),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    editBtn,
                    const SizedBox(height: AppSizes.sm),
                    signOutBtn,
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}
