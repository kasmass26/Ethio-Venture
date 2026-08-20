import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:ethioventure/features/investor/presentation/cubit/recommended_startups_cubit.dart';
import 'package:ethioventure/features/investor/presentation/cubit/recommended_startups_state.dart';
import 'package:ethioventure/features/investor/presentation/widgets/app_bottom_nav.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';

/// ============================================================================
/// INVESTOR DASHBOARD — REDESIGN
/// ============================================================================
/// Same treatment as the founder dashboard redesign: self-contained so you
/// can see the whole screen working, built on your real AppColors, and
/// deliberately sharing the founder page's visual language (same radii,
/// spacing, border-not-shadow cards, cyan-for-action / navy-for-structure
/// split) so the two dashboards read as one product.
///
/// Widgets I couldn't see (BrandedAppBar, AppBottomNav, InvestorMetric,
/// RecommendedStartupsSection, RecentActivityCard, TrackedStartupsSection,
/// etc.) were rebuilt inline. Split back into widgets/ once you're happy
/// with the direction — the data classes at the bottom match your originals
/// field-for-field, so nothing else in your app needs to change.
///
/// WHAT'S DIFFERENT FROM THE FOUNDER PAGE, ON PURPOSE
/// - Founder's hero card sells profile completeness (a ring + checklist).
///   Investors don't have a "profile strength" concept, so the hero here is
///   a slim portfolio-pulse strip instead — same navy gradient, much less
///   vertical weight, so it doesn't compete with the deal-flow content below.
/// - Metrics carry a third "neutral" tone (in addition to positive/warning)
///   since investor stats like "Startups Tracked" can legitimately have
///   nothing to report.
/// - Recommended startups show a match-score badge — the one thing founders
///   don't need but investors scan for first.
/// - Tracked startups get a progress bar instead of a delta chip, since
///   funding progress is inherently a "how far along" metric, not a
///   week-over-week change.
/// ============================================================================

class InvestorDashboardPage extends StatefulWidget {
  const InvestorDashboardPage({super.key});

  @override
  State<InvestorDashboardPage> createState() => _InvestorDashboardPageState();
}

class _InvestorDashboardPageState extends State<InvestorDashboardPage> {
  String _userName = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userService = sl<UserService>();
      final user = await userService.getCurrentUser();
      
