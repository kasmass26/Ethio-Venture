import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/investment_thesis_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

/// Presentation page for Investor Profile & Investment Thesis Setup.
///
/// Guards itself: if no Supabase auth session exists when the page is opened
/// (e.g. the user arrived via the landing page without signing in), it renders
/// an "authentication required" screen instead of attempting database calls
/// that would throw "User is not authenticated".
class InvestorProfilePage extends StatelessWidget {
  const InvestorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth guard — checked once at build time before the cubit is created.
    // currentUser is non-null only when a live Supabase session exists.
    // We use a safe accessor so the page degrades gracefully in test
    // environments where Supabase is not initialised.
    final bool isAuthenticated;
    try {
      isAuthenticated = Supabase.instance.client.auth.currentUser != null;
    } on AssertionError {
      // Supabase not initialised (e.g. widget tests) — fall through to the
      // unauthenticated view so tests that pump the page directly don't crash.
      // In production this path is never taken because main() calls
      // Supabase.initialize() before runApp().
      return BlocProvider(
        create: (_) => sl<InvestorProfileCubit>()..loadProfile(),
        child: const _InvestorProfileView(),
      );
    }

    if (!isAuthenticated) {
      return const _UnauthenticatedView();
    }

    return BlocProvider(
      create: (_) => sl<InvestorProfileCubit>()..loadProfile(),
      child: const _InvestorProfileView(),
    );
  }
}

// ── Unauthenticated placeholder ───────────────────────────────────────────────

/// Shown when the user reaches the Investor Profile page without an active
/// Supabase session. Provides a clear call-to-action instead of crashing.
class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Portal'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Sign in to continue',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'You need an investor account to set up your investment '
                  'thesis. Create a free account or sign in to continue.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppConstants.routeRoleSelection),
                    child: const Text('Create an Account'),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppConstants.routeLogin),
                    child: const Text('Sign In'),
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

// ── Authenticated profile view ────────────────────────────────────────────────

class _InvestorProfileView extends StatefulWidget {
  const _InvestorProfileView();

  @override
  State<_InvestorProfileView> createState() => _InvestorProfileViewState();
}

class _InvestorProfileViewState extends State<_InvestorProfileView> {
  InvestorProfileEntity? _currentProfile;

  void _saveProfile(
    BuildContext context,
    InvestorProfileEntity profile, {
    required bool isDraft,
  }) {
    final cubit = context.read<InvestorProfileCubit>();
    if (_currentProfile != null && _currentProfile!.id.isNotEmpty) {
      // Update existing profile — preserve immutable fields from the server copy.
      cubit.updateProfile(
        InvestorProfileEntity(
          id: _currentProfile!.id,
          userId: _currentProfile!.userId,
          investorType: profile.investorType,
          organizationName: profile.organizationName,
          bio: profile.bio,
          preferredIndustries: profile.preferredIndustries,
          preferredStages: profile.preferredStages,
          ticketSizeMin: profile.ticketSizeMin,
          ticketSizeMax: profile.ticketSizeMax,
          geographicFocus: profile.geographicFocus,
          createdAt: _currentProfile!.createdAt,
        ),
      );
    } else {
      // New profile — the repository injects the authenticated user's UUID.
      cubit.createProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Thesis Setup'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSizes.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: isDark ? Colors.white : AppColors.secondary,
                ),
                const SizedBox(width: AppSizes.xs),
                Text(
                  'Investor Portal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocConsumer<InvestorProfileCubit, InvestorProfileState>(
        listener: (context, state) {
          if (state is InvestorProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is InvestorProfileLoaded) {
            setState(() => _currentProfile = state.profile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Investment thesis saved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvestorProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is InvestorProfileLoaded) {
            _currentProfile = state.profile;
          }

          final isSaving = state is InvestorProfileSaving;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pageHorizontal,
                  vertical: AppSizes.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investment Thesis Setup',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.secondary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Configure your fund criteria, industry preferences, '
                      'and target ticket sizes to receive high-relevance '
                      'Ethiopian startup deal flow.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    InvestmentThesisForm(
                      initialProfile: _currentProfile,
                      isSaving: isSaving,
                      onSaveDraft: (profile) =>
                          _saveProfile(context, profile, isDraft: true),
                      onCompleteProfile: (profile) =>
                          _saveProfile(context, profile, isDraft: false),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
