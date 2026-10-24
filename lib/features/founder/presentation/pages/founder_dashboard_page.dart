import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/staggered_fade_slide.dart';
import '../../../pitch_deck/presentation/cubit/document_cubit.dart';
import '../../../pitch_deck/presentation/cubit/document_state.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_cubit.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_state.dart';
import '../cubit/recommended_investors_cubit.dart';
import '../cubit/founder_metrics_cubit.dart';
import '../cubit/founder_metrics_state.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/recommended_investor_section.dart';

/// ============================================================================
/// FOUNDER HOME / DASHBOARD — ULTRA-MODERN PREMIUM REDESIGN
/// ============================================================================
class FounderDashboardPage extends StatefulWidget {
  const FounderDashboardPage({super.key});

  @override
  State<FounderDashboardPage> createState() => _FounderDashboardPageState();
}

class _FounderDashboardPageState extends State<FounderDashboardPage> {
  String _userName = 'Founder';
  String _userEmail = '';
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
          _userEmail = user.email;
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

  static ProfileStrength _calculateProfileStrength(
    StartupProfileEntity? profile,
    bool isProfileEmpty, {
    bool hasDocuments = false,
  }) {
    if (isProfileEmpty || profile == null) {
      return const ProfileStrength(
        percent: 0,
        subtitle:
            'Set up your startup profile & upload pitch deck to attract verified investors.',
        checklist: [
          ProfileChecklistItem(
            label: 'Basic Startup Info & Vision',
            isComplete: false,
            description: 'Name, logo, mission, and overview',
          ),
          ProfileChecklistItem(
            label: 'Industry Sector & Stage',
            isComplete: false,
            description: 'Target market, industry & funding stage',
          ),
          ProfileChecklistItem(
            label: 'Team & Founders Overview',
            isComplete: false,
            description: 'Core team members and roles',
          ),
          ProfileChecklistItem(
            label: 'Funding Target & Contact Info',
            isComplete: false,
            description: 'Target raise amount and business contact',
          ),
          ProfileChecklistItem(
            label: 'Pitch Deck & Business Documents',
            isComplete: false,
            description: 'PDF pitch deck or executive summary',
          ),
        ],
      );
    }

    final bool hasBasic =
        profile.startupName.trim().isNotEmpty &&
        profile.description.trim().isNotEmpty;

    final bool hasIndustryStage =
        profile.industry.trim().isNotEmpty &&
        profile.fundingStage.trim().isNotEmpty;

    final bool hasTeam = profile.teamInformation.trim().isNotEmpty;

    final bool hasFundingContact =
        profile.contactInformation.trim().isNotEmpty ||
        profile.fundingAmountNeeded > 0;

    int completedCount = 0;
    if (hasBasic) completedCount++;
    if (hasIndustryStage) completedCount++;
    if (hasTeam) completedCount++;
    if (hasFundingContact) completedCount++;
    if (hasDocuments) completedCount++;

    final int percent = (completedCount / 5 * 100).round();
    final String subtitle = percent == 100
        ? 'Your startup profile is 100% investor ready! Visible to active VCs & Angels.'
        : 'Your profile is $percent% complete — complete setup to boost investor visibility.';

    return ProfileStrength(
      percent: percent,
      subtitle: subtitle,
      checklist: [
        ProfileChecklistItem(
          label: 'Basic Startup Info & Vision',
          isComplete: hasBasic,
          description: 'Name, logo, mission, and overview',
        ),
        ProfileChecklistItem(
          label: 'Industry Sector & Stage',
          isComplete: hasIndustryStage,
          description: 'Target market, industry & funding stage',
        ),
        ProfileChecklistItem(
          label: 'Team & Founders Overview',
          isComplete: hasTeam,
          description: 'Core team members and roles',
        ),
        ProfileChecklistItem(
          label: 'Funding Target & Contact Info',
          isComplete: hasFundingContact,
          description: 'Target raise amount and business contact',
        ),
        ProfileChecklistItem(
          label: 'Pitch Deck & Business Documents',
          isComplete: hasDocuments,
          description: 'PDF pitch deck or executive summary',
        ),
      ],
    );
  }

