import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor/presentation/widgets/app_bottom_nav.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/investment_thesis_form.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/investor_profile_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

// REGENERATED FROM SCRATCH – all layout rebuilt to avoid BoxConstraints
// infinite-width errors that occurred with Center → ConstrainedBox(maxWidth) →
// SingleChildScrollView → Row → OutlinedButton chains.

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
    final bool isAuthenticated;
    try {
      isAuthenticated = Supabase.instance.client.auth.currentUser != null;
    } on AssertionError {
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

class _InvestorProfileViewState extends State<_InvestorProfileView>
    with SingleTickerProviderStateMixin {
  InvestorProfileEntity? _currentProfile;
  bool _isEditing = false;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _switchMode(bool editing) {
    _fadeCtrl.reverse().then((_) {
      if (mounted) {
        setState(() => _isEditing = editing);
        _fadeCtrl.forward();
      }
    });
  }

  void _saveProfile(
    BuildContext context,
    InvestorProfileEntity profile, {
    required bool isDraft,
  }) {
    final cubit = context.read<InvestorProfileCubit>();
    if (_currentProfile != null && _currentProfile!.id.isNotEmpty) {
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
      cubit.createProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final showDisplay = _currentProfile != null && !_isEditing;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: AppBottomNav(
        items: AppBottomNav.investorNavItems,
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeInvestorDashboard,
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed(
              AppConstants.routeStartupSearch,
            );
          }
        },
      ),
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            showDisplay ? 'Investor Profile' : 'Investment Thesis Setup',
            key: ValueKey(showDisplay),
          ),
        ),
        centerTitle: false,
        actions: [
          if (showDisplay)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.xs),
              child: TextButton.icon(
                onPressed: () => _switchMode(true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primary : AppColors.secondary,
                ),
              ),
            )
          else if (_currentProfile != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.xs),
              child: TextButton.icon(
                onPressed: () => _switchMode(false),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.coral,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: AppSizes.md, left: AppSizes.xs),
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
                  size: 14,
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
            _fadeCtrl.reverse().then((_) {
              if (mounted) {
                setState(() {
                  _currentProfile = state.profile;
                  _isEditing = false;
                });
                _fadeCtrl.forward();
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Investment thesis saved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InvestorProfileLoading && _currentProfile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Loading your profile…',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is InvestorProfileLoaded) {
            _currentProfile = state.profile;
          }

          final isSaving = state is InvestorProfileSaving;

          // LayoutBuilder gives every descendant a finite, concrete width.
          // This is the key fix: using LayoutBuilder instead of
          // Center + ConstrainedBox(maxWidth only), which left width unbounded.
          return LayoutBuilder(
            builder: (context, outer) {
              final maxW = outer.maxWidth.clamp(0.0, AppSizes.maxContentWidth);
              final hPad = ((outer.maxWidth - maxW) / 2) + AppSizes.pageHorizontal;

              return FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: AppSizes.lg,
                  ),
                  child: showDisplay
                      ? InvestorProfileDisplayWidget(
                          profile: _currentProfile!,
                          onEdit: () => _switchMode(true),
                        )
                      : _EditFormSection(
                          currentProfile: _currentProfile,
                          isSaving: isSaving,
                          isDark: isDark,
                          theme: theme,
                          onCancel: () => _switchMode(false),
                          onSave: (p, draft) =>
                              _saveProfile(context, p, isDraft: draft),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Edit form section (extracted to avoid putting Rows/Buttons in an
// unbounded-width context) ────────────────────────────────────────────────────

class _EditFormSection extends StatelessWidget {
  const _EditFormSection({
    required this.currentProfile,
    required this.isSaving,
    required this.isDark,
    required this.theme,
    required this.onCancel,
    required this.onSave,
  });

  final InvestorProfileEntity? currentProfile;
  final bool isSaving;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onCancel;
  final void Function(InvestorProfileEntity profile, bool isDraft) onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentProfile != null) ...[  
              // InkWell-based back button avoids OutlinedButton width issues
              InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
            ],
            Expanded(
              child: Text(
                currentProfile != null
                    ? 'Edit Investment Thesis'
                    : 'Investment Thesis Setup',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.secondary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
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

        // ── Form ──────────────────────────────────────────────────────────────
        InvestmentThesisForm(
          initialProfile: currentProfile,
          isSaving: isSaving,
          onSaveDraft: (p) => onSave(p, true),
          onCompleteProfile: (p) => onSave(p, false),
        ),
      ],
    );
  }
}
