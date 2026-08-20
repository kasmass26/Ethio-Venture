import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Contract for all messaging data operations.
abstract class MessagingRepository {
  /// Returns all conversations the authenticated user participates in,
  /// ordered by latest message descending.
  Future<List<ConversationEntity>> getConversations();

  /// Returns the message history for [conversationId] in chronological order.
  Future<List<MessageEntity>> getMessages(String conversationId);

  /// Sends a message in [conversationId] on behalf of the authenticated user.
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Returns a stream of new messages inserted into [conversationId].
  Stream<MessageEntity> subscribeToMessages(String conversationId);

  /// Creates or retrieves a conversation between the given startup and
  /// investor profile IDs.
  ///
  /// [startupProfileId] is `startup_profiles.id`
  /// [investorProfileId] is `investor_profiles.id`
  Future<ConversationEntity> getOrCreateConversation({
    required String startupProfileId,
    required String investorProfileId,
  });

  /// Returns the `investor_profiles.id` for the currently authenticated user,
  /// or `null` if the user has no investor profile.
  ///
  /// Used by the presentation layer to resolve the investor side of a
  /// conversation without bypassing the repository layer.
  Future<String?> resolveInvestorProfileId();

  /// Returns the `startup_profiles.id` for the currently authenticated user,
  /// or `null` if the user has no startup profile.
  Future<String?> resolveStartupProfileId();
}