      if (user != null && mounted) {
        setState(() {
          _userName = userService.getFirstName(user.name);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Mock data (replace with real state from a Cubit/Bloc) ---------------

  static const _metrics = [
    InvestorMetric(
      label: 'Active Deals',
      value: '12',
      deltaText: '+2 this month',
      tone: DeltaTone.positive,
      icon: Icons.sell_outlined,
    ),
    InvestorMetric(
      label: 'Startups Tracked',
      value: '48',
      deltaText: 'No change',
      tone: DeltaTone.neutral,
      icon: Icons.visibility_outlined,
    ),
    InvestorMetric(
      label: 'Unread Messages',
      value: '5',
      deltaText: 'Requires attention',
      tone: DeltaTone.warning,
      icon: Icons.chat_bubble_outline_rounded,
    ),
  ];


  // _recommended is now loaded dynamically via RecommendedStartupsCubit.

  static const _activity = [
    ActivityItem(
      actorName: 'Acme Corp',
      action: 'uploaded a new pitch deck.',
      timeAgo: '2 hours ago',
      kind: ActivityKind.document,
    ),
    ActivityItem(
      actorName: 'GreenTech',
      action: 'requested a meeting.',
      timeAgo: 'Yesterday',
      kind: ActivityKind.meeting,
    ),
    ActivityItem(
      actorName: 'EduNet',
      action: 'closed their Seed round.',
      timeAgo: '3 days ago',
      kind: ActivityKind.milestone,
    ),
  ];

  static const _tracked = [
    TrackedStartup(
      id: 'ts-1',
      name: 'Lomi Logistics',
      fundingGoalLabel: 'Seeking \$500k Seed',
      progressPercent: 75,
    ),
    TrackedStartup(
      id: 'ts-2',
      name: 'Solaris Grid',
      fundingGoalLabel: 'Seeking \$2M Series A',
      progressPercent: 40,
    ),
    TrackedStartup(
      id: 'ts-3',
      name: 'Kifiya Pay',
      fundingGoalLabel: 'Seeking \$150k Pre-Seed',
      progressPercent: 98,
    ),
  ];



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<InvestorProfileCubit>(
          create: (_) => sl<InvestorProfileCubit>()..loadProfile(),
        ),
        BlocProvider<RecommendedStartupsCubit>(
          create: (_) => sl<RecommendedStartupsCubit>(),
        ),
      ],
      child: BlocListener<InvestorProfileCubit, InvestorProfileState>(
        listener: (context, profileState) {
          // Once the investor profile resolves (loaded or empty), trigger
          // the recommendations fetch so it can use the profile preferences.
          if (profileState is InvestorProfileLoaded) {
            context
                .read<RecommendedStartupsCubit>()
                .load(profileState.profile);
          } else if (profileState is InvestorProfileEmpty ||
              profileState is InvestorProfileError) {
            // No profile yet — fetch recent startups with a neutral score.
            context.read<RecommendedStartupsCubit>().load();
          }
        },
        child: _DashboardScaffold(
          userName: _userName,
          metrics: _metrics,
          activity: _activity,
          tracked: _tracked,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold widget — extracted so MultiBlocProvider at the top can provide
// cubits that _DashboardScaffold and its children read from context.
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold({
    required this.userName,
    required this.metrics,
    required this.activity,
    required this.tracked,
  });

  final String userName;
  final List<InvestorMetric> metrics;
  final List<ActivityItem> activity;
  final List<TrackedStartup> tracked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        title: const Text(
          'Investor Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _IconBadgeButton(
            icon: Icons.notifications_none_rounded,
            showDot: true,
            onTap: () {
              // TODO: navigate to notifications.
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: AppBottomNav.investorNavItems,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeStartupSearch,
            );
          } else if (index == 2) {
            Navigator.of(context).pushNamed(
              AppConstants.routeMessages,
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorProfile,
            );
          }
        },
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 28),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PortfolioPulseStrip(
                    activeDeals: '12',
                    userName: userName,
                  ),
                  const SizedBox(height: 20),
                  const _SectionHeading(title: 'Your Overview'),
                  const SizedBox(height: 12),
                  _MetricsGrid(metrics: metrics),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Dynamic recommendations driven by RecommendedStartupsCubit ──
            BlocBuilder<RecommendedStartupsCubit, RecommendedStartupsState>(
              builder: (context, state) {
                return _RecommendedStartupsSection(
                  state: state,
                  onViewAll: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.routeRecommendations,
                    );
                  },
                  onViewProfile: (recommendedItem) {
                    Navigator.of(context).pushNamed(
                      AppConstants.routeStartupDetail,
                      arguments: recommendedItem,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RecentActivityCard(
                    items: activity,
                    onViewAll: () {
                      // TODO: navigate to full activity feed.
                    },
                  ),
                  const SizedBox(height: 16),
                  _TrackedStartupsSection(
                    startups: tracked,
                    onManage: () {
                      Navigator.of(context).pushNamed(
                        AppConstants.routeStartupSearch,
                      );
                    },
                    onTapStartup: (startup) {
                      Navigator.of(context).pushNamed(
                        AppConstants.routeStartupDetail,
                        arguments: startup.id,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;
  const _IconBadgeButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            if (showDot)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _PortfolioPulseStrip extends StatelessWidget {
  final String activeDeals;
  final String userName;
  const _PortfolioPulseStrip({
    required this.activeDeals,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good to see you back, $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3 startups match your thesis this week',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  activeDeals,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'active deals',
                  style: TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section heading (shared shape with founder page)
// ---------------------------------------------------------------------------
class _SectionHeading extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String actionLabel;
  const _SectionHeading({
    required this.title,
    this.onAction,
    this.actionLabel = 'See all',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics grid — 2-up + wide card, tone-aware (positive / neutral / warning)
// ---------------------------------------------------------------------------
class _MetricsGrid extends StatelessWidget {
  final List<InvestorMetric> metrics;
  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(metric: metrics[0])),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(metric: metrics[1])),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(metric: metrics[2], wide: true),
      ],
    );
  }
}

class _ToneColors {
  final Color fg;
  final Color bg;
  const _ToneColors(this.fg, this.bg);
}

_ToneColors _toneColors(DeltaTone tone) {
  switch (tone) {
    case DeltaTone.positive:
      return const _ToneColors(AppColors.success, AppColors.successSoft);
    case DeltaTone.warning:
      return const _ToneColors(AppColors.warning, AppColors.warningSoft);
    case DeltaTone.neutral:
      return const _ToneColors(
        AppColors.textSecondary,
        AppColors.surfaceVariant,
      );
  }
}

class _MetricCard extends StatelessWidget {
  final InvestorMetric metric;
  final bool wide;
  const _MetricCard({required this.metric, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final tone = _toneColors(metric.tone);

    final iconBadge = Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(metric.icon, size: 18, color: AppColors.primaryDark),
    );

    final deltaChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        metric.deltaText,
        style: TextStyle(
          color: tone.fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: wide
          ? Row(
              children: [
                iconBadge,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric.value, style: _valueStyle),
                      const SizedBox(height: 2),
                      Text(metric.label, style: _labelStyle),
                    ],
                  ),
                ),
                deltaChip,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconBadge,
                const SizedBox(height: 12),
                Text(metric.value, style: _valueStyle),
                const SizedBox(height: 2),
                Text(metric.label, style: _labelStyle),
                const SizedBox(height: 10),
                deltaChip,
              ],
            ),
    );
  }

  static const _valueStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );

  static const _labelStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommended startups section — state-aware wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _RecommendedStartupsSection extends StatelessWidget {
  const _RecommendedStartupsSection({
    required this.state,
    required this.onViewAll,
    required this.onViewProfile,
  });

  final RecommendedStartupsState state;
  final VoidCallback onViewAll;
  final ValueChanged<RecommendedStartupItem> onViewProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeading(
            title: 'Recommended For You',
            onAction: state is RecommendedStartupsLoaded ? onViewAll : null,
          ),
        ),
        const SizedBox(height: 12),
        switch (state) {
          RecommendedStartupsLoading() ||
          RecommendedStartupsInitial() =>
            const _RecommendedShimmer(),
          RecommendedStartupsLoaded(:final startups) when startups.isEmpty =>
            const _RecommendedEmpty(),
          RecommendedStartupsLoaded(:final startups) =>
            _RecommendedRail(
              startups: startups,
              onViewProfile: onViewProfile,
            ),
          RecommendedStartupsError(:final message) =>
            _RecommendedError(message: message),
        },
      ],
    );
  }
}

/// Horizontal scrolling rail of real startup cards.
class _RecommendedRail extends StatelessWidget {
  const _RecommendedRail({
    required this.startups,
    required this.onViewProfile,
  });

