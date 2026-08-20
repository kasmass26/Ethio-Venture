import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/conversation_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';

/// The individual chat screen shown when a user opens a conversation.
///
/// Displays a full conversation history in chronological order,
/// distinguishing incoming/outgoing messages, timestamps, and provides
/// a real-time-connected message input.
class ChatPage extends StatelessWidget {
  const ChatPage({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
  });

  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (_) =>
          sl<ChatCubit>()..loadMessages(conversationId),
      child: _ChatView(
        conversationId: conversationId,
        participantName: participantName,
        participantAvatarUrl: participantAvatarUrl,
      ),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({
    required this.conversationId,
    required this.participantName,
    this.participantAvatarUrl,
  });

  final String conversationId;
  final String participantName;
  final String? participantAvatarUrl;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(max);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ConversationAvatar(
              name: widget.participantName,
              avatarUrl: widget.participantAvatarUrl,
              radius: 18,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.participantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Active now',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            _scrollToBottom();
          }
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ChatUnauthenticated) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Text(
                  'You must be signed in to view this conversation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ChatCubit>()
                          .loadMessages(widget.conversationId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ChatLoaded) {
            if (state.messages.isEmpty) {
              return const Center(
                child: Text(
                  'No messages yet.\nBe the first to say hello!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            // Group messages by date to display date separators.
            final grouped = _groupByDate(state.messages);
            final myProfileId = state.myProfileId;

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final item = grouped[index];

                if (item is _DateLabel) {
                  return _DateSeparator(label: item.label);
                }

                if (item is _MessageItem) {
                  final msg = item.entity;
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSizes.xs + 2),
                    child: MessageBubble(
                      content: msg.content,
                      sentAt: msg.sentAt,
                      isOutgoing: msg.senderId == myProfileId,
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // ── Input bar ─────────────────────────────────────────────────────────
      bottomNavigationBar: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final isSending =
              state is ChatLoaded && state.isSending;
          return MessageInputBar(
            isSending: isSending,
            onSend: (text) =>
                context.read<ChatCubit>().sendMessage(text),
          );
        },
      ),
    );
  }

  // ── Date grouping helpers ───────────────────────────────────────────────

  List<Object> _groupByDate(List<MessageEntity> messages) {
    final result = <Object>[];
    DateTime? lastDay;

    for (final msg in messages) {
      final dt = msg.sentAt;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (lastDay == null || day != lastDay) {
        result.add(_DateLabel(_formatDateLabel(day)));
        lastDay = day;
      }
      result.add(_MessageItem(msg));
    }
    return result;
  }

  static String _formatDateLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';

    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }
}

// ── Date separator widget ─────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: AppColors.divider, thickness: 1),
          ),
        ],
      ),
    );
  }
}

// ── List item sealed types ─────────────────────────────────────────────────

class _DateLabel {
  final String label;
  _DateLabel(this.label);
}

class _MessageItem {
  final MessageEntity entity;
  _MessageItem(this.entity);
}
