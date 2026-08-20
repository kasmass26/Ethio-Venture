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
        return 'Venture Capital Fund';
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

  int _calculateCompleteness() {
    int score = 20; // Base profile
    if (profile.organizationName != null && profile.organizationName!.trim().isNotEmpty) score += 20;
    if (profile.bio != null && profile.bio!.trim().isNotEmpty) score += 20;
    if (profile.preferredIndustries.isNotEmpty) score += 20;
    if (profile.preferredStages.isNotEmpty) score += 10;
    if (profile.ticketSizeMin != null || profile.ticketSizeMax != null) score += 10;
    return score.clamp(0, 100);
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.coral, size: 22),
            SizedBox(width: 10),
            Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your EthioVenture investor portal session?',
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
    final completenessScore = _calculateCompleteness();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Glassmorphic Hero Header ─────────────────────────────────────────
        _HeroHeader(
          orgName: orgName,
          initial: initial,
          investorTypeLabel: _formatInvestorType(profile.investorType),
          investorTypeIcon: _investorTypeIcon(profile.investorType),
          geographicFocus: profile.geographicFocus,
          completenessScore: completenessScore,
          onEdit: onEdit,
          isDark: isDark,
        ),
        const SizedBox(height: AppSizes.lg),

        // ── Completeness Banner (if under 100%) ──────────────────────────────
        if (completenessScore < 100) ...[
          _CompletenessBanner(
            score: completenessScore,
            onEdit: onEdit,
            isDark: isDark,
          ),
          const SizedBox(height: AppSizes.lg),
        ],

        // ── Stat Summary Cards ─────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _MetricCard(
                icon: Icons.payments_outlined,
                accentColor: AppColors.primaryDark,
                title: 'TICKET RANGE',
                value:
                    '${_formatCurrency(profile.ticketSizeMin)} – ${_formatCurrency(profile.ticketSizeMax)}',
                subtitle: 'USD Investment Check Size',
                isDark: isDark,
              ),
              _MetricCard(
                icon: Icons.category_outlined,
                accentColor: AppColors.secondary,
                title: 'FOCUS SECTORS',
                value: '${profile.preferredIndustries.length} Industries',
                subtitle: profile.preferredIndustries.isNotEmpty
                    ? profile.preferredIndustries.take(2).join(', ')
                    : 'Not specified',
                isDark: isDark,
              ),
              _MetricCard(
                icon: Icons.timeline_outlined,
                accentColor: const Color(0xFFD97706),
                title: 'TARGET STAGES',
                value: '${profile.preferredStages.length} Stages',
                subtitle: profile.preferredStages.isNotEmpty
                    ? profile.preferredStages.join(', ')
                    : 'Not specified',
                isDark: isDark,
              ),
            ];

            if (constraints.maxWidth > 600) {
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

        // ── Investment Thesis & Overview ───────────────────────────────────
        _SectionCard(
          title: 'Investment Thesis & Overview',
          icon: Icons.article_outlined,
          isDark: isDark,
          child: (profile.bio != null && profile.bio!.trim().isNotEmpty)
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.backgroundDark.withValues(alpha: 0.5)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    profile.bio!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 14.5,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                )
              : _EmptyState(
                  icon: Icons.edit_note_outlined,
                  message:
                      'No overview bio yet. Add details about your fund, thesis, and value-add to attract top founders.',
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
                      icon: Icons.check_circle_rounded,
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
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFFD97706),
                      isDark: isDark,
                      filled: false,
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: AppSizes.xl),

        // ── Bottom Actions Bar ──────────────────────────────────────────────
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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
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
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
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
                            'Edit Thesis Criteria',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
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
// Hero Header Component
// ─────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.orgName,
    required this.initial,
    required this.investorTypeLabel,
    required this.investorTypeIcon,
    required this.geographicFocus,
    required this.completenessScore,
    required this.onEdit,
    required this.isDark,
  });

  final String orgName;
  final String initial;
  final String investorTypeLabel;
  final IconData investorTypeIcon;
  final List<String> geographicFocus;
  final int completenessScore;
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
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [AppColors.secondary, const Color(0xFF1E3A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.secondary)
                      .withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 420;

                    // Avatar with glowing ring
                    final avatar = Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySoft,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
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
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.15),
                          child: InkWell(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                                vertical: AppSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.white,
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

                    final titleColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                              Icons.verified_rounded,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(investorTypeIcon,
                                      size: 13, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      investorTypeLabel,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.25),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSm),
                                border: Border.all(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 12,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$completenessScore% Profile Strength',
                                    style: const TextStyle(
                                      color: Color(0xFF6EE7B7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                          vertical: 5,
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
          // Decorative background depth elements
          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
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
// Completeness Banner Component
// ─────────────────────────────────────────────────────────────────────────
class _CompletenessBanner extends StatelessWidget {
  const _CompletenessBanner({
    required this.score,
    required this.onEdit,
    required this.isDark,
  });

  final int score;
  final VoidCallback onEdit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Completeness: $score%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: isDark
                        ? AppColors.borderDark
                        : AppColors.primary.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryDark,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add missing details to rank higher in AI startup deal-flow matches.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Metric card with accent bar
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
            height: 3.5,
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
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
// Section Card Container
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
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
            ? color.withValues(alpha: isDark ? 0.18 : 0.1)
            : (isDark ? AppColors.surfaceVariant : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(12),
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
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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