import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/storage_service.dart';

/// Splash screen that determines the initial route based on onboarding state
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add a small delay for smooth splash experience
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final storageService = await StorageService.init();
      final hasSeenOnboarding = storageService.hasCompletedOnboarding();

      if (!mounted) return;

      // Navigate to appropriate screen
      if (hasSeenOnboarding) {
        // User has seen onboarding, go directly to login
        Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
      } else {
        // First time user, show onboarding
        Navigator.of(context).pushReplacementNamed(AppConstants.routeOnboarding);
      }
    } catch (e) {
      // If there's any error, show onboarding to be safe
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeOnboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hub_outlined,
                color: AppColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              AppConstants.appTagline,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
