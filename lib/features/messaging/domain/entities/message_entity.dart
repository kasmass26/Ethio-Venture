/// Domain entity representing a single message inside a conversation.
/// Maps to the `messages` Supabase table.
///
/// Actual columns: id, conversation_id, sender_id, content, sent_at, read_at
class MessageEntity {
  final String id;
  final String conversationId;

  /// `messages.sender_id` — the profile ID of the sender
  final String senderId;

  /// `messages.content`
  final String content;

  /// `messages.sent_at`
  final DateTime sentAt;

  /// `messages.read_at` (nullable)
  final DateTime? readAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.readAt,
  });
}
