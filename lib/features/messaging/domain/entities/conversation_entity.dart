import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

/// Represents a conversation thread between a Startup Founder and an Investor.
class ConversationEntity {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantRoles;
  final String? startupId;
  final String? startupName;
  final MessageEntity? lastMessage;
  final Map<String, int> unreadCounts;
  final DateTime updatedAt;
  final DateTime createdAt;

  const ConversationEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantRoles,
    this.startupId,
    this.startupName,
    this.lastMessage,
    this.unreadCounts = const {},
    required this.updatedAt,
    required this.createdAt,
  });

  /// Verify if a user is an authorized participant
  bool isParticipant(String userId) => participantIds.contains(userId);

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown User';
  }

  String getOtherParticipantRole(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantRoles[otherId] ?? 'Member';
  }

  int getUnreadCountFor(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  ConversationEntity copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantRoles,
    String? startupId,
    String? startupName,
    MessageEntity? lastMessage,
    Map<String, int>? unreadCounts,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantRoles: participantRoles ?? this.participantRoles,
      startupId: startupId ?? this.startupId,
      startupName: startupName ?? this.startupName,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
