
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
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

class FounderDashboardPage extends StatefulWidget {
  const FounderDashboardPage({super.key});

  @override
  State<FounderDashboardPage> createState() => _FounderDashboardPageState();
}

class _FounderDashboardPageState extends State<FounderDashboardPage> {
  String _userName = 'User';
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
            'Setup your startup profile & upload pitch deck to attract investors.',
        checklist: [
          ProfileChecklistItem(
            label: 'Basic Startup Info & Vision',
            isComplete: false,
          ),
          ProfileChecklistItem(
            label: 'Industry Sector & Stage',
            isComplete: false,
          ),
          ProfileChecklistItem(
            label: 'Team & Founders Overview',
            isComplete: false,
          ),
          ProfileChecklistItem(
            label: 'Funding Target & Contact Info',
            isComplete: false,
          ),
          ProfileChecklistItem(
            label: 'Pitch Deck & Business Documents',
            isComplete: false,
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
        ? 'Your profile is 100% complete and visible to investors!'
        : 'Your profile is $percent% complete — finish setting it up to boost visibility.';

    return ProfileStrength(
      percent: percent,
      subtitle: subtitle,
      checklist: [
        ProfileChecklistItem(
          label: 'Basic Startup Info & Vision',
          isComplete: hasBasic,
        ),
        ProfileChecklistItem(
          label: 'Industry Sector & Stage',
          isComplete: hasIndustryStage,
        ),
        ProfileChecklistItem(
          label: 'Team & Founders Overview',
          isComplete: hasTeam,
        ),
        ProfileChecklistItem(
          label: 'Funding Target & Contact Info',
          isComplete: hasFundingContact,
        ),
        ProfileChecklistItem(
          label: 'Pitch Deck & Business Documents',
          isComplete: hasDocuments,
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
      deltaText: 'No documents uploaded',
      iconAsset: 'views',
      isPositive: false,
    ),
  ];

  static const _defaultMetricIcons = [
    Icons.handshake_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.description_outlined,
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
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                _TopBar(userName: _userName, userEmail: _userEmail),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Hero Card (stagger index 0) ──
                        StaggeredFadeSlide(
                          index: 0,
                          totalItems: 5,
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

                                  return _HeroWelcomeCard(
                                    userName: _userName,
                                    userEmail: _userEmail,
                                    strength: strength,
                                    isLoading: isProfileLoading || isDocLoading,
                                    onTap: () {
                                      if (profile != null) {
                                        Navigator.of(context)
                                            .pushNamed(
                                              AppConstants.routeStartupProfile,
                                            )
                                            .then((_) {
                                              if (context.mounted) {
                                                context
                                                    .read<StartupProfileCubit>()
                                                    .loadProfile(currentUserId);
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
                                                    .loadProfile(currentUserId);
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

                        // ── Metrics Section (stagger index 1) ──
                        StaggeredFadeSlide(
                          index: 1,
                          totalItems: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SectionHeading(title: 'Your Momentum'),
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
                                      height: 164,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return _MetricsRow(
                                    metrics: _defaultMetrics,
                                    icons: _defaultMetricIcons,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Quick Actions (stagger index 2) ──
                        StaggeredFadeSlide(
                          index: 2,
                          totalItems: 5,
                          child: const _QuickActionsGrid(),
                        ),

                        const SizedBox(height: 24),

                        // ── Tip of the Day (stagger index 3) ──
                        StaggeredFadeSlide(
                          index: 3,
                          totalItems: 5,
                          child: const _TipOfTheDayCard(),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Recommended Investors (stagger index 4) ──
                SliverToBoxAdapter(
                  child: StaggeredFadeSlide(
                    index: 4,
                    totalItems: 5,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: RecommendedInvestorsSection(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar — greeting + avatar + notification bell
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  const _TopBar({required this.userName, required this.userEmail});

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Founder Account',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
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
                          'Account Sign-in Email',
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
                            fontSize: 14,
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.routeStartupProfile);
              },
              icon: const Icon(Icons.business_center_outlined, size: 18),
              label: const Text('View Startup Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      titleSpacing: 20,
      title: const Text(
        'Dashboard',
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
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _AvatarBubble(
          initials: userName.isNotEmpty ? userName[0] : '?',
          onTap: () => _showAccountSheet(context),
        ),
        const SizedBox(width: 20),
      ],
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
            Icon(icon, color: AppColors.textPrimary, size: 22),
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

class _AvatarBubble extends StatelessWidget {
  final String initials;
  final VoidCallback? onTap;
  const _AvatarBubble({required this.initials, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
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

// ---------------------------------------------------------------------------
// Hero card — greeting + profile-strength ring, combined into one focal point
// ---------------------------------------------------------------------------
class _HeroWelcomeCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final ProfileStrength strength;
  final VoidCallback onTap;
  final bool isLoading;

  const _HeroWelcomeCard({
    required this.userName,
    required this.userEmail,
    required this.strength,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.secondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_timeGreeting()}, $userName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      if (userEmail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                userEmail,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        strength.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _ProgressRing(percent: strength.percent, isLoading: isLoading),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: strength.checklist
                    .map((item) => _ChecklistRow(item: item, onTap: onTap))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;
  final bool isLoading;

  const _ProgressRing({required this.percent, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: isLoading ? null : percent / 100,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          if (!isLoading)
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final ProfileChecklistItem item;
  final VoidCallback? onTap;

  const _ChecklistRow({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              item.isComplete
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.isComplete ? AppColors.primary : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: item.isComplete ? 0.7 : 1.0),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: item.isComplete
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: Colors.white54,
                ),
              ),
            ),
            if (!item.isComplete)
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section heading
// ---------------------------------------------------------------------------
class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics row — now 3 cards with animated counters, scrollable
// ---------------------------------------------------------------------------
class _MetricsRow extends StatelessWidget {
  final List<DashboardMetric> metrics;
  final List<IconData> icons;
  const _MetricsRow({required this.metrics, required this.icons});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return SizedBox(
            width: 155,
            child: _MetricCard(metric: metrics[i], icon: icons[i]),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final DashboardMetric metric;
  final IconData icon;
  const _MetricCard({required this.metric, required this.icon});

  @override
  Widget build(BuildContext context) {
    final Color deltaFg = metric.isPositive
        ? AppColors.success
        : AppColors.warning;
    final Color deltaBg = metric.isPositive
        ? AppColors.successSoft
        : AppColors.warningSoft;

    final numericValue = int.tryParse(
      metric.value.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricIconBadge(icon: icon),
          const SizedBox(height: 8),
          if (numericValue != null)
            AnimatedCounter(
              end: numericValue,
              style: _valueStyle,
            )
          else
            Text(metric.value, style: _valueStyle),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: _labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          _DeltaChip(text: metric.deltaText, fg: deltaFg, bg: deltaBg),
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

class _MetricIconBadge extends StatelessWidget {
  final IconData icon;
  const _MetricIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 18, color: AppColors.primaryDark),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const _DeltaChip({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
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
                icon: Icons.description_outlined,
                label: 'Upload\nPitch Deck',
                gradient: const [Color(0xFF0A2540), Color(0xFF21496E)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeStartupProfile,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.people_alt_outlined,
                label: 'Find\nInvestors',
                gradient: const [Color(0xFF009BC2), Color(0xFF00D1FF)],
                onTap: () => Navigator.of(context).pushReplacementNamed(
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
              child: _QuickActionTile(
                icon: Icons.send_rounded,
                label: 'My\nRequests',
                gradient: const [Color(0xFF11845B), Color(0xFF1DB67E)],
                onTap: () => Navigator.of(context).pushNamed(
                  AppConstants.routeFounderRequests,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                icon: Icons.edit_outlined,
                label: 'Edit\nProfile',
                gradient: const [Color(0xFF7F77DD), Color(0xFFA49AFF)],
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
// Tip of the Day — rotating insights card
// ---------------------------------------------------------------------------
class _TipOfTheDayCard extends StatelessWidget {
  const _TipOfTheDayCard();

  static const _tips = [
    (
      icon: Icons.lightbulb_outline_rounded,
      title: 'Did you know?',
      body:
          'Investors spend an average of 3 minutes 44 seconds reviewing a pitch deck. Make your first 3 slides count!',
    ),
    (
      icon: Icons.trending_up_rounded,
      title: 'Growth tip',
      body:
          'Startups with complete profiles receive 4× more investor inquiries than incomplete ones.',
    ),
    (
      icon: Icons.handshake_outlined,
      title: 'Networking insight',
      body:
          '73% of successful seed deals close within 90 days of the first investor meeting.',
    ),
    (
      icon: Icons.star_outline_rounded,
      title: 'Pro tip',
      body:
          'Adding a team section to your profile increases investor confidence by 62%.',
    ),
    (
      icon: Icons.rocket_launch_outlined,
      title: 'Momentum matters',
      body:
          'Founders who update their pitch deck monthly are 3× more likely to secure funding.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a tip based on the day of the year for stable daily rotation.
    final dayIndex = DateTime.now().difference(DateTime(2025)).inDays;
    final tip = _tips[dayIndex % _tips.length];

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
                colors: [Color(0xFFFFF4D6), Color(0xFFFFE8A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tip.title,
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
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DAILY TIP',
                        style: TextStyle(
                          color: AppColors.primaryDark,
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
// Domain models for Dashboard
// ---------------------------------------------------------------------------

/// A single checklist item inside the "Profile Strength" card.
class ProfileChecklistItem {
  final String label;
  final bool isComplete;

  const ProfileChecklistItem({required this.label, required this.isComplete});
}

/// Snapshot of profile-completeness data.
class ProfileStrength {
  final int percent;
  final String subtitle;
  final List<ProfileChecklistItem> checklist;

  const ProfileStrength({
    required this.percent,
    required this.subtitle,
    required this.checklist,
  });
}

/// One metric tile (Profile Views, Investor Interest, Active Conversations...).
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
