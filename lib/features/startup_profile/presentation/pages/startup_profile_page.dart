import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import '../../../founder/presentation/widgets/dashboard_bottom_nav.dart';
import '../../../pitch_deck/presentation/cubit/document_cubit.dart';
import '../../../pitch_deck/presentation/widgets/pitch_deck_section_widget.dart';
import '../cubit/startup_profile_cubit.dart';
import '../cubit/startup_profile_state.dart';

/// Dashboard view page displaying founder's startup profile.
class StartupProfilePage extends StatelessWidget {
  const StartupProfilePage({super.key});

  static const String routeName = '/startup-profile';

  /// Helper to format currency numbers with commas for thousands (e.g. 436577.00 -> 436,577.00)
  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$integerPart.${parts[1]} USD';
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of Ethio Venture?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
              sl<SupabaseClient>().auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        sl<SupabaseClient>().auth.currentUser?.id ??
        '00000000-0000-0000-0000-000000000000';

    return BlocProvider<StartupProfileCubit>(
      create: (context) =>
          sl<StartupProfileCubit>()..loadProfile(currentUserId),
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: DashboardBottomNav(
          currentIndex: 3,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppConstants.routeFounderDashboard);
            } else if (index == 1) {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppConstants.routeFounderInvestors);
            } else if (index == 2) {
              Navigator.of(
                context,
              ).pushNamed(AppConstants.routeMessages);
            }
          },
        ),
        appBar: AppBar(
          title: const Text('Startup Profile'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Create New Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/startup-profile-setup').then((
                  _,
                ) {
                  if (context.mounted) {
                    context.read<StartupProfileCubit>().loadProfile(
                      currentUserId,
                    );
                  }
                });
              },
            ),
            BlocBuilder<StartupProfileCubit, StartupProfileState>(
              builder: (context, state) {
                if (state is StartupProfileLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit Current Profile',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/edit-startup-profile',
                        arguments: state.profile,
                      ).then((_) {
                        if (context.mounted) {
                          context.read<StartupProfileCubit>().loadProfile(
                            currentUserId,
                          );
                        }
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign Out',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<StartupProfileCubit, StartupProfileState>(
            builder: (context, state) {
              if (state is StartupProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
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
                          padding: const EdgeInsets.all(AppSizes.lg),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.business_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'No Startup Profile Found',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'Create your startup profile to showcase your product, team, and funding goals to investors.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.slate),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/startup-profile-setup',
                            ).then((_) {
                              if (context.mounted) {
                                context.read<StartupProfileCubit>().loadProfile(
                                  currentUserId,
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Setup Profile Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.xl,
                              vertical: AppSizes.md,
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
                          color: AppColors.coral,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'Unable to Load Profile',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.slate),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StartupProfileCubit>().loadProfile(
                              currentUserId,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is StartupProfileLoaded) {
                final profile = state.profile;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.pageHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Summary Card
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.storefront,
                                  color: AppColors.primary,
                                  size: 28,
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
                                          .headlineSmall
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
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          backgroundColor:
                                              AppColors.primaryTint,
                                          visualDensity: VisualDensity.compact,
                                          side: BorderSide.none,
                                        ),
                                        Chip(
                                          label: Text(
                                            profile.fundingStage,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
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
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Funding Request',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: AppColors.slate),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                _formatCurrency(profile.fundingAmountNeeded),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
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
                                    profile.location ?? 'Addis Ababa, Ethiopia',
                                    style: const TextStyle(
                                      color: AppColors.slate,
                                      fontWeight: FontWeight.w500,
                                    ),
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

                      // Pitch Deck & Business Documents Section
                      BlocProvider<DocumentCubit>(
                        create: (context) =>
                            sl<DocumentCubit>()
                              ..loadDocuments(startupId: profile.id),
                        child: PitchDeckSectionWidget(startupId: profile.id),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Contact Information Card with Email Badge
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.contact_mail_outlined,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  Text(
                                    'Contact Details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.ink,
                                        ),
                                  ),
                                ],
                              ),
                              const Divider(height: AppSizes.lg),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMd,
                                  ),
                                  border: Border.all(color: AppColors.fog),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      profile.contactInformation.contains('@')
                                          ? Icons.email_outlined
                                          : Icons.phone_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    SelectableText(
                                      profile.contactInformation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.ink,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      // Bottom Main Action Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit-startup-profile',
                            arguments: profile,
                          ).then((_) {
                            if (context.mounted) {
                              context.read<StartupProfileCubit>().loadProfile(
                                currentUserId,
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Current Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
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
                Icon(icon, size: 20, color: AppColors.primary),
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
                color: AppColors.slate,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
