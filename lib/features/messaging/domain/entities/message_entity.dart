/// Represents a direct message exchanged between a startup and an investor.
/// Maps to `public.messages` table in Supabase.
class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final String? attachmentUrl;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName = 'User',
    required this.content,
    required this.sentAt,
    this.readAt,
    this.attachmentUrl,
  });

  bool get isRead => readAt != null;

  DateTime get timestamp => sentAt;

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? sentAt,
    DateTime? readAt,
    String? attachmentUrl,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}
