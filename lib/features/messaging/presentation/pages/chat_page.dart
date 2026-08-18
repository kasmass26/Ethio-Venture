import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_state.dart';
import 'package:ethioventure/features/messaging/presentation/widgets/chat_bubble.dart';
import 'package:ethioventure/features/messaging/presentation/widgets/message_input_bar.dart';

class ChatPage extends StatefulWidget {
  final ConversationEntity conversation;
  final String currentUserId;
  final String currentUserName;
  final ChatCubit cubit;

  const ChatPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
    required this.cubit,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.cubit.loadChat(
      conversation: widget.conversation,
      currentUserId: widget.currentUserId,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherName = widget.conversation.getOtherParticipantName(widget.currentUserId);
    final otherRole = widget.conversation.getOtherParticipantRole(widget.currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Row(
              children: [
                if (widget.conversation.startupName != null) ...[
                  Text(
                    widget.conversation.startupName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const Text(' • ', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
                Text(
                  otherRole.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.cubit,
        builder: (context, _) {
          final state = widget.cubit.state;

          return switch (state) {
            ChatInitial() || ChatLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ChatError(:final message, :final isAuthError) => _buildErrorView(message, isAuthError),
            ChatLoaded() => _buildChatView(state),
          };
        },
      ),
    );
  }

  Widget _buildErrorView(String message, bool isAuthError) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.error_outline,
              size: 54,
              color: isAuthError ? AppColors.error : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isAuthError ? 'Access Restricted' : 'Error Loading Chat',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Conversations'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(ChatLoaded state) {
    _scrollToBottom();

    return Column(
      children: [
        // Security & Encryption Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          color: AppColors.primary.withValues(alpha: 0.05),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 13, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Direct Startup-Investor Encrypted Channel',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),

        // Message List
        Expanded(
          child: state.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.forum_outlined, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'Start the Conversation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Introduce your investment thesis or startup traction.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: 6),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMe = msg.senderId == widget.currentUserId;
                    return ChatBubble(message: msg, isMe: isMe);
                  },
                ),
        ),

        // Input Bar
        MessageInputBar(
          isSending: state.isSending,
          onSend: (text) {
            widget.cubit.sendMessage(text, senderName: widget.currentUserName);
          },
        ),
      ],
    );
  }
}
