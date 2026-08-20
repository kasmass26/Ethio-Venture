import 'package:flutter/material.dart';
import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';

/// Interactive Onboarding & Welcome Screen for Ethio-Venture.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      icon: Icons.rocket_launch_outlined,
      title: 'Showcase Your Venture',
      description:
          'Create a high-impact startup profile to showcase your product, vision, and team to top investors across Ethiopia.',
    ),
    _OnboardingSlide(
      icon: Icons.handshake_outlined,
      title: 'Connect with Investors',
      description:
          'Get discovered by venture funds, angel investor networks, and strategic partners looking for growth opportunities.',
    ),
    _OnboardingSlide(
      icon: Icons.trending_up_outlined,
      title: 'Scale & Raise Capital',
      description:
          'Track your funding stage, manage your investment goals, and scale your business to new heights.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button / Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pageHorizontal,
                vertical: AppSizes.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/startup-profile');
                    },
                    child: const Text(
                      'Explore Profile',
                      style: TextStyle(
                        color: AppColors.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Onboarding Slides PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pageHorizontal,
                      vertical: AppSizes.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.slate, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.fog,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pageHorizontal,
                vertical: AppSizes.md,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Register Founder Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Sign In as Founder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
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