  final List<RecommendedStartupItem> startups;
  final ValueChanged<RecommendedStartupItem> onViewProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: startups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final startup = startups[i];
          return _StartupCard(
            startup: startup,
            onTap: () => onViewProfile(startup),
          );
        },
      ),
    );
  }
}

/// Three animated shimmer placeholder cards shown while loading.
class _RecommendedShimmer extends StatelessWidget {
  const _RecommendedShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 240,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

/// Shown when the fetch returned an empty list.
class _RecommendedEmpty extends StatelessWidget {
  const _RecommendedEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'No matching startups found. Update your investor profile to get personalised recommendations.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}

/// Shown on network or Supabase error.
class _RecommendedError extends StatelessWidget {
  const _RecommendedError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Could not load recommendations. Please check your connection.',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  final RecommendedStartupItem startup;
  final VoidCallback onTap;
  const _StartupCard({required this.startup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    startup.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${startup.matchScore}% match',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                startup.tagline,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            // Industry + stage tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                startup.industry,
                startup.fundingStage,
              ]
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: const BorderSide(color: AppColors.primaryDark),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Profile',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent activity card
// ---------------------------------------------------------------------------
class _RecentActivityCard extends StatelessWidget {
  final List<ActivityItem> items;
  final VoidCallback onViewAll;
  const _RecentActivityCard({required this.items, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'Recent Activity', onAction: onViewAll),
          const SizedBox(height: 4),
          ...List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return _ActivityRow(item: item, showDivider: !isLast);
          }),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityItem item;
  final bool showDivider;
  const _ActivityRow({required this.item, required this.showDivider});

  ({IconData icon, Color fg, Color bg}) _kindStyle(ActivityKind kind) {
    switch (kind) {
      case ActivityKind.document:
        return (
          icon: Icons.description_outlined,
          fg: AppColors.secondary,
          bg: AppColors.secondarySoft,
        );
      case ActivityKind.meeting:
        return (
          icon: Icons.event_outlined,
          fg: AppColors.primaryDark,
          bg: AppColors.primarySoft,
        );
      case ActivityKind.milestone:
        return (
          icon: Icons.flag_outlined,
          fg: AppColors.success,
          bg: AppColors.successSoft,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _kindStyle(item.kind);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(style.icon, size: 16, color: style.fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: item.actorName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' ${item.action}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tracked startups — funding progress instead of a delta chip
// ---------------------------------------------------------------------------
class _TrackedStartupsSection extends StatelessWidget {
  final List<TrackedStartup> startups;
  final VoidCallback onManage;
  final ValueChanged<TrackedStartup> onTapStartup;
  const _TrackedStartupsSection({
    required this.startups,
    required this.onManage,
    required this.onTapStartup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Tracked Startups',
          onAction: onManage,
          actionLabel: 'Manage',
        ),
        const SizedBox(height: 12),
        ...startups.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TrackedStartupCard(
              startup: s,
              onTap: () => onTapStartup(s),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackedStartupCard extends StatelessWidget {
  final TrackedStartup startup;
  final VoidCallback onTap;
  const _TrackedStartupCard({required this.startup, required this.onTap});

  Color _progressColor(int percent) {
    if (percent >= 75) return AppColors.success;
    if (percent >= 40) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _progressColor(startup.progressPercent);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                startup.name.isNotEmpty ? startup.name[0] : '?',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startup.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    startup.fundingGoalLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: startup.progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${startup.progressPercent}%',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}



// ---------------------------------------------------------------------------
// Domain models — field-for-field matches of your originals
// ---------------------------------------------------------------------------

enum DeltaTone { positive, neutral, warning }

class InvestorMetric {
  final String label;
  final String value;
  final String deltaText;
  final DeltaTone tone;
  final IconData icon;

  const InvestorMetric({
    required this.label,
    required this.value,
    required this.deltaText,
    required this.tone,
    required this.icon,
  });
}

class StartupRecommendation {
  final String id;
  final String name;
  final String tagline;
  final List<String> tags;
  final int matchScore;

  const StartupRecommendation({
    required this.id,
    required this.name,
    required this.tagline,
    required this.tags,
    required this.matchScore,
  });
}

enum ActivityKind { document, meeting, milestone }

class ActivityItem {
  final String actorName;
  final String action;
  final String timeAgo;
  final ActivityKind kind;

  const ActivityItem({
    required this.actorName,
    required this.action,
    required this.timeAgo,
    required this.kind,
  });
}

class TrackedStartup {
  final String id;
  final String name;
  final String fundingGoalLabel;
  final int progressPercent;

  const TrackedStartup({
    required this.id,
    required this.name,
    required this.fundingGoalLabel,
    required this.progressPercent,
  });
}