  static const _defaultMetrics = [
    DashboardMetric(
      label: 'Investor Requests',
      value: '0',
      deltaText: '0 requests sent',
      iconAsset: 'interest',
      isPositive: false,
    ),
    DashboardMetric(
      label: 'Conversations',
      value: '0',
      deltaText: 'No active chats',
      iconAsset: 'conversations',
      isPositive: false,
    ),
    DashboardMetric(
      label: 'Pitch Deck & Docs',
      value: '0',
      deltaText: 'No docs uploaded',
      iconAsset: 'views',
      isPositive: false,
    ),
    DashboardMetric(
      label: 'Investor Matches',
      value: '0',
      deltaText: 'Discover VCs',
      iconAsset: 'matches',
      isPositive: true,
    ),
  ];

  static const _defaultMetricIcons = [
    Icons.send_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.description_outlined,
    Icons.people_alt_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryDark),
          ),
        ),
      );
    }

    final currentUserId = sl<SupabaseClient>().auth.currentUser?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<StartupProfileCubit>(
          create: (_) => sl<StartupProfileCubit>()..loadProfile(currentUserId),
        ),
        BlocProvider<RecommendedInvestorsCubit>(
          create: (_) => sl<RecommendedInvestorsCubit>()..load(),
        ),
        BlocProvider<DocumentCubit>(create: (_) => sl<DocumentCubit>()),
        BlocProvider<FounderMetricsCubit>(
          create: (_) => sl<FounderMetricsCubit>()
            ..loadMetrics(userId: currentUserId),
        ),
      ],
      child: BlocListener<StartupProfileCubit, StartupProfileState>(
        listener: (context, startupState) {
          if (startupState is StartupProfileLoaded) {
            context.read<RecommendedInvestorsCubit>().load(
              startupState.profile,
            );
            context.read<DocumentCubit>().loadDocuments(
              startupId: startupState.profile.id,
            );
            context.read<FounderMetricsCubit>().loadMetrics(
              userId: currentUserId,
              startupProfileId: startupState.profile.id,
              industry: startupState.profile.industry,
            );
          } else if (startupState is StartupProfileEmpty ||
              startupState is StartupProfileError) {
            context.read<RecommendedInvestorsCubit>().load();
            context.read<FounderMetricsCubit>().loadMetrics(
              userId: currentUserId,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: DashboardBottomNav(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppConstants.routeFounderInvestors);
              } else if (index == 2) {
                Navigator.of(context).pushNamed(AppConstants.routeMessages);
              } else if (index == 3) {
                Navigator.of(
                  context,
                ).pushReplacementNamed(AppConstants.routeStartupProfile);
              }
            },
          ),
          body: Builder(
            builder: (context) {
              return RefreshIndicator(
                color: AppColors.primaryDark,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  final startupState = context.read<StartupProfileCubit>().state;
                  final startupId = startupState is StartupProfileLoaded
                      ? startupState.profile.id
                      : null;
                  final industry = startupState is StartupProfileLoaded
                      ? startupState.profile.industry
                      : null;

                  await Future.wait([
                    context.read<StartupProfileCubit>().loadProfile(currentUserId),
                    context.read<RecommendedInvestorsCubit>().load(
                      startupState is StartupProfileLoaded
                          ? startupState.profile
                          : null,
                    ),
                    context.read<FounderMetricsCubit>().loadMetrics(
                      userId: currentUserId,
                      startupProfileId: startupId,
                      industry: industry,
                    ),
                    if (startupId != null)
                      context
                          .read<DocumentCubit>()
                          .loadDocuments(startupId: startupId),
                  ]);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // ── Modern Floating Top App Bar ──
                    _TopBar(
                      userName: _userName,
                      userEmail: _userEmail,
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Quick Investor Search Shortcut Bar ──
                            StaggeredFadeSlide(
                              index: 0,
                              totalItems: 7,
                              child: _QuickSearchBar(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppConstants.routeFounderInvestors,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ── AI Startup Co-Pilot Banner ──
                            const StaggeredFadeSlide(
                              index: 1,
                              totalItems: 7,
                              child: _FounderAiCoPilotBanner(),
                            ),

                            const SizedBox(height: 18),

                            // ── Executive Venture Hero Card (stagger index 1) ──
                            StaggeredFadeSlide(
                              index: 1,
                              totalItems: 6,
                              child: BlocBuilder<StartupProfileCubit, StartupProfileState>(
                                builder: (context, profileState) {
                                  final profile = profileState is StartupProfileLoaded
                                      ? profileState.profile
                                      : null;
                                  final isProfileEmpty =
                                      profileState is StartupProfileEmpty;
                                  final isProfileLoading =
                                      profileState is StartupProfileLoading;

                                  return BlocBuilder<DocumentCubit, DocumentState>(
                                    builder: (context, docState) {
                                      final hasDocuments =
                                          docState is DocumentsLoaded &&
                                          docState.documents.isNotEmpty;
                                      final isDocLoading =
                                          docState is DocumentLoading;

                                      final strength = _calculateProfileStrength(
                                        profile,
                                        isProfileEmpty,
                                        hasDocuments: hasDocuments,
                                      );

                                      return _ExecutiveVentureCard(
                                        userName: _userName,
                                        profile: profile,
                                        strength: strength,
                                        hasDocuments: hasDocuments,
                                        isLoading:
                                            isProfileLoading || isDocLoading,
                                        onSetupProfile: () {
                                          if (profile != null) {
                                            Navigator.of(context)
                                                .pushNamed(
                                                  AppConstants
                                                      .routeStartupProfile,
                                                )
                                                .then((_) {
                                                  if (context.mounted) {
                                                    context
                                                        .read<StartupProfileCubit>()
                                                        .loadProfile(
                                                          currentUserId,
                                                        );
                                                    context
                                                        .read<DocumentCubit>()
                                                        .loadDocuments(
                                                          startupId: profile.id,
                                                        );
                                                  }
                                                });
                                          } else {
                                            Navigator.of(context)
                                                .pushNamed(
                                                  AppConstants
                                                      .routeStartupProfileSetup,
                                                )
                                                .then((_) {
                                                  if (context.mounted) {
                                                    context
                                                        .read<StartupProfileCubit>()
                                                        .loadProfile(
                                                          currentUserId,
                                                        );
                                                  }
                                                });
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Momentum & Live Metrics (stagger index 2) ──
                            StaggeredFadeSlide(
                              index: 2,
                              totalItems: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const _SectionHeading(
                                        title: 'Venture Momentum',
                                        badge: 'LIVE',
                                      ),
                                      Text(
                                        'Tap card to view details',
                                        style: TextStyle(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.8),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<FounderMetricsCubit, FounderMetricsState>(
                                    builder: (context, metricsState) {
                                      if (metricsState is FounderMetricsLoaded) {
                                        return _MetricsRow(
                                          metrics: metricsState.metrics,
                                          icons: metricsState.icons,
                                        );
                                      }
                                      if (metricsState is FounderMetricsLoading) {
                                        return const SizedBox(
                                          height: 168,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                AppColors.primaryDark,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return const _MetricsRow(
                                        metrics: _defaultMetrics,
                                        icons: _defaultMetricIcons,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Quick Actions Grid (stagger index 3) ──
                            StaggeredFadeSlide(
                              index: 3,
                              totalItems: 6,
                              child: const _QuickActionsGrid(),
                            ),

                            const SizedBox(height: 24),

                            // ── Daily Founder Wisdom (stagger index 4) ──
                            StaggeredFadeSlide(
                              index: 4,
                              totalItems: 6,
                              child: const _TipOfTheDayCard(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Recommended Investors Rail (stagger index 5) ──
                    SliverToBoxAdapter(
                      child: StaggeredFadeSlide(
                        index: 5,
                        totalItems: 6,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: RecommendedInvestorsSection(),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modern Top bar — greeting + role badge + notification & profile sheet
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _TopBar({
    required this.userName,
    required this.userEmail,
  });

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) => _AccountBottomSheet(
        userName: userName,
        userEmail: userEmail,
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) => const _NotificationsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      titleSpacing: 20,
      toolbarHeight: 68,
      title: Row(
        children: [
          // Avatar Bubble with status ring
          _AvatarWithStatus(
            initials: userName.isNotEmpty ? userName[0] : 'F',
            onTap: () => _showAccountSheet(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$greeting, $userName',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('👋', style: TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Flexible(
                      child: Text(
                        'Founder Hub • Active Deal Room',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _IconButtonSurfaced(
          icon: Icons.auto_awesome_rounded,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppConstants.routeStartupAiAdvisor,
              arguments: {'role': AppConstants.roleFounder},
            );
          },
        ),
        const SizedBox(width: 8),
        _LiveNotificationButton(
          onTap: () => _showNotificationsSheet(context),
        ),
        const SizedBox(width: 8),
        _IconButtonSurfaced(
          icon: Icons.person_outline_rounded,
          onTap: () => _showAccountSheet(context),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Search Bar Shortcut
// ---------------------------------------------------------------------------
class _QuickSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryDark,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search 40+ active investors, angels & VCs...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
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

// ---------------------------------------------------------------------------
// Founder AI Startup Co-Pilot Banner
// ---------------------------------------------------------------------------
class _FounderAiCoPilotBanner extends StatelessWidget {
  const _FounderAiCoPilotBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 12,
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
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'EthioVenture AI Co-Pilot',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Fundraising, Valuation & Growth Advisor',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primarySoft,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppConstants.routeStartupAiAdvisor,
                    arguments: {'role': AppConstants.roleFounder},
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ask AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ask tailored questions about your pitch deck, calculate pre-seed valuation, or evaluate unit economics for the Ethiopian market.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  context,
                  label: '🚀 Pitch & Deck Review',
                  prompt:
                      'How can I refine my 30-second elevator pitch and investor deck structure to captivate angel investors in Ethiopia?',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  context,
                  label: '💰 Pre-Seed Valuation',
                  prompt:
                      'How should I calculate our pre-money valuation and determine how much equity to give away for a pre-seed round in East Africa?',
                ),
                const SizedBox(width: 6),
                _buildChip(
                  context,
                  label: '📊 CAC & Runway',
                  prompt:
                      'Walk me through calculating CAC, LTV, payback period, and managing our 18-month burn rate.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required String prompt,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppConstants.routeStartupAiAdvisor,
          arguments: {
            'role': AppConstants.roleFounder,
            'initialPrompt': prompt,
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar with Glowing Status Ring
// ---------------------------------------------------------------------------
class _AvatarWithStatus extends StatelessWidget {
  final String initials;
  final VoidCallback onTap;

  const _AvatarWithStatus({
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2540), Color(0xFF1E4870)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2540).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live Notification Button with Real-time Count
// ---------------------------------------------------------------------------
class _LiveNotificationButton extends StatefulWidget {
  final VoidCallback onTap;

  const _LiveNotificationButton({required this.onTap});

  @override
  State<_LiveNotificationButton> createState() => _LiveNotificationButtonState();
}

class _LiveNotificationButtonState extends State<_LiveNotificationButton> {
  StreamSubscription<int>? _sub;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = NotificationService.instance.cachedUnreadCount;
    _sub = NotificationService.instance.unreadCountStream.listen((count) {
      if (mounted) setState(() => _unreadCount = count);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: widget.onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 21,
            ),
            if (_unreadCount > 0)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Center(
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 7,
                  height: 7,
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

class _IconButtonSurfaced extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButtonSurfaced({required this.icon, required this.onTap});

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
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 21),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Executive Venture Readiness Card (Replacing the bulky static hero)
// ---------------------------------------------------------------------------
class _ExecutiveVentureCard extends StatefulWidget {
  final String userName;
  final StartupProfileEntity? profile;
  final ProfileStrength strength;
  final bool hasDocuments;
  final bool isLoading;
  final VoidCallback onSetupProfile;

  const _ExecutiveVentureCard({
    required this.userName,
    required this.profile,
    required this.strength,
    required this.hasDocuments,
    required this.isLoading,
    required this.onSetupProfile,
  });

  @override
  State<_ExecutiveVentureCard> createState() => _ExecutiveVentureCardState();
}

class _ExecutiveVentureCardState extends State<_ExecutiveVentureCard> {
  bool _isChecklistExpanded = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final strength = widget.strength;
    final isComplete = strength.isComplete;

    final startupName = profile?.startupName.isNotEmpty == true
        ? profile!.startupName
        : "${widget.userName}'s Startup";

    final industryText = profile?.industry.isNotEmpty == true
        ? profile!.industry
        : 'Tech & Innovation';

    final stageText = profile?.fundingStage.isNotEmpty == true
        ? profile!.fundingStage
        : 'Pre-Seed';

    final targetFunding = profile != null && profile.fundingAmountNeeded > 0
        ? '\$${_formatCurrency(profile.fundingAmountNeeded)}'
        : 'Set Target';

    // Find the immediate next incomplete step
    final nextStep = strength.checklist.firstWhere(
      (item) => !item.isComplete,
      orElse: () => const ProfileChecklistItem(
        label: 'Profile fully optimized',
        isComplete: true,
        description: 'Ready to pitch to investors',
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF07192F),
            Color(0xFF0F3255),
            Color(0xFF0B2541),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07192F).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Decorative background glowing blur orbs
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet.withValues(alpha: 0.12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Company Badge + Stage + Circular Gauge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startupName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$stageText • $industryText',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Progress Ring or Verified Badge
                      _CircularReadinessGauge(
                        percent: strength.percent,
                        isLoading: widget.isLoading,
                        isComplete: isComplete,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Middle: Dynamic Headline & Pitch
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? AppColors.success.withValues(alpha: 0.25)
                              : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isComplete
                                  ? Icons.verified_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 13,
                              color: isComplete
                                  ? const Color(0xFF69F0AE)
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isComplete
                                  ? 'DEAL ROOM READY'
                                  : 'FUNDRAISING READINESS',
                              style: TextStyle(
                                color: isComplete
                                    ? const Color(0xFF69F0AE)
                                    : AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strength.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  // Next Action Priority Banner (if not complete)
                  if (!isComplete) ...[
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: widget.onSetupProfile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recommended Next Step',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    nextStep.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Collapsible Checklist Accordion
                  if (!isComplete) ...[
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isChecklistExpanded = !_isChecklistExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              _isChecklistExpanded
                                  ? 'Hide 5-step checklist'
                                  : 'View 5-step checklist (${strength.percent}% done)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isChecklistExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isChecklistExpanded) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: strength.checklist.map((item) {
                            return _CompactChecklistTile(
                              item: item,
                              onTap: widget.onSetupProfile,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 14),

                  // Bottom Metrics & Fast Action Row
                  Row(
                    children: [
                      _HeroMiniStat(
                        label: 'Pitch Deck',
                        value: widget.hasDocuments ? 'Uploaded' : 'Pending',
                        icon: Icons.description_outlined,
                        isHighlight: widget.hasDocuments,
                      ),
                      const SizedBox(width: 14),
                      _HeroMiniStat(
                        label: 'Target Raise',
                        value: targetFunding,
                        icon: Icons.monetization_on_outlined,
                        isHighlight: profile != null &&
                            profile.fundingAmountNeeded > 0,
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: widget.onSetupProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF07192F),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isComplete ? 'View Profile' : 'Update Deck',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _CircularReadinessGauge extends StatelessWidget {
  final int percent;
  final bool isLoading;
  final bool isComplete;

  const _CircularReadinessGauge({
    required this.percent,
    required this.isLoading,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: isLoading ? null : percent / 100,
              strokeWidth: 4.5,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                isComplete ? const Color(0xFF69F0AE) : AppColors.primary,
              ),
            ),
          ),
          if (!isLoading)
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _CompactChecklistTile extends StatelessWidget {
  final ProfileChecklistItem item;
  final VoidCallback onTap;

  const _CompactChecklistTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(
              item.isComplete
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.isComplete
                  ? const Color(0xFF69F0AE)
                  : Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: Colors.white
                      .withValues(alpha: item.isComplete ? 0.6 : 0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration:
                      item.isComplete ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white38,
                ),
              ),
            ),
            if (!item.isComplete)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 10,
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _HeroMiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isHighlight
                  ? const Color(0xFF69F0AE)
                  : Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section heading with optional live badge
// ---------------------------------------------------------------------------
class _SectionHeading extends StatelessWidget {
  final String title;
  final String? badge;

  const _SectionHeading({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics Row — 4 dynamic cards with interactive navigation shortcuts
// ---------------------------------------------------------------------------
class _MetricsRow extends StatelessWidget {
  final List<DashboardMetric> metrics;
  final List<IconData> icons;

  const _MetricsRow({required this.metrics, required this.icons});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: metrics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final metric = metrics[i];
          final icon = icons.length > i ? icons[i] : Icons.analytics_outlined;

          // Determine card click action
          VoidCallback? onTap;
          if (metric.label.toLowerCase().contains('request')) {
            onTap = () => Navigator.of(context).pushNamed(
                  AppConstants.routeFounderRequests,
                );
          } else if (metric.label.toLowerCase().contains('conversation')) {
            onTap = () => Navigator.of(context).pushNamed(
                  AppConstants.routeMessages,
                );
          } else if (metric.label.toLowerCase().contains('deck') ||
              metric.label.toLowerCase().contains('doc')) {
            onTap = () => Navigator.of(context).pushNamed(
                  AppConstants.routeStartupProfile,
                );
          } else if (metric.label.toLowerCase().contains('match')) {
            onTap = () => Navigator.of(context).pushNamed(
                  AppConstants.routeFounderInvestors,
                );
          }

          return SizedBox(
            width: 156,
            child: _InteractiveMetricCard(
              metric: metric,
              icon: icon,
              index: i,
              onTap: onTap,
            ),
          );
        },
      ),
    );
  }
}

class _InteractiveMetricCard extends StatelessWidget {
  final DashboardMetric metric;
  final IconData icon;
  final int index;
  final VoidCallback? onTap;

  const _InteractiveMetricCard({
    required this.metric,
    required this.icon,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numericValue = int.tryParse(
      metric.value.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    // Complementary palettes for the 4 metrics
    final gradientColors = switch (index % 4) {
      0 => [const Color(0xFF009BC2), const Color(0xFF00D1FF)], // Cyan
      1 => [const Color(0xFF0D6E4B), const Color(0xFF16A06B)], // Emerald
      2 => [const Color(0xFF635BCA), const Color(0xFF8B82F6)], // Indigo
      _ => [const Color(0xFFC75D00), const Color(0xFFFF9E3D)], // Amber
    };

    final isPositive = metric.isPositive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 18, color: Colors.white),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const Spacer(),
              if (numericValue != null)
                AnimatedCounter(
                  end: numericValue,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                )
              else
                Text(
                  metric.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                metric.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.successSoft
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  metric.deltaText,
                  style: TextStyle(
                    color: isPositive
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions — Modern 2x2 Grid with Rich Visual Details
// ---------------------------------------------------------------------------
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Ecosystem Shortcuts'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModernQuickActionTile(
                icon: Icons.auto_awesome_rounded,
                badge: 'AI SPOTLIGHT',
                title: 'Pitch Deck & AI',
                subtitle: 'Upload & analyze deck',
                gradient: const [Color(0xFF091E3A), Color(0xFF1E4870)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeStartupProfile,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernQuickActionTile(
                icon: Icons.groups_rounded,
                badge: 'RECOMMENDED',
                title: 'Find Investors',
                subtitle: 'Browse 40+ active VCs',
                gradient: const [Color(0xFF007A99), Color(0xFF00B4D8)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeFounderInvestors,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModernQuickActionTile(
                icon: Icons.send_rounded,
                title: 'Sent Requests',
                subtitle: 'Track deal statuses',
                gradient: const [Color(0xFF0F6846), Color(0xFF19A870)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeFounderRequests,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModernQuickActionTile(
                icon: Icons.business_center_rounded,
                title: 'Startup Profile',
                subtitle: 'Edit team & traction',
                gradient: const [Color(0xFF5B52B6), Color(0xFF867CF0)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeStartupProfile,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernQuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String? badge;
  final VoidCallback onTap;

  const _ModernQuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 13,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tip of the Day — Modern Editorial Style
// ---------------------------------------------------------------------------
class _TipOfTheDayCard extends StatelessWidget {
  const _TipOfTheDayCard();

  static const _tips = [
    (
      icon: Icons.lightbulb_outline_rounded,
      tag: 'PITCH DECKS',
      title: 'Make Your First 3 Slides Irresistible',
      body:
          'Investors spend an average of 3 minutes reviewing a pitch deck. Hook them in the problem and traction slides immediately.',
    ),
    (
      icon: Icons.trending_up_rounded,
      tag: 'TRACTION',
      title: 'Profile Completeness Matters',
      body:
          'Startups with comprehensive profiles and uploaded pitch decks receive 4× more investor meeting requests.',
    ),
    (
      icon: Icons.handshake_outlined,
      tag: 'DEAL CLOSING',
      title: 'Maintain Follow-Up Momentum',
      body:
          '73% of seed deals close within 90 days of the first investor dialogue. Always send crisp meeting minutes within 24 hours.',
    ),
    (
      icon: Icons.groups_rounded,
      tag: 'TEAM & VISION',
      title: 'Highlight Your Unfair Advantage',
      body:
          'A transparent team overview with deep domain experience boosts investor conviction by over 60%.',
    ),
    (
      icon: Icons.rocket_launch_outlined,
      tag: 'VALUATION',
      title: 'Anchor on Market Potential',
      body:
          'African tech ecosystem valuations are driven by real revenue milestones, unit economics, and recurring customer retention.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().difference(DateTime(2025)).inDays;
    final tip = _tips[dayIndex % _tips.length];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7DB), Color(0xFFFFE89E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(tip.icon, color: AppColors.warning, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip.tag,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '• Venture Insight',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tip.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.body,
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

// ---------------------------------------------------------------------------
// Account Bottom Sheet Modal
// ---------------------------------------------------------------------------
class _AccountBottomSheet extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _AccountBottomSheet({
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0A2540), Color(0xFF1E4870)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified Founder',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Primary Account Email',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          userEmail.isNotEmpty ? userEmail : 'No email address',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeStartupProfile);
              },
              icon: const Icon(Icons.business_center_outlined, size: 18),
              label: const Text('Manage Startup Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF07192F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeFounderRequests);
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('View Sent Requests'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
// Notifications Bottom Sheet Modal
// ---------------------------------------------------------------------------
class _NotificationsBottomSheet extends StatelessWidget {
  const _NotificationsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deal Room Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActivityRow(
              icon: Icons.mark_email_read_outlined,
              color: AppColors.primaryDark,
              title: 'Connection Requests',
              subtitle: 'Check investor response statuses & pending requests',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeFounderRequests);
              },
            ),
            const SizedBox(height: 8),
            _ActivityRow(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.success,
              title: 'Direct Messages',
              subtitle: 'Join active chats with matched angel & VC investors',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeMessages);
              },
            ),
            const SizedBox(height: 8),
            _ActivityRow(
              icon: Icons.people_outline_rounded,
              color: AppColors.violet,
              title: 'New Matching Investors',
              subtitle: '3 new investors match your sector in Addis Ababa',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeFounderInvestors);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Domain models for Dashboard
// ---------------------------------------------------------------------------
class ProfileChecklistItem {
  final String label;
  final bool isComplete;
  final String description;

  const ProfileChecklistItem({
    required this.label,
    required this.isComplete,
    this.description = '',
  });
}

class ProfileStrength {
  final int percent;
  final String subtitle;
  final List<ProfileChecklistItem> checklist;

  const ProfileStrength({
    required this.percent,
    required this.subtitle,
    required this.checklist,
  });

  bool get isComplete => percent >= 100;
}

class DashboardMetric {
  final String label;
  final String value;
  final String deltaText;
  final String iconAsset;
  final bool isPositive;

  const DashboardMetric({
    required this.label,
    required this.value,
    required this.deltaText,
    required this.iconAsset,
    this.isPositive = true,
  });
}
