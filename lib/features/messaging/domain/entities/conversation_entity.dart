import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

/// Represents a conversation thread between a Startup and an Investor.
/// Maps to `public.conversations` table in Supabase.
class ConversationEntity {
  final String id;
  final String startupId;
  final String investorId;
  final DateTime createdAt;

  // Joined profile metadata for display
  final String? startupUserId;
  final String? startupName;
  final String? startupLogoUrl;
  final String? investorUserId;
  final String? investorName;
  final String? investorType;

  // Computed conversation state
  final MessageEntity? lastMessage;
  final Map<String, int> unreadCounts;
  final DateTime? _updatedAt;

  const ConversationEntity({
    required this.id,
    required this.startupId,
    required this.investorId,
    required this.createdAt,
    this.startupUserId,
    this.startupName,
    this.startupLogoUrl,
    this.investorUserId,
    this.investorName,
    this.investorType,
    this.lastMessage,
    this.unreadCounts = const {},
    DateTime? updatedAt,
  }) : _updatedAt = updatedAt;

  DateTime get updatedAt => _updatedAt ?? lastMessage?.sentAt ?? createdAt;

  /// Helper returning all participant identifiers (user IDs and profile IDs)
  List<String> get participantIds => [
        startupId,
        investorId,
        ?startupUserId,
        ?investorUserId,
      ];

  /// Checks whether a given userId/profileId is an authorized participant
  bool isParticipant(String userId) {
    if (userId.isEmpty) return false;
    return userId == startupId ||
        userId == investorId ||
        userId == startupUserId ||
        userId == investorUserId;
  }

  /// Determines the other participant's display name
  String getOtherParticipantName(String currentUserId) {
    if (currentUserId == startupUserId || currentUserId == startupId) {
      return investorName ?? 'Investor';
    } else {
      return startupName ?? 'Startup Founder';
    }
  }

  /// Determines the other participant's role (Startup vs Investor)
  String getOtherParticipantRole(String currentUserId) {
    if (currentUserId == startupUserId || currentUserId == startupId) {
      return investorType ?? 'Investor';
    } else {
      return 'Startup Founder';
    }
  }

  /// Gets unread message count for a specific user
  int getUnreadCountFor(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  ConversationEntity copyWith({
    String? id,
    String? startupId,
    String? investorId,
    DateTime? createdAt,
    String? startupUserId,
    String? startupName,
    String? startupLogoUrl,
    String? investorUserId,
    String? investorName,
    String? investorType,
    MessageEntity? lastMessage,
    Map<String, int>? unreadCounts,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      investorId: investorId ?? this.investorId,
      createdAt: createdAt ?? this.createdAt,
      startupUserId: startupUserId ?? this.startupUserId,
      startupName: startupName ?? this.startupName,
      startupLogoUrl: startupLogoUrl ?? this.startupLogoUrl,
      investorUserId: investorUserId ?? this.investorUserId,
      investorName: investorName ?? this.investorName,
      investorType: investorType ?? this.investorType,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
