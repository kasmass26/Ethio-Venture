import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../messaging/presentation/pages/chat_page.dart';
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

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatPage(
                conversationId: payload.conversationId,
                participantName: payload.participantName,
              ),
            ),
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
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
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

        bottomNavigationBar: _BottomNavBar(currentIndex: 1),
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

// ── Bottom navigation bar (shared pattern) ────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: currentIndex == 0,
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(AppConstants.routeHome),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Discover',
                selected: currentIndex == 1,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Messages',
                selected: currentIndex == 2,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppConstants.routeMessages),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.secondary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
