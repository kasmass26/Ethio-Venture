import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../pitch_deck/presentation/cubit/document_cubit.dart';
import '../../../pitch_deck/presentation/cubit/document_state.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_cubit.dart';
import '../../../startup_profile/presentation/cubit/startup_profile_state.dart';
import '../cubit/recommended_investors_cubit.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/recommended_investor_section.dart';

class FounderDashboardPage extends StatefulWidget {
  const FounderDashboardPage({super.key});

  @override
  State<FounderDashboardPage> createState() => _FounderDashboardPageState();
}

class _FounderDashboardPageState extends State<FounderDashboardPage> {
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

  static const _metrics = [
    DashboardMetric(
      label: 'Profile Views',
      value: '248',
      deltaText: '+12% this week',
      iconAsset: 'views',
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Investor Interest',
      value: '15',
      deltaText: '3 new saves',
      iconAsset: 'interest',
      isPositive: true,
    ),
  ];

  static const _metricIcons = [
    Icons.visibility_outlined,
    Icons.favorite_border_rounded,
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
          } else if (startupState is StartupProfileEmpty ||
              startupState is StartupProfileError) {
            context.read<RecommendedInvestorsCubit>().load();
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
                _TopBar(userName: _userName),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<StartupProfileCubit, StartupProfileState>(
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
                        const SizedBox(height: 24),
                        const _SectionHeading(title: 'Your Momentum'),
                        const SizedBox(height: 12),
                        _MetricsGrid(metrics: _metrics, icons: _metricIcons),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: RecommendedInvestorsSection(),
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
  const _TopBar({required this.userName});

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
        _AvatarBubble(initials: userName.isNotEmpty ? userName[0] : '?'),
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
  const _AvatarBubble({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ---------------------------------------------------------------------------
// Hero card — greeting + profile-strength ring, combined into one focal point
// ---------------------------------------------------------------------------
class _HeroWelcomeCard extends StatelessWidget {
  final String userName;
  final ProfileStrength strength;
  final VoidCallback onTap;
  final bool isLoading;

  const _HeroWelcomeCard({
    required this.userName,
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
                        'Welcome back, $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        strength.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
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
                color: Colors.white.withOpacity(0.12),
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
              backgroundColor: Colors.white.withOpacity(0.25),
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
                  color: Colors.white.withOpacity(item.isComplete ? 0.7 : 1),
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
  final VoidCallback? onSeeAll;
  const _SectionHeading({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final onSeeAllCallback = onSeeAll;
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
        if (onSeeAllCallback != null)
          TextButton(
            onPressed: onSeeAllCallback,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics grid
// ---------------------------------------------------------------------------
class _MetricsGrid extends StatelessWidget {
  final List<DashboardMetric> metrics;
  final List<IconData> icons;
  const _MetricsGrid({required this.metrics, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(metric: metrics[0], icon: icons[0]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(metric: metrics[1], icon: icons[1]),
        ),
      ],
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
          _MetricIconBadge(icon: icon),
          const SizedBox(height: 12),
          Text(metric.value, style: _valueStyle),
          const SizedBox(height: 2),
          Text(metric.label, style: _labelStyle),
          const SizedBox(height: 10),
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
