import '../../domain/entities/message_entity.dart';

/// JSON ↔ domain mapping for the `messages` Supabase table.
///
/// Actual columns: id, conversation_id, sender_id, content, sent_at, read_at
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.sentAt,
    super.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? '') ??
          DateTime.now(),
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
    );
  }
}
