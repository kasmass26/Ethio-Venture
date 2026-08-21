import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../founder/presentation/widgets/dashboard_bottom_nav.dart';
import '../../../investor/presentation/widgets/app_bottom_nav.dart';
import '../cubit/conversations_cubit.dart';
import '../cubit/conversations_state.dart';
import '../widgets/conversation_tile.dart';

/// The Messages inbox screen — matches the reference design:
///
///  AppBar: ← | Ethio Venture | 🔔
///  ─────────────────────────────────
///  Messages                     🔍
///  ─────────────────────────────────
///  [ConversationTile]
///  [ConversationTile]
///  …
///  ─────────────────────────────────
///  Bottom nav: Dashboard | Discover | Messages | Profile
class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationsCubit>(
      create: (_) => sl<ConversationsCubit>()..loadConversations(),
      child: const _ConversationsView(),
    );
  }
}

class _ConversationsView extends StatefulWidget {
  const _ConversationsView();

  @override
  State<_ConversationsView> createState() => _ConversationsViewState();
}

class _ConversationsViewState extends State<_ConversationsView> {
  bool _isInvestor = false;

  @override
  void initState() {
    super.initState();
    _detectRole();
    // Clear the unread notification badge when the user opens their inbox.
    _clearMessageNotifications();
  }

  /// Marks all unread 'message' notifications as read for the current user
  /// and resets the badge counter shown on the bottom navigation.
  Future<void> _clearMessageNotifications() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      await client
          .from(ApiEndpoints.notifications)
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('type', 'message')
          .eq('is_read', false);

      // Refresh the live badge count.
      await NotificationService.instance.refreshUnreadCount(client);
    } catch (_) {
      // Non-fatal — badge will self-correct on next Realtime event.
    }
  }

  Future<void> _detectRole() async {
    try {
      final userService = sl<UserService>();
      final user = await userService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _isInvestor = user.role.toLowerCase() == 'investor';
        });
      }
    } catch (_) {
      final metaRole = Supabase.instance.client.auth.currentUser?.userMetadata?['role']?.toString().toLowerCase();
      if (mounted && metaRole != null) {
        setState(() {
          _isInvestor = metaRole == 'investor';
        });
      }
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(
        _isInvestor
            ? AppConstants.routeInvestorDashboard
            : AppConstants.routeFounderDashboard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _handleBack,
        ),
        title: const Text(
          AppConstants.appName,
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
        children: [
          // ── "Messages" header + search ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs,
            ),
            child: Row(
              children: [
                Text(
                  'Messages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                // Circular search button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, thickness: 1, height: 16),

          // ── Conversation list ───────────────────────────────────────────
          Expanded(child: _buildBody(context)),
        ],
      ),

      // ── Bottom navigation bar ───────────────────────────────────────────
      bottomNavigationBar: _isInvestor
          ? AppBottomNav(
              items: AppBottomNav.investorNavItems,
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeInvestorDashboard,
                  );
                } else if (index == 1) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeStartupSearch,
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeInvestorProfile,
                  );
                }
              },
            )
          : DashboardBottomNav(
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeFounderDashboard,
                  );
                } else if (index == 1) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeFounderInvestors,
                  );
                } else if (index == 3) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.routeStartupProfile,
                  );
                }
              },
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (context, state) {
        if (state is ConversationsLoading || state is ConversationsInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ConversationsUnauthenticated) {
          return _EmptyState(
            icon: Icons.lock_outline,
            title: 'Sign in to view messages',
            subtitle: 'You must be logged in to access your conversations.',
            actionLabel: 'Sign In',
            onAction: () => Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeLogin),
          );
        }

        if (state is ConversationsError) {
          return _EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load messages',
            subtitle: state.message,
            actionLabel: 'Retry',
            onAction: () =>
                context.read<ConversationsCubit>().loadConversations(),
          );
        }

        if (state is ConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return const _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle:
                  'When a match is made, you\'ll be able to start a conversation here.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<ConversationsCubit>().loadConversations(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.conversations.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.divider,
                height: 1,
                indent: AppSizes.md + 52 + AppSizes.md,
              ),
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.routeChat,
                      arguments: {
                        'conversationId': conv.id,
                        'participantName': conv.otherParticipantName,
                        'participantAvatarUrl':
                            conv.otherParticipantAvatarUrl,
                      },
                    );
                  },
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

// ── Empty / error state ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
                color: AppColors.textPrimary,
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
