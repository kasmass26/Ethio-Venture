import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_cubit.dart';
import 'package:ethioventure/features/investor_profile/presentation/cubit/investor_profile_state.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/investment_thesis_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Presentation page for Investor Profile & Investment Thesis Setup.
class InvestorProfilePage extends StatelessWidget {
  const InvestorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvestorProfileCubit>()..loadProfile(),
      child: const _InvestorProfileView(),
    );
  }
}

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
      final updatedProfile = InvestorProfileEntity(
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
      );
      cubit.updateProfile(updatedProfile);
    } else {
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
            setState(() {
              _currentProfile = state.profile;
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
                    // Header Banner
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
                      'Configure your fund criteria, industry preferences, and target ticket sizes to receive high-relevance Ethiopian startup deal flow.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Main Form
                    InvestmentThesisForm(
                      initialProfile: _currentProfile,
                      isSaving: isSaving,
                      onSaveDraft: (profile) => _saveProfile(
                        context,
                        profile,
                        isDraft: true,
                      ),
                      onCompleteProfile: (profile) => _saveProfile(
                        context,
                        profile,
                        isDraft: false,
                      ),
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
