import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/conversation_avatar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';

/// The individual chat screen shown when a user opens a conversation.
///
/// Features modern conversational aesthetics, interactive icebreakers for new chats,
/// participant profile sheets, reply threads, and smooth scroll behaviors.
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
      create: (_) => sl<ChatCubit>()..loadMessages(conversationId),
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
  bool _showScrollToBottom = false;
  String? _replyingToMessage;
  String? _replyingToSender;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final isFarFromBottom = (maxScroll - currentScroll) > 200;

    if (isFarFromBottom != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = isFarFromBottom;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
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
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(max);
      }
    });
  }

  void _showParticipantDetailsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ConversationAvatar(
                name: widget.participantName,
                avatarUrl: widget.participantAvatarUrl,
                radius: 36,
                isOnline: true,
                showOnlineBadge: true,
                hasRing: true,
                ringColor: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                widget.participantName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Verified Partner',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded,
                    color: AppColors.textPrimary),
                title: const Text('View Full Profile',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  // Open discovery or profile view
                  Navigator.of(context).pushNamed(AppConstants.routeStartupSearch);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined,
                    color: AppColors.textPrimary),
                title: const Text('Mute Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications muted for this conversation'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReplyToMessage(MessageEntity msg) {
    setState(() {
      _replyingToMessage = msg.content;
      _replyingToSender = widget.participantName;
    });
  }

  void _handleSend(String text) {
    String finalContent = text;
    if (_replyingToMessage != null) {
      finalContent = '💬 Replying to "$_replyingToMessage":\n$text';
    }
    context.read<ChatCubit>().sendMessage(finalContent);
    setState(() {
      _replyingToMessage = null;
      _replyingToSender = null;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,

      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.secondary.withValues(alpha: 0.08),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: _showParticipantDetailsSheet,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                ConversationAvatar(
                  name: widget.participantName,
                  avatarUrl: widget.participantAvatarUrl,
                  radius: 20,
                  isOnline: true,
                  showOnlineBadge: true,
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
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      const Row(
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Active now',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
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
        actions: [
          IconButton(
            tooltip: 'Call',
            icon: const Icon(
              Icons.videocam_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Audio & Video Calling will be available in the next release.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Details',
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: _showParticipantDetailsSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    if (state is ChatLoaded) {
                      _scrollToBottom();
                    }
                    if (state is ChatError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatLoading || state is ChatInitial) {
                      return const _ChatShimmerLoading();
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
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSizes.md),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSizes.lg),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ChatCubit>()
                                    .loadMessages(widget.conversationId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is ChatLoaded) {
                      if (state.messages.isEmpty) {
                        return _EmptyChatIcebreakers(
                          participantName: widget.participantName,
                          avatarUrl: widget.participantAvatarUrl,
                          onSelectPrompt: (prompt) => _handleSend(prompt),
                        );
                      }

                      final grouped = _groupByDate(state.messages);
                      final myProfileId = state.myProfileId;
                      final currentUid =
                          Supabase.instance.client.auth.currentUser?.id;

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
                            final isOut = msg.senderId == myProfileId ||
                                (currentUid != null &&
                                    msg.senderId == currentUid);

                            return MessageBubble(
                              content: msg.content,
                              sentAt: msg.sentAt,
                              isOutgoing: isOut,
                              onReply: () => _onReplyToMessage(msg),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),

              // ── Input bar ───────────────────────────────────────────────
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  final isSending =
                      state is ChatLoaded && state.isSending;
                  return MessageInputBar(
                    isSending: isSending,
                    replyToMessage: _replyingToMessage,
                    replyToSender: _replyingToSender,
                    onCancelReply: () {
                      setState(() {
                        _replyingToMessage = null;
                        _replyingToSender = null;
                      });
                    },
                    onTap: () => _scrollToBottom(),
                    onSend: (text) => _handleSend(text),
                  );
                },
              ),
            ],
          ),

          // ── Scroll to bottom floating button ─────────────────────────────
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 80,
              child: FloatingActionButton.small(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.secondary,
                elevation: 4,
                onPressed: () => _scrollToBottom(),
                child: const Icon(Icons.arrow_downward_rounded, size: 20),
              ),
            ),
        ],
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[day.month - 1]} ${day.day}, ${day.year}';
  }
}

// ── Icebreaker Suggestions for New Chats ────────────────────────────────────

class _EmptyChatIcebreakers extends StatelessWidget {
  const _EmptyChatIcebreakers({
    required this.participantName,
    this.avatarUrl,
    required this.onSelectPrompt,
  });

  final String participantName;
  final String? avatarUrl;
  final ValueChanged<String> onSelectPrompt;

  @override
  Widget build(BuildContext context) {
    final firstName = participantName.split(' ').first;
    final prompts = [
      '👋 Hi $firstName! Excited to connect on EthioVenture.',
      '💼 Could you share your pitch deck with me?',
      '📅 Would you be open for a brief 15-minute intro meeting?',
      '💡 I would love to learn more about your traction & vision.',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: 24),
      child: Column(
        children: [
          ConversationAvatar(
            name: participantName,
            avatarUrl: avatarUrl,
            radius: 34,
            isOnline: true,
            showOnlineBadge: true,
            hasRing: true,
            ringColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Connected with $participantName',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start the discussion by saying hello or choose a conversation starter below:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ...prompts.map(
            (prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectPrompt(prompt),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            prompt,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat Shimmer Loading ───────────────────────────────────────────────────

class _ChatShimmerLoading extends StatelessWidget {
  const _ChatShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(width: 220, height: 44, borderRadius: 16),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: ShimmerLoading(width: 180, height: 40, borderRadius: 16),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(width: 260, height: 56, borderRadius: 16),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: ShimmerLoading(width: 200, height: 44, borderRadius: 16),
          ),
        ],
      ),
    );
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
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
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

