import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../cubit/startup_profile_cubit.dart';
import '../cubit/startup_profile_state.dart';

/// Dashboard view page displaying founder's startup profile.
class StartupProfilePage extends StatelessWidget {
  const StartupProfilePage({super.key});

  static const String routeName = '/startup-profile';

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<SupabaseClient>().auth.currentUser?.id ?? '';

    return BlocProvider<StartupProfileCubit>(
      create: (context) {
        final cubit = sl<StartupProfileCubit>();
        cubit.loadProfile(currentUserId);
        return cubit;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Startup Profile'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          actions: [
            BlocBuilder<StartupProfileCubit, StartupProfileState>(
              builder: (context, state) {
                if (state is StartupProfileLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Profile',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-startup-profile',
                        arguments: state.profile,
                      ).then((_) {
                        if (context.mounted) {
                          context
                              .read<StartupProfileCubit>()
                              .loadProfile(currentUserId);
                        }
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<StartupProfileCubit, StartupProfileState>(
            builder: (context, state) {
              if (state is StartupProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.emerald),
                );
              }

              if (state is StartupProfileInitial ||
                  state is StartupProfileEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.emeraldTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.business_center_outlined,
                            size: 40,
                            color: AppColors.emerald,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          'No Startup Profile Found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Create your startup profile to showcase your product, team, and funding goals to investors.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.slate,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/startup-profile-setup',
                            ).then((_) {
                              if (context.mounted) {
                                context
                                    .read<StartupProfileCubit>()
                                    .loadProfile(currentUserId);
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Setup Profile Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.lg,
                              vertical: AppSizes.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is StartupProfileError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: AppSizes.md),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<StartupProfileCubit>()
                                .loadProfile(currentUserId);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is StartupProfileLoaded) {
                return _buildProfileDetails(context, state.profile);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, StartupProfileEntity profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Identity Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldTint,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: AppColors.emerald,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.startupName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Wrap(
                          spacing: AppSizes.xs,
                          children: [
                            Chip(
                              label: Text(
                                profile.industry,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.emerald,
                                ),
                              ),
                              backgroundColor: AppColors.emeraldTint,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                            ),
                            Chip(
                              label: Text(
                                profile.fundingStage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.violet,
                                ),
                              ),
                              backgroundColor: AppColors.violetTint,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Request Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Funding Request',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.slate,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '\$${profile.fundingAmountNeeded.toStringAsFixed(2)} USD',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.emerald,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.slate,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        profile.location,
                        style: const TextStyle(color: AppColors.slate),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Description Card
          _buildInfoSection(
            context,
            title: 'Overview & Vision',
            icon: Icons.description_outlined,
            content: profile.description,
          ),
          const SizedBox(height: AppSizes.md),

          // Team Information Card
          _buildInfoSection(
            context,
            title: 'Team & Founders',
            icon: Icons.people_outline,
            content: profile.teamInformation,
          ),
          const SizedBox(height: AppSizes.md),

          // Contact Information Card
          _buildInfoSection(
            context,
            title: 'Contact Details',
            icon: Icons.contact_mail_outlined,
            content: profile.contactInformation,
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.emerald),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                ),
              ],
            ),
            const Divider(height: AppSizes.lg),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
