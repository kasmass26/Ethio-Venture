import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../investor/presentation/widgets/app_bottom_nav.dart';
import '../cubit/recommendations_cubit.dart';
import '../cubit/recommendations_state.dart';
import '../widgets/recommendation_card.dart';

/// Investor dashboard screen showing personalised startup recommendations.
class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendationsCubit>(
      create: (_) =>
          sl<RecommendationsCubit>()..loadRecommendations(),
      child: const _RecommendationsView(),
    );
  }
}

class _RecommendationsView extends StatelessWidget {
  const _RecommendationsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<RecommendationsCubit, RecommendationsState>(
      listener: (context, state) {
        // Navigate to ChatPage when a conversation has been resolved.
        if (state is RecommendationsLoaded &&
            state.pendingConversation != null) {
          final payload = state.pendingConversation!;
          // Consume the payload so we don't re-navigate on rebuild.
          context.read<RecommendationsCubit>().clearPendingConversation();

          Navigator.of(context).pushNamed(
            AppConstants.routeChat,
            arguments: {
              'conversationId': payload.conversationId,
              'participantName': payload.participantName,
            },
          );
        }

        // Show error as a snackbar (cubit restores list automatically).
        if (state is RecommendationsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Recommendations',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sub-header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended for You',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Startups matched to your investment preferences',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
                color: AppColors.divider,
                height: AppSizes.md,
                thickness: 1),

            // ── Content ───────────────────────────────────────────────
            Expanded(child: _buildBody(context)),
          ],
        ),

        bottomNavigationBar: AppBottomNav(
          items: AppBottomNav.investorNavItems,
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacementNamed(
                AppConstants.routeInvestorDashboard,
              );
            } else if (index == 1) {
              Navigator.of(context).pushReplacementNamed(
                AppConstants.routeStartupSearch,
              );
            } else if (index == 2) {
              Navigator.of(context).pushNamed(
                AppConstants.routeMessages,
              );
            } else if (index == 3) {
              Navigator.of(context).pushReplacementNamed(
                AppConstants.routeInvestorProfile,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<RecommendationsCubit, RecommendationsState>(
      builder: (context, state) {
        if (state is RecommendationsLoading ||
            state is RecommendationsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is RecommendationsUnauthenticated) {
          return _FullScreenMessage(
            icon: Icons.lock_outline,
            title: 'Sign in required',
            subtitle:
                'You must be signed in to view recommendations.',
            actionLabel: 'Sign In',
            onAction: () => Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeLogin),
          );
        }

        if (state is RecommendationsNotInvestor) {
          return const _FullScreenMessage(
            icon: Icons.info_outline,
            title: 'Investor account required',
            subtitle:
                'Recommendations are available for investor accounts only.',
          );
        }

        // Show the list while a conversation is being opened (per-card
        // loading is shown inside the card itself).
        final results = switch (state) {
          RecommendationsLoaded(:final results) => results,
          RecommendationsOpeningConversation(:final results) => results,
          _ => null,
        };

        final openingForId = state is RecommendationsOpeningConversation
            ? state.startupProfileId
            : null;

        if (results != null) {
          if (results.isEmpty) {
            return const _FullScreenMessage(
              icon: Icons.search_off_rounded,
              title: 'No matches found',
              subtitle:
                  'There are no published startups matching your '
                  'current preferences. Try broadening your '
                  'investment criteria.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context
                .read<RecommendationsCubit>()
                .loadRecommendations(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: AppSizes.xs,
                bottom: AppSizes.xl,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final r = results[index];
                return RecommendationCard(
                  result: r,
                  isOpeningConversation:
                      openingForId == r.startup.id,
                  onViewDetails: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.routeStartupDetail,
                      arguments: r.startup.id,
                    );
                  },
                  onMessageTap: () =>
                      context
                          .read<RecommendationsCubit>()
                          .openConversationWith(
                            startupProfileId: r.startup.id,
                            startupName: r.startup.businessName,
                          ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ── Empty / error placeholder ─────────────────────────────────────────────

class _FullScreenMessage extends StatelessWidget {
  const _FullScreenMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: AppSizes.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
