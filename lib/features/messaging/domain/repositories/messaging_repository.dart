import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

abstract class MessagingRepository {
  /// Retrieves all conversations belonging to the user.
  Future<Result<List<ConversationEntity>>> getConversations({required String userId});

  /// Retrieves or creates a conversation between a founder and an investor.
  Future<Result<ConversationEntity>> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String currentUserRole,
    required String otherUserId,
    required String otherUserName,
    required String otherUserRole,
    String? startupId,
    String? startupName,
  });

  /// Retrieves message history for a conversation, validating participant authorization.
  Future<Result<List<MessageEntity>>> getMessages({
    required String conversationId,
    required String currentUserId,
  });

  /// Sends a message, validating participant authorization and updating conversation timestamp.
  Future<Result<MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  });

  /// Marks unread messages in a conversation as read for the current user.
  Future<Result<void>> markAsRead({
    required String conversationId,
    required String currentUserId,
  });
}
