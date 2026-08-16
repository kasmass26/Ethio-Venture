import 'package:ethioventure/features/messaging/data/models/message_model.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participantIds,
    required super.participantNames,
    required super.participantRoles,
    super.startupId,
    super.startupName,
    super.lastMessage,
    super.unreadCounts,
    required super.updatedAt,
    required super.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String? ?? '',
      participantIds: (json['participant_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      participantNames: (json['participant_names'] is Map)
          ? (json['participant_names'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()))
          : {},
      participantRoles: (json['participant_roles'] is Map)
          ? (json['participant_roles'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()))
          : {},
      startupId: json['startup_id'] as String?,
      startupName: json['startup_name'] as String?,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCounts: (json['unread_counts'] is Map)
          ? (json['unread_counts'] as Map)
              .map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : {},
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'participant_names': participantNames,
      'participant_roles': participantRoles,
      'startup_id': startupId,
      'startup_name': startupName,
      'last_message': lastMessage is MessageModel
          ? (lastMessage as MessageModel).toJson()
          : lastMessage != null
              ? MessageModel.fromEntity(lastMessage!).toJson()
              : null,
      'unread_counts': unreadCounts,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      participantRoles: entity.participantRoles,
      startupId: entity.startupId,
      startupName: entity.startupName,
      lastMessage: entity.lastMessage,
      unreadCounts: entity.unreadCounts,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
    );
  }
}
