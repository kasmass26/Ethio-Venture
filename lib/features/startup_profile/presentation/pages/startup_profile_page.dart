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

    return MultiBlocProvider(
      providers: [
        BlocProvider<StartupProfileCubit>(
          create: (context) =>
              sl<StartupProfileCubit>()..loadProfile(currentUserId),
        ),
        BlocProvider<DocumentCubit>(
          create: (context) => sl<DocumentCubit>(),
        ),
      ],
      child: BlocListener<StartupProfileCubit, StartupProfileState>(
        listener: (context, state) {
          if (state is StartupProfileLoaded) {
            context.read<DocumentCubit>().loadDocuments(
              startupId: state.profile.id,
            );
          }
        },
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
            title: const Text(
              'Startup Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
                      tooltip: 'Edit Profile',
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
                            padding: const EdgeInsets.all(AppSizes.xl),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.rocket_launch_outlined,
                              size: 54,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),
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
                            'Create your startup profile to showcase your product, team, and funding goals to investors on Ethio Venture.',
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status Notification Banner
                        if (profile.isRejected) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.error.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.cancel, color: AppColors.error, size: 22),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Profile Application Not Approved',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Admin Feedback: ${profile.rejectionReason != null && profile.rejectionReason!.isNotEmpty ? profile.rejectionReason : "Please update your profile details to meet requirements."}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
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
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit & Resubmit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (profile.isPending) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 20),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pending Admin Approval',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Your profile is under review. Once approved by our team, it will go live and become discoverable to investors.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.slate,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Modern Hero Header Banner Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white38, width: 1.5),
                                    ),
                                    child: Text(
                                      profile.startupName.isNotEmpty
                                          ? profile.startupName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.startupName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 15,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                profile.location.isNotEmpty
                                                    ? profile.location
                                                    : 'Addis Ababa, Ethiopia',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.domain_rounded, size: 14, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          profile.industry,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.trending_up_rounded, size: 14, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          profile.fundingStage,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryDark),
                                        SizedBox(width: 6),
                                        Text(
                                          'Verified Venture',
                                          style: TextStyle(
                                            color: AppColors.primaryDark,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Key Metrics Row Card
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.monetization_on_outlined,
                                        size: 20,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _formatCurrency(profile.fundingAmountNeeded),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Funding Requested',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondarySoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.rocket_launch_outlined,
                                        size: 20,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      profile.fundingStage,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Target Stage',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Description Card
                        _buildInfoSection(
                          context,
                          title: 'Overview & Vision',
                          icon: Icons.lightbulb_outline_rounded,
                          content: profile.description,
                        ),
                        const SizedBox(height: 16),

                        // Team Information Card
                        _buildInfoSection(
                          context,
                          title: 'Team & Founders',
                          icon: Icons.groups_2_outlined,
                          content: profile.teamInformation,
                        ),
                        const SizedBox(height: 16),

                        // Pitch Deck & Business Documents Section
                        PitchDeckSectionWidget(
                          startupId: profile.id,
                          isFounder: true,
                        ),
                        const SizedBox(height: 16),

                        // Contact Information Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          color: AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.contact_mail_outlined,
                                      size: 20,
                                      color: AppColors.primaryDark,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Contact Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        profile.contactInformation.contains('@')
                                            ? Icons.email_outlined
                                            : Icons.phone_outlined,
                                        size: 18,
                                        color: AppColors.primaryDark,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SelectableText(
                                          profile.contactInformation,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bottom Action Button
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
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text(
                            'Edit Startup Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryDark),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content.isNotEmpty ? content : 'No details provided.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
