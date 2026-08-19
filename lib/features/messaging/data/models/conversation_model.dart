import '../../domain/entities/conversation_entity.dart';

/// JSON ↔ domain mapping for the `conversations` Supabase table.
///
/// Actual columns: id, startup_id, investor_id, created_at
///
/// The data source enriches the row with:
///   - other_participant_name  (resolved via startup_profiles/investor_profiles → users)
///   - other_participant_avatar_url
///   - other_participant_profile_id
///   - latest_message_content  (from messages table)
///   - latest_message_at
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.startupId,
    required super.investorId,
    required super.createdAt,
    required super.otherParticipantProfileId,
    required super.otherParticipantName,
    super.otherParticipantAvatarUrl,
    super.latestMessageContent,
    super.latestMessageAt,
  });

  factory ConversationModel.fromEnriched(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      startupId: json['startup_id']?.toString() ?? '',
      investorId: json['investor_id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      otherParticipantProfileId:
          json['other_participant_profile_id']?.toString() ?? '',
      otherParticipantName:
          json['other_participant_name']?.toString() ?? 'Unknown',
      otherParticipantAvatarUrl:
          json['other_participant_avatar_url']?.toString(),
      latestMessageContent:
          json['latest_message_content']?.toString(),
      latestMessageAt: json['latest_message_at'] != null
          ? DateTime.tryParse(json['latest_message_at'].toString())
          : null,
    );
  }
}
