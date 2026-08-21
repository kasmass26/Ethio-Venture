import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart';
import '../../core/routing/app_router.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/storage_service.dart';
import '../auth/data/models/user_model.dart';

/// Splash screen that determines the initial route based on auth and onboarding state
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
    // Add a minimum delay for a smooth, premium splash experience
    final minSplashDuration = Future.delayed(const Duration(milliseconds: 1200));

    try {
      final storageService = await StorageService.init();
      final hasSeenOnboarding = storageService.hasCompletedOnboarding();

      // Check if user is already logged in with an active session
      SupabaseClient? supabaseClient;
      try {
        supabaseClient = Supabase.instance.client;
      } catch (_) {
        supabaseClient = null;
      }

      final session = supabaseClient?.auth.currentSession;
      final currentUser = supabaseClient?.auth.currentUser;

      if (session != null && currentUser != null) {
        // User has an active session: fetch role and destination
        UserModel? userModel;
        try {
          if (sl.isRegistered<UserService>()) {
            userModel = await sl<UserService>().getCurrentUser();
          }
        } catch (e) {
          debugPrint('Error retrieving user details in splash: $e');
        }

        final role = userModel?.role ??
            currentUser.userMetadata?['role']?.toString() ??
            AppConstants.roleFounder;
        final email = userModel?.email ?? currentUser.email ?? '';

        // Ensure notification service is initialized for the active user
        if (supabaseClient != null) {
          NotificationService.instance.onUserLoggedIn(supabaseClient);
        }

        // Wait for minimum splash duration before navigation
        await minSplashDuration;
        if (!mounted) return;

        final destination = AppRouter.dashboardRouteForRole(role, email);
        Navigator.of(context).pushReplacementNamed(destination);
        return;
      }

      // No active session: wait for minimum splash duration
      await minSplashDuration;
      if (!mounted) return;

      // Navigate to appropriate screen based on onboarding state
      if (hasSeenOnboarding) {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
      } else {
        Navigator.of(context).pushReplacementNamed(AppConstants.routeOnboarding);
      }
    } catch (e) {
      debugPrint('Error in splash initialization: $e');
      await minSplashDuration;
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
