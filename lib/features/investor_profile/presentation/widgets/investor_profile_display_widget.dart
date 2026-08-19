import 'dart:ui';

import 'package:ethioventure/core/enums/app_enums.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Premium, responsive presentation widget displaying an Investor's Profile & Thesis.
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

  IconData _investorTypeIcon(String raw) {
    final type = InvestorType.fromString(raw);
    switch (type) {
      case InvestorType.angel:
        return Icons.auto_awesome_outlined;
      case InvestorType.vc:
        return Icons.rocket_launch_outlined;
      case InvestorType.firm:
        return Icons.corporate_fare_outlined;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
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
        _HeroHeader(
          orgName: orgName,
          initial: initial,
          investorTypeLabel: _formatInvestorType(profile.investorType),
          investorTypeIcon: _investorTypeIcon(profile.investorType),
          geographicFocus: profile.geographicFocus,
          onEdit: onEdit,
          isDark: isDark,
        ),
        const SizedBox(height: AppSizes.lg),

        // ── Stat Summary Cards ─────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _MetricCard(
                icon: Icons.account_balance_wallet_outlined,
                accentColor: AppColors.primaryDark,
                title: 'TICKET RANGE',
                value:
                    '${_formatCurrency(profile.ticketSizeMin)} – ${_formatCurrency(profile.ticketSizeMax)}',
                subtitle: 'USD Range',
                isDark: isDark,
              ),
              _MetricCard(
                icon: Icons.category_outlined,
                accentColor: AppColors.secondary,
                title: 'INDUSTRIES',
                value: '${profile.preferredIndustries.length}',
                subtitle: 'Active Focus Sectors',
                isDark: isDark,
              ),
              _MetricCard(
                icon: Icons.timeline_outlined,
                accentColor: const Color(0xFFC9932E),
                title: 'TARGET STAGES',
                value: '${profile.preferredStages.length}',
                subtitle: 'Deal Criteria',
                isDark: isDark,
              ),
            ];

            if (constraints.maxWidth > 520) {
              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    if (i != 0) const SizedBox(width: AppSizes.sm),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  if (i != 0) const SizedBox(height: AppSizes.sm),
                  cards[i],
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.lg),

        // ── Investment Thesis Bio ─────────────────────────────────────────
        _SectionCard(
          title: 'Investment Thesis & Bio',
          icon: Icons.article_outlined,
          isDark: isDark,
          child: (profile.bio != null && profile.bio!.trim().isNotEmpty)
              ? Container(
                  padding: const EdgeInsets.only(left: AppSizes.md),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    profile.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                )
              : _EmptyState(
                  icon: Icons.edit_note_outlined,
                  message:
                      'No overview bio yet. Add details about your fund, thesis, and value-add.',
                  isDark: isDark,
                ),
        ),
        const SizedBox(height: AppSizes.lg),

        // ── Preferred Industries ────────────────────────────────────────────
        _SectionCard(
          title: 'Preferred Investment Sectors',
          icon: Icons.domain_outlined,
          isDark: isDark,
          child: profile.preferredIndustries.isEmpty
              ? _EmptyState(
                  icon: Icons.domain_disabled_outlined,
                  message: 'No preferred industries selected yet.',
                  isDark: isDark,
                )
              : Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: profile.preferredIndustries.map((industry) {
                    return _Tag(
                      label: industry,
                      icon: Icons.check_circle_outline,
                      color: AppColors.primaryDark,
                      isDark: isDark,
                      filled: true,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: AppSizes.lg),

        // ── Target Funding Stages ───────────────────────────────────────────
        _SectionCard(
          title: 'Target Funding Stages',
          icon: Icons.stars_outlined,
          isDark: isDark,
          child: profile.preferredStages.isEmpty
              ? _EmptyState(
                  icon: Icons.stars_outlined,
                  message: 'No target stages selected yet.',
                  isDark: isDark,
                )
              : Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: profile.preferredStages.map((stage) {
                    return _Tag(
                      label: stage,
                      icon: Icons.bolt,
                      color: const Color(0xFFC9932E),
                      isDark: isDark,
                      filled: false,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: AppSizes.xl),

        // ── Bottom Actions ───────────────────────────────────────────────────
        Container(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 480;

              final signOutBtn = OutlinedButton(
                onPressed: () => _confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  side: BorderSide(
                    color: AppColors.coral.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_outlined, color: AppColors.coral, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600)),
                  ],
                ),
              );

              final editBtn = Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Edit Thesis',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: signOutBtn),
                    const SizedBox(width: AppSizes.md),
                    Expanded(flex: 2, child: editBtn),
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
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Hero header: richer gradient, decorative depth, glass edit button
// ─────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.orgName,
    required this.initial,
    required this.investorTypeLabel,
    required this.investorTypeIcon,
    required this.geographicFocus,
    required this.onEdit,
    required this.isDark,
  });

  final String orgName;
  final String initial;
  final String investorTypeLabel;
  final IconData investorTypeIcon;
  final List<String> geographicFocus;
  final VoidCallback onEdit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.surfaceDark, AppColors.backgroundDark]
                    : [AppColors.secondary, const Color(0xFF1B3A52)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.secondary)
                      .withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    // Avatar with gradient ring + glow
                    final avatar = Container(
                      width: 68,
                      height: 68,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD98A), Color(0xFFFFB800)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySoft,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    );

                    // Glassmorphic edit button
                    final editButton = ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.9),
                          child: InkWell(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 15, color: AppColors.secondary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 340;

                        final titleColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  orgName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 22,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                size: 19,
                                color: Color(0xFFFFB800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(investorTypeIcon, size: 13, color: Colors.white),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    investorTypeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  avatar,
                                  const SizedBox(width: AppSizes.md),
                                  Expanded(child: titleColumn),
                                ],
                              ),
                              const SizedBox(height: AppSizes.md),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: editButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            avatar,
                            const SizedBox(width: AppSizes.md),
                            Expanded(child: titleColumn),
                            const SizedBox(width: AppSizes.xs),
                            editButton,
                          ],
                        );
                      },
                    );
                  },
                ),
                if (geographicFocus.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Wrap(
                    spacing: AppSizes.xs,
                    runSpacing: AppSizes.xs,
                    children: geographicFocus.map((geo) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
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
          // Subtle decorative glow circles for depth
          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB800).withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Metric card with gradient icon chip + top accent bar
// ─────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
            height: 3,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.3)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, color: accentColor, size: 19),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
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
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Section card with icon chip header
// ─────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared tag/chip for industries & stages
// ─────────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: filled
            ? color.withValues(alpha: isDark ? 0.16 : 0.1)
            : (isDark ? AppColors.surfaceVariant : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled
              ? color.withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Empty state helper
// ─────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  final IconData icon;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: muted,
            ),
          ),
        ),
      ],
    );
  }
}