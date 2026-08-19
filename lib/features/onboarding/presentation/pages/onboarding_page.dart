import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/storage_service.dart';

/// A short, focused intro flow: what Ethio Venture is, what founders get,
/// what investors get — then a clear fork into role-based registration.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.trending_up_rounded,
      title: 'Where ambition meets capital',
      description:
          "Ethio Venture connects Ethiopia's boldest founders with "
          'investors ready to back what\'s next.',
    ),
    _OnboardingSlide(
      icon: Icons.rocket_launch_outlined,
      title: 'Get your startup seen',
      description:
          'Build a profile that tells your story and puts your startup '
          'in front of investors actively looking to fund ideas like yours.',
    ),
    _OnboardingSlide(
      icon: Icons.insights_outlined,
      title: 'Find your next investment',
      description:
          'Browse vetted startups by sector and stage, and connect '
          'directly with founders who match what you\'re looking for.',
    ),
  ];

  bool get _isLastPage => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNext() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToEnd() {
    _controller.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _completeAndNavigate(String routeName, {Object? arguments}) async {
    try {
      final storageService = await StorageService.init();
      await storageService.setOnboardingCompleted();
    } catch (e) {
      // If storage fails, continue anyway
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
            constraints: const BoxConstraints(maxWidth: 720),
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
                    AppSizes.md,
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
                      const SizedBox(height: AppSizes.lg),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        ),
                        child: _isLastPage
                            ? _RoleSelection(
                                key: const ValueKey('roles'),
                                isDark: isDark,
                                onFounder: () =>
                                    _registerAs(AppConstants.roleFounder),
                                onInvestor: () =>
                                    _registerAs(AppConstants.roleInvestor),
                              )
                            : _NextButton(
                                key: const ValueKey('next'),
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
        AppSizes.md,
        AppSizes.sm,
        0,
      ),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSizes.sm),
          Text(
            AppConstants.appName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: showSkip ? 1 : 0,
            child: IgnorePointer(
              ignoring: !showSkip,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(foregroundColor: mutedColor),
                child: const Text('Skip'),
              ),
            ),
          ),
          TextButton(
            onPressed: onSignIn,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.isDark});

  final _OnboardingSlide slide;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconBg =
        isDark ? AppColors.primary.withOpacity(0.14) : AppColors.primarySoft;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.secondary;
    final descColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(slide.icon, color: AppColors.primary, size: 48),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: descColor, fontSize: 15.5, height: 1.5),
          ),
        ],
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
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
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
      height: 52,
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
  });

  final bool isDark;
  final VoidCallback onFounder;
  final VoidCallback onInvestor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _RoleCard(
            isDark: isDark,
            icon: Icons.rocket_launch_outlined,
            title: "I'm a founder",
            description: 'Present your startup and meet the right investors.',
            actionLabel: 'Join as founder',
            onTap: onFounder,
          ),
          _RoleCard(
            isDark: isDark,
            icon: Icons.insights_outlined,
            title: "I'm an investor",
            description: 'Discover ambitious startups that fit your thesis.',
            actionLabel: 'Join as investor',
            onTap: onInvestor,
          ),
        ];

        if (constraints.maxWidth < 520) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: AppSizes.md),
              cards[1],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: AppSizes.md),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
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
    final iconBg =
        isDark ? AppColors.primary.withOpacity(0.14) : AppColors.primarySoft;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: descColor, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}