import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.senderName = 'User',
    required super.content,
    required super.sentAt,
    super.readAt,
    super.attachmentUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ??
          (json['users'] is Map ? (json['users']['full_name'] as String?) ?? 'User' : 'User'),
      content: json['content'] as String? ?? '',
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString()) ?? DateTime.now()
          : (json['timestamp'] != null
              ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now()),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      content: entity.content,
      sentAt: entity.sentAt,
      readAt: entity.readAt,
      attachmentUrl: entity.attachmentUrl,
    );
  }
}
