import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../../core/widgets/app_logo.dart';

/// Modern, inclusive onboarding experience for both Founders and Investors.
///
/// Features:
/// - Official Ethio Venture app logo branding throughout.
/// - Value proposition for both startup founders and private/angel investors.
/// - Unbiased role selection enabling registration as either Founder or Investor.
/// - Instant sign-in access for existing users of any role.
/// - Persistent completion flag via [StorageService].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_SlideData> _slides = [
    _SlideData(
      isHeroSlide: true,
      badgeText: 'Ethiopia\'s Premier Venture Network',
      title: 'Where Ambition Meets Capital',
      description:
          'Ethio Venture bridges Ethiopia\'s most innovative founders with '
          'forward-thinking investors ready to back the next generation of enterprises.',
      highlights: ['Vetted Startups', 'Smart Matching', 'Direct Deal Flow'],
    ),
    _SlideData(
      isHeroSlide: false,
      badgeText: 'For Startup Founders',
      title: 'Build, Pitch & Raise',
      description:
          'Create a verified venture profile, showcase your pitch deck and traction '
          'metrics, and gain direct visibility with active angel investors and funds.',
      highlights: ['Showcase Pitch Decks', 'Track Growth Metrics', 'Raise Capital'],
      icon: Icons.rocket_launch_rounded,
      accentColor: AppColors.primary,
    ),
    _SlideData(
      isHeroSlide: false,
      badgeText: 'For Strategic Investors',
      title: 'Discover High-Impact Deals',
      description:
          'Filter vetted startups by industry and stage, review financial traction, '
          'and connect directly with high-conviction founders.',
      highlights: ['Curated Pipeline', 'Due Diligence Data', 'Direct Founder Chat'],
      icon: Icons.insights_rounded,
      accentColor: AppColors.violet,
    ),
  ];

  bool get _isLastPage => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_controller.hasClients) {
      if (_page < _slides.length - 1) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
        );
      } else {
        setState(() {
          _page = _slides.length - 1;
        });
      }
    }
  }

  void _skipToEnd() {
    if (_controller.hasClients) {
      _controller.animateToPage(
        _slides.length - 1,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeAndNavigate(String routeName, {Object? arguments}) async {
    try {
      final storageService = await StorageService.init();
      await storageService.setOnboardingCompleted();
    } catch (e) {
      debugPrint('Failed to save onboarding state: $e');
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
    }
  }

  void _registerAs(String role) {
    _completeAndNavigate(AppConstants.routeRegister, arguments: role);
  }

  void _signIn() {
    _completeAndNavigate(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                _TopBar(
                  isDark: isDark,
                  showSkip: !_isLastPage,
                  onSkip: _skipToEnd,
                  onSignIn: _signIn,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (context, index) {
                      return _SlideView(slide: _slides[index], isDark: isDark);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.sm,
                    AppSizes.lg,
                    AppSizes.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PageIndicator(
                        count: _slides.length,
                        current: _page,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        ),
                        child: _isLastPage
                            ? _RoleSelection(
                                key: const ValueKey('role_selection'),
                                isDark: isDark,
                                onFounder: () =>
                                    _registerAs(AppConstants.roleFounder),
                                onInvestor: () =>
                                    _registerAs(AppConstants.roleInvestor),
                                onSignIn: _signIn,
                              )
                            : _NextButton(
                                key: const ValueKey('next_button'),
                                onTap: _goToNext,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isDark,
    required this.showSkip,
    required this.onSkip,
    required this.onSignIn,
  });

  final bool isDark;
  final bool showSkip;
  final VoidCallback onSkip;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        0,
      ),
      child: Row(
        children: [
          const AppLogo(
            size: 32,
            showBorder: true,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            AppConstants.appName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (showSkip)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: mutedColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              child: const Text('Skip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: AppSizes.xs),
          ElevatedButton(
            onPressed: onSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              elevation: 0,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: const Text(
              'Sign in',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.isDark});

  final _SlideData slide;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final descColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 560;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizes.md),
                if (slide.isHeroSlide)
                  _HeroLogoVisual(isDark: isDark, isSmall: isSmallScreen)
                else
                  _SlideIconVisual(
                    icon: slide.icon ?? Icons.star_rounded,
                    accentColor: slide.accentColor ?? AppColors.primary,
                    isDark: isDark,
                    isSmall: isSmallScreen,
                  ),
                SizedBox(height: isSmallScreen ? AppSizes.md : AppSizes.xl),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.16)
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Text(
                    slide.badgeText,
                    style: TextStyle(
                      color: isDark ? AppColors.primary : AppColors.secondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: descColor,
                    fontSize: isSmallScreen ? 14 : 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                // Feature pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: slide.highlights.map((highlight) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            highlight,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.secondaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroLogoVisual extends StatelessWidget {
  const _HeroLogoVisual({required this.isDark, required this.isSmall});

  final bool isDark;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final logoSize = isSmall ? 80.0 : 104.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative glow circle
          Container(
            width: logoSize + 40,
            height: logoSize + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Ambient border ring
          Container(
            width: logoSize + 16,
            height: logoSize + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1.5,
              ),
            ),
          ),
          // App Logo
          AppLogo(
            size: logoSize,
            isCircular: true,
            showShadow: true,
            showBorder: true,
            borderColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SlideIconVisual extends StatelessWidget {
  const _SlideIconVisual({
    required this.icon,
    required this.accentColor,
    required this.isDark,
    required this.isSmall,
  });

  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final size = isSmall ? 80.0 : 100.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? accentColor.withValues(alpha: 0.16)
              : accentColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.4 : 0.28),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.46,
          color: accentColor,
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.isDark,
  });

  final int count;
  final int current;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? AppColors.borderDark : AppColors.border;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.secondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(width: AppSizes.sm),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RoleSelection extends StatelessWidget {
  const _RoleSelection({
    super.key,
    required this.isDark,
    required this.onFounder,
    required this.onInvestor,
    required this.onSignIn,
  });

  final bool isDark;
  final VoidCallback onFounder;
  final VoidCallback onInvestor;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose how you want to join',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _RoleCard(
                isDark: isDark,
                icon: Icons.rocket_launch_rounded,
                accentColor: AppColors.primary,
                title: "I'm a Founder",
                description: 'Showcase your startup & connect with investors.',
                actionLabel: 'Join as Founder',
                onTap: onFounder,
              ),
              _RoleCard(
                isDark: isDark,
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.violet,
                title: "I'm an Investor",
                description: 'Discover vetted deal flow & fund top startups.',
                actionLabel: 'Join as Investor',
                onTap: onInvestor,
              ),
            ];

            if (constraints.maxWidth < 520) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: AppSizes.sm),
                  cards[1],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: AppSizes.md),
                Expanded(child: cards[1]),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(color: mutedColor, fontSize: 13.5),
            ),
            GestureDetector(
              onTap: onSignIn,
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.isDark,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final descColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.secondary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.xs + 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            description,
            style: TextStyle(color: descColor, fontSize: 12.5, height: 1.35),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark ? AppColors.secondary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.isHeroSlide,
    required this.badgeText,
    required this.title,
    required this.description,
    required this.highlights,
    this.icon,
    this.accentColor,
  });

  final bool isHeroSlide;
  final String badgeText;
  final String title;
  final String description;
  final List<String> highlights;
  final IconData? icon;
  final Color? accentColor;
}