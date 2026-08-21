import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/staggered_fade_slide.dart';
import 'package:ethioventure/features/investor/presentation/widgets/app_bottom_nav.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';
import 'package:ethioventure/features/matching/domain/entities/match_result_entity.dart';
import 'package:ethioventure/features/matching/presentation/cubit/recommendations_cubit.dart';
import 'package:ethioventure/features/matching/presentation/cubit/recommendations_state.dart';
import 'package:ethioventure/features/connection_requests/presentation/cubit/connection_request_cubit.dart';
import 'package:ethioventure/features/connection_requests/presentation/cubit/connection_request_state.dart';
import 'package:ethioventure/features/connection_requests/domain/entities/connection_request_entity.dart';
import 'package:ethioventure/features/tracked_startups/presentation/cubit/tracked_startups_cubit.dart';
import 'package:ethioventure/features/tracked_startups/presentation/cubit/tracked_startups_state.dart';
import 'package:ethioventure/features/tracked_startups/domain/entities/tracked_startup_entity.dart';

/// ============================================================================
/// INVESTOR DASHBOARD — PREMIUM REDESIGN
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
        BlocProvider<RecommendationsCubit>(
          create: (_) => sl<RecommendationsCubit>()..loadRecommendations(),
        ),
        BlocProvider<ConnectionRequestCubit>(
          create: (_) => sl<ConnectionRequestCubit>()..loadInvestorRequests(),
        ),
        BlocProvider<TrackedStartupsCubit>(
          create: (_) => sl<TrackedStartupsCubit>()..loadTrackedStartups(),
        ),
      ],
      child: BlocListener<InvestorProfileCubit, InvestorProfileState>(
        listener: (context, profileState) {
          if (profileState is InvestorProfileLoaded) {
            context.read<RecommendationsCubit>().loadRecommendations();
          }
        },
        child: _DashboardScaffold(userName: _userName, activity: _activity),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scaffold widget
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold({required this.userName, required this.activity});

  final String userName;
  final List<ActivityItem> activity;

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
            Navigator.of(
              context,
            ).pushReplacementNamed(AppConstants.routeStartupSearch);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppConstants.routeMessages);
          } else if (index == 3) {
            Navigator.of(
              context,
            ).pushReplacementNamed(AppConstants.routeInvestorProfile);
          }
        },
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<InvestorProfileCubit>().loadProfile();
            context.read<RecommendationsCubit>().loadRecommendations();
            context.read<ConnectionRequestCubit>().loadInvestorRequests();
            await context.read<TrackedStartupsCubit>().loadTrackedStartups();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 28),
            children: [
              // ── Portfolio Pulse Strip (stagger 0) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 0,
                  totalItems: 7,
                  child: _PortfolioPulseStrip(
                    activeDeals: '12',
                    userName: userName,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Metrics (stagger 1) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 1,
                  totalItems: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeading(title: 'Your Overview'),
                      const SizedBox(height: 12),
                      BlocBuilder<TrackedStartupsCubit, TrackedStartupsState>(
                        builder: (context, trackedState) {
                          return BlocBuilder<
                            ConnectionRequestCubit,
                            ConnectionRequestState
                          >(
                            builder: (context, connectionState) {
                              final trackedCount =
                                  trackedState is TrackedStartupsLoaded
                                  ? trackedState.startups.length
                                  : 0;

                              final requests =
                                  connectionState is ConnectionRequestLoaded
                                  ? connectionState.requests
                                  : <ConnectionRequestEntity>[];
                              final activeDealsCount = requests
                                  .where((r) => r.isAccepted)
                                  .length;
                              final pendingCount = requests
                                  .where((r) => r.isPending)
                                  .length;

                              final dynamicMetrics = [
                                InvestorMetric(
                                  label: 'Active Deals',
                                  value: activeDealsCount.toString(),
                                  deltaText: pendingCount > 0
                                      ? '+$pendingCount pending'
                                      : (activeDealsCount > 0
                                            ? 'Active portfolio'
                                            : 'No active deals'),
                                  tone: activeDealsCount > 0
                                      ? DeltaTone.positive
                                      : DeltaTone.neutral,
                                  icon: Icons.sell_outlined,
                                ),
                                InvestorMetric(
                                  label: 'Startups Tracked',
                                  value: trackedCount.toString(),
                                  deltaText: trackedCount > 0
                                      ? '$trackedCount in watchlist'
                                      : 'No startups tracked',
                                  tone: trackedCount > 0
                                      ? DeltaTone.positive
                                      : DeltaTone.neutral,
                                  icon: Icons.visibility_outlined,
                                ),
                                InvestorMetric(
                                  label: 'Connections',
                                  value: requests.length.toString(),
                                  deltaText:
                                      '${requests.length} total requests',
                                  tone: DeltaTone.neutral,
                                  icon: Icons.connect_without_contact_rounded,
                                ),
                              ];

                              return _MetricsRow(metrics: dynamicMetrics);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Quick Actions (stagger 2) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 2,
                  totalItems: 7,
                  child: _QuickActionsGrid(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Connection Requests Card (stagger 3) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 3,
                  totalItems: 7,
                  child:
                      BlocBuilder<
                        ConnectionRequestCubit,
                        ConnectionRequestState
                      >(
                        builder: (context, state) {
                          final requests = state is ConnectionRequestLoaded
                              ? state.requests
                              : <ConnectionRequestEntity>[];
                          final pendingCount = requests
                              .where((r) => r.isPending)
                              .length;
                          final acceptedCount = requests
                              .where((r) => r.isAccepted)
                              .length;

                          return GestureDetector(
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppConstants.routeInvestorRequests),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0A2540),
                                    Color(0xFF21496E),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(
                                          Icons.connect_without_contact_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        if (pendingCount > 0)
                                          Positioned(
                                            top: -6,
                                            right: -6,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFF5252),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$pendingCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Connection Requests',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _RequestStatChip(
                                              label: '$pendingCount Pending',
                                              color: const Color(0xFFFFD54F),
                                            ),
                                            const SizedBox(width: 8),
                                            _RequestStatChip(
                                              label: '$acceptedCount Accepted',
                                              color: const Color(0xFF69F0AE),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white54,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Investment Insight Card (stagger 4) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 4,
                  totalItems: 7,
                  child: const _InvestmentInsightCard(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Dynamic recommendations (stagger 5) ──
              StaggeredFadeSlide(
                index: 5,
                totalItems: 7,
                child: BlocBuilder<RecommendationsCubit, RecommendationsState>(
                  builder: (context, state) {
                    return _RecommendedStartupsSection(
                      state: state,
                      onViewAll: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppConstants.routeRecommendations);
                      },
                      onViewProfile: (match) async {
                        await Navigator.of(context).pushNamed(
                          AppConstants.routeStartupDetail,
                          arguments: match,
                        );
                        if (context.mounted) {
                          context
                              .read<TrackedStartupsCubit>()
                              .loadTrackedStartups();
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Activity & Tracked (stagger 6) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredFadeSlide(
                  index: 6,
                  totalItems: 7,
                  child: Column(
                    children: [
                      BlocBuilder<TrackedStartupsCubit, TrackedStartupsState>(
                        builder: (context, state) {
                          return _TrackedStartupsSection(
                            state: state,
                            onManage: () async {
                              await Navigator.of(
                                context,
                              ).pushNamed(AppConstants.routeStartupSearch);
                              if (context.mounted) {
                                context
                                    .read<TrackedStartupsCubit>()
                                    .loadTrackedStartups();
                              }
                            },
                            onTapStartup: (startup) async {
                              await Navigator.of(context).pushNamed(
                                AppConstants.routeStartupDetail,
                                arguments: startup.startup,
                              );
                              if (context.mounted) {
                                context
                                    .read<TrackedStartupsCubit>()
                                    .loadTrackedStartups();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

// ---------------------------------------------------------------------------
// Time-aware greeting helper
// ---------------------------------------------------------------------------
String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).pushNamed(AppConstants.routeRecommendations);
        },
        child: Container(
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
                      '${_timeGreeting()}, $userName 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<RecommendationsCubit, RecommendationsState>(
                      builder: (context, state) {
                        final text = switch (state) {
                          RecommendationsLoading() ||
                          RecommendationsInitial() =>
                            'Finding startups matching your thesis...',
                          RecommendationsLoaded(:final results) ||
                          RecommendationsOpeningConversation(
                            :final results,
                          ) => _formatMatchCount(results),
                          RecommendationsNotInvestor() =>
                            'Set up your investor thesis to see matches',
                          RecommendationsError() =>
                            'Startups matching your investment thesis',
                          RecommendationsUnauthenticated() =>
                            'Sign in to see startup matches',
                        };

                        return Row(
                          children: [
                            Flexible(
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
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
        ),
      ),
    );
  }

  String _formatMatchCount(List<MatchResultEntity> results) {
    final matchingCount = results.where((r) => r.overallScore > 0).length;
    if (matchingCount == 0) {
      return 'No startups match your thesis yet';
    } else if (matchingCount == 1) {
      return '1 startup matches your thesis';
    } else {
      return '$matchingCount startups match your thesis';
    }
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
// Metrics row — 3 scrollable cards with animated counters
// ---------------------------------------------------------------------------
class _MetricsRow extends StatelessWidget {
  final List<InvestorMetric> metrics;
  const _MetricsRow({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return SizedBox(width: 155, child: _MetricCard(metric: metrics[i]));
        },
      ),
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
  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final tone = _toneColors(metric.tone);

    final numericValue = int.tryParse(
      metric.value.replaceAll(RegExp(r'[^0-9]'), ''),
    );

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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconBadge,
          const SizedBox(height: 10),
          if (numericValue != null)
            AnimatedCounter(end: numericValue, style: _valueStyle)
          else
            Text(metric.value, style: _valueStyle),
          const SizedBox(height: 2),
          Text(metric.label, style: _labelStyle),
          const Spacer(),
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

// ---------------------------------------------------------------------------
// Quick Actions — 2×2 grid of shortcut tiles
// ---------------------------------------------------------------------------
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Quick Actions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.search_rounded,
                label: 'Browse\nStartups',
                gradient: const [Color(0xFF0A2540), Color(0xFF21496E)],
                onTap: () async {
                  await Navigator.of(
                    context,
                  ).pushNamed(AppConstants.routeStartupSearch);
                  if (context.mounted) {
                    context.read<TrackedStartupsCubit>().loadTrackedStartups();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.connect_without_contact_rounded,
                label: 'View\nRequests',
                gradient: const [Color(0xFF009BC2), Color(0xFF00D1FF)],
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppConstants.routeInvestorRequests),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                gradient: const [Color(0xFF11845B), Color(0xFF1DB67E)],
                onTap: () =>
                    Navigator.of(context).pushNamed(AppConstants.routeMessages),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.person_outline_rounded,
                label: 'My\nProfile',
                gradient: const [Color(0xFF7F77DD), Color(0xFFA49AFF)],
                onTap: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppConstants.routeInvestorProfile),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Investment Insight card — rotating tips for investors
// ---------------------------------------------------------------------------
class _InvestmentInsightCard extends StatelessWidget {
  const _InvestmentInsightCard();

  static const _insights = [
    (
      icon: Icons.insights_rounded,
      title: 'Investment insight',
      body:
          '73% of successful seed deals close within 90 days of the first investor meeting. Move quickly on strong matches!',
    ),
    (
      icon: Icons.psychology_outlined,
      title: 'Due diligence tip',
      body:
          'Top-performing investors review at least 100 startups before making a single investment. Thoroughness pays off.',
    ),
    (
      icon: Icons.analytics_outlined,
      title: 'Portfolio strategy',
      body:
          'Diversifying across 3+ industries reduces portfolio risk by 45% while maintaining strong return potential.',
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Market insight',
      body:
          'Ethiopian tech startups grew 62% year-over-year. Early-stage investing in emerging markets yields outsized returns.',
    ),
    (
      icon: Icons.handshake_outlined,
      title: 'Networking matters',
      body:
          'Investors who actively message founders are 5× more likely to close a deal than passive reviewers.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().difference(DateTime(2025)).inDays;
    final insight = _insights[dayIndex % _insights.length];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEEEDFE), Color(0xFFDAD8FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(insight.icon, color: AppColors.violet, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.violetTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DAILY INSIGHT',
                        style: TextStyle(
                          color: AppColors.violet,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  insight.body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
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

// ─────────────────────────────────────────────────────────────────────────────
// Recommended startups section — state-aware wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _RecommendedStartupsSection extends StatelessWidget {
  const _RecommendedStartupsSection({
    required this.state,
    required this.onViewAll,
    required this.onViewProfile,
  });

  final RecommendationsState state;
  final VoidCallback onViewAll;
  final ValueChanged<MatchResultEntity> onViewProfile;

  @override
  Widget build(BuildContext context) {
    final hasResults = switch (state) {
      RecommendationsLoaded(:final results) => results.isNotEmpty,
      RecommendationsOpeningConversation(:final results) => results.isNotEmpty,
      _ => false,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeading(
            title: 'Recommended For You',
            onAction: hasResults ? onViewAll : null,
          ),
        ),
        const SizedBox(height: 12),
        switch (state) {
          RecommendationsLoading() ||
          RecommendationsInitial() => const _RecommendedShimmer(),
          RecommendationsLoaded(:final results) when results.isEmpty =>
            const _RecommendedEmpty(),
          RecommendationsLoaded(:final results) => _RecommendedRail(
            startups: results,
            onViewProfile: onViewProfile,
          ),
          RecommendationsOpeningConversation(:final results) =>
            _RecommendedRail(startups: results, onViewProfile: onViewProfile),
          RecommendationsError(:final message) => _RecommendedError(
            message: message,
          ),
          RecommendationsNotInvestor() => const SizedBox.shrink(),
          RecommendationsUnauthenticated() => const SizedBox.shrink(),
        },
      ],
    );
  }
}

/// Horizontal scrolling rail of real startup cards from matching.
class _RecommendedRail extends StatelessWidget {
  const _RecommendedRail({required this.startups, required this.onViewProfile});

  final List<MatchResultEntity> startups;
  final ValueChanged<MatchResultEntity> onViewProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: startups.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final match = startups[i];
          return _StartupCard(match: match, onTap: () => onViewProfile(match));
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
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 250,
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
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 18,
            ),
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
  final MatchResultEntity match;
  final VoidCallback onTap;
  const _StartupCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final startup = match.startup;
    final description =
        (startup.description != null && startup.description!.trim().isNotEmpty)
        ? startup.description!.trim()
        : 'High-potential venture matching your investment criteria.';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 250,
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
                    startup.businessName,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${match.overallScore}% match',
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
                description,
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
              children:
                  [
                        if (startup.industry != null &&
                            startup.industry!.isNotEmpty)
                          startup.industry!,
                        if (startup.fundingStage != null &&
                            startup.fundingStage!.isNotEmpty)
                          startup.fundingStage!,
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
// Tracked startups — funding progress instead of a delta chip
// ---------------------------------------------------------------------------
class _TrackedStartupsSection extends StatelessWidget {
  final TrackedStartupsState state;
  final VoidCallback onManage;
  final ValueChanged<TrackedStartupEntity> onTapStartup;
  const _TrackedStartupsSection({
    required this.state,
    required this.onManage,
    required this.onTapStartup,
  });

  @override
  Widget build(BuildContext context) {
    if (state is TrackedStartupsLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Tracked Startups',
            onAction: onManage,
            actionLabel: 'Manage',
          ),
          const SizedBox(height: 12),
          Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

    final startups = state is TrackedStartupsLoaded
        ? (state as TrackedStartupsLoaded).startups
        : <TrackedStartupEntity>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Tracked Startups',
          onAction: onManage,
          actionLabel: 'Manage',
        ),
        const SizedBox(height: 12),
        if (startups.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No Startups Tracked Yet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track innovative startups to keep an eye on their funding progress and milestones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onManage,
                  icon: const Icon(Icons.explore_outlined, size: 16),
                  label: const Text('Discover Startups'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
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
  final TrackedStartupEntity startup;
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
                startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?',
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

// ── Helper: small colored chip for request stats ──────────────────────────────

class _RequestStatChip extends StatelessWidget {
  const _RequestStatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
