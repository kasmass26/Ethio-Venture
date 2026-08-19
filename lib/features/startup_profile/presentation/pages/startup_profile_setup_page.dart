import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import '../cubit/startup_profile_cubit.dart';
import '../cubit/startup_profile_state.dart';
import '../widgets/startup_profile_form.dart';

/// Page enabling a founder to set up their initial startup profile.
class StartupProfileSetupPage extends StatelessWidget {
  const StartupProfileSetupPage({super.key});

  static const String routeName = '/startup-profile-setup';

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        sl<SupabaseClient>().auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';

    return BlocProvider<StartupProfileCubit>(
      create: (context) => sl<StartupProfileCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Create Startup Profile'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pageHorizontal),
            child: BlocConsumer<StartupProfileCubit, StartupProfileState>(
              listener: (context, state) {
                if (state is StartupProfileSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pushReplacementNamed(context, '/startup-profile');
                } else if (state is StartupProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isSubmitting = state is StartupProfileSubmitting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell Investors About Your Venture',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Provide comprehensive information to connect with potential investors on Ethio Venture.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      color: AppColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: StartupProfileForm(
                          userId: currentUserId,
                          isSubmitting: isSubmitting,
                          buttonText: 'Create Profile',
                          onSubmit: (profile) {
                            context.read<StartupProfileCubit>().createProfile(
                              profile,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
