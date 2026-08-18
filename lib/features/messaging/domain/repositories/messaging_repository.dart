import 'package:ethioventure/core/error/result.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

abstract class MessagingRepository {
  /// Retrieves all conversations where the user (startup or investor) participates.
  Future<Result<List<ConversationEntity>>> getConversations({required String userId});

  /// Retrieves an existing conversation between startup and investor or creates a new one.
  Future<Result<ConversationEntity>> getOrCreateConversation({
    required String startupId,
    required String investorId,
    String? currentUserId,
  });

  /// Retrieves message history for a conversation, validating participant authorization.
  Future<Result<List<MessageEntity>>> getMessages({
    required String conversationId,
    required String currentUserId,
  });

  /// Sends a message into a conversation with validation and authorization checks.
  Future<Result<MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? senderName,
  });

  /// Marks unread messages in a conversation as read.
  Future<Result<void>> markAsRead({
    required String conversationId,
    required String currentUserId,
  });

  /// Real-time stream of messages for active chat session.
  Stream<List<MessageEntity>> streamMessages({
    required String conversationId,
  });
}
