import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final ConversationEntity conversation;
  final List<MessageEntity> messages;
  final String currentUserId;
  final bool isSending;

  const ChatLoaded({
    required this.conversation,
    required this.messages,
    required this.currentUserId,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    ConversationEntity? conversation,
    List<MessageEntity>? messages,
    String? currentUserId,
    bool? isSending,
  }) {
    return ChatLoaded(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  final bool isAuthError;

  const ChatError(this.message, {this.isAuthError = false});
}
