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
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../founder/presentation/widgets/dashboard_bottom_nav.dart';
import '../../../investor/presentation/widgets/app_bottom_nav.dart';
import '../../domain/entities/conversation_entity.dart';
import '../cubit/conversations_cubit.dart';
import '../cubit/conversations_state.dart';
import '../widgets/conversation_avatar.dart';
import '../widgets/conversation_tile.dart';

/// Modern, intuitive Messages inbox with live search, filters,
/// active partner reel, shimmer loading, and clean empty states.
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Unread'
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _detectRole();
    _clearMessageNotifications();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      await NotificationService.instance.refreshUnreadCount(client);
    } catch (_) {}
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
      final metaRole = Supabase.instance.client.auth.currentUser
          ?.userMetadata?['role']
          ?.toString()
          .toLowerCase();
      if (mounted && metaRole != null) {
        setState(() {
          _isInvestor = metaRole == 'investor';
        });
      }
    }
  }

  List<ConversationEntity> _filterConversations(List<ConversationEntity> all) {
    var list = all;

    if (_searchQuery.isNotEmpty) {
      list = list.where((c) {
        final nameMatches =
            c.otherParticipantName.toLowerCase().contains(_searchQuery);
        final msgMatches = (c.latestMessageContent ?? '')
            .toLowerCase()
            .contains(_searchQuery);
        return nameMatches || msgMatches;
      }).toList();
    }

    if (_selectedFilter == 'Unread') {
      list = list.where((c) => c.latestMessageContent != null).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.secondary.withValues(alpha: 0.08),
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _isSearchOpen ? 'Close search' : 'Search messages',
            icon: Icon(
              _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchController.clear();
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search field (collapsible / animated) ────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _isSearchOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.xs,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: _isSearchOpen,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search people or messages…',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: AppColors.textSecondary),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Main conversation list & active contacts ───────────────────
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
          return const _ConversationsShimmerList();
        }

        if (state is ConversationsUnauthenticated) {
          return _EmptyState(
            icon: Icons.lock_outline_rounded,
            title: 'Sign in to view messages',
            subtitle: 'You must be logged in to access your conversations.',
            actionLabel: 'Sign In',
            onAction: () => Navigator.of(context)
                .pushReplacementNamed(AppConstants.routeLogin),
          );
        }

        if (state is ConversationsError) {
          return _EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load messages',
            subtitle: state.message,
            actionLabel: 'Retry',
            onAction: () =>
                context.read<ConversationsCubit>().loadConversations(),
          );
        }

        if (state is ConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return _EmptyState(
              icon: Icons.forum_outlined,
              title: 'No conversations yet',
              subtitle: _isInvestor
                  ? 'Discover promising startups and initiate conversations directly.'
                  : 'Connect with investors in the Discover directory to start a chat.',
              actionLabel:
                  _isInvestor ? 'Explore Startups' : 'Discover Investors',
              onAction: () {
                Navigator.of(context).pushNamed(
                  _isInvestor
                      ? AppConstants.routeStartupSearch
                      : AppConstants.routeFounderInvestors,
                );
              },
            );
          }

          final filtered = _filterConversations(state.conversations);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<ConversationsCubit>().loadConversations(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // ── Active Matches / Recent Contacts Bar ──────────────────
                if (state.conversations.isNotEmpty && _searchQuery.isEmpty)
                  _ActiveContactsBar(
                    conversations: state.conversations,
                    onTapContact: (conv) => _openChat(conv),
                  ),

                // ── Filter Chips Row ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.xs,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip('All', state.conversations.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread', null),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ── Filtered list or Search empty state ───────────────────
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.xl * 1.5,
                      horizontal: AppSizes.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'No results for "$_searchQuery"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Check the spelling or try searching another name.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        OutlinedButton(
                          onPressed: () => _searchController.clear(),
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.divider,
                        height: 1,
                        indent: AppSizes.md + 52 + AppSizes.md,
                      ),
                      itemBuilder: (context, index) {
                        final conv = filtered[index];
                        return ConversationTile(
                          conversation: conv,
                          isOnline: index % 2 == 0,
                          onTap: () => _openChat(conv),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(String label, int? count) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : AppColors.border.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openChat(ConversationEntity conv) {
    Navigator.of(context).pushNamed(
      AppConstants.routeChat,
      arguments: {
        'conversationId': conv.id,
        'participantName': conv.otherParticipantName,
        'participantAvatarUrl': conv.otherParticipantAvatarUrl,
      },
    );
  }
}

// ── Active / Recent Contacts Reel ──────────────────────────────────────────

class _ActiveContactsBar extends StatelessWidget {
  const _ActiveContactsBar({
    required this.conversations,
    required this.onTapContact,
  });

  final List<ConversationEntity> conversations;
  final ValueChanged<ConversationEntity> onTapContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.xs,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Recent Partners',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Active Now',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return InkWell(
                  onTap: () => onTapContact(conv),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 62,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConversationAvatar(
                          name: conv.otherParticipantName,
                          avatarUrl: conv.otherParticipantAvatarUrl,
                          radius: 24,
                          isOnline: index % 2 == 0,
                          showOnlineBadge: true,
                          hasRing: true,
                          ringColor: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          conv.otherParticipantName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Loading List ───────────────────────────────────────────────────

class _ConversationsShimmerList extends StatelessWidget {
  const _ConversationsShimmerList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  ShimmerLoading(
                    width: 52,
                    height: 52,
                    borderRadius: 26,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(
                          width: 120,
                          height: 14,
                          borderRadius: 4,
                        ),
                        SizedBox(height: 8),
                        ShimmerLoading(
                          width: double.infinity,
                          height: 11,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primarySoft,
                    AppColors.surfaceVariant,
                  ],
                ),
              ),
              child: Icon(icon, size: 40, color: AppColors.secondary),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.lg),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
