import 'package:flutter/material.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversation_list_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversation_list_state.dart';
import 'package:ethioventure/features/messaging/presentation/pages/chat_page.dart';
import 'package:ethioventure/features/messaging/presentation/widgets/conversation_tile.dart';

class ConversationsPage extends StatefulWidget {
  final ConversationListCubit cubit;

  const ConversationsPage({
    super.key,
    required this.cubit,
  });

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    widget.cubit.loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.cubit,
        builder: (context, _) {
          final state = widget.cubit.state;

          return switch (state) {
            ConversationListInitial() || ConversationListLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ConversationListError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.cubit.loadConversations(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ConversationListLoaded(
              :final conversations,
              :final currentUserId,
              :final currentUserName,
            ) =>
              conversations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 54, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            const Text(
                              'No Conversations Yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Connect directly with matched startups from your Investor Dashboard to start communicating.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => widget.cubit.loadConversations(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return ConversationTile(
                            conversation: conv,
                            currentUserId: currentUserId,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    conversation: conv,
                                    currentUserId: currentUserId,
                                    currentUserName: currentUserName,
                                    cubit: sl<ChatCubit>(),
                                  ),
                                ),
                              ).then((_) {
                                widget.cubit.loadConversations();
                              });
                            },
                          );
                        },
                      ),
                    ),
          };
        },
      ),
    );
  }
}
