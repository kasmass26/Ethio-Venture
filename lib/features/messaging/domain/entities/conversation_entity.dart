/// Domain entity representing a conversation between a startup and an investor.
/// Maps to the `conversations` Supabase table.
///
/// Actual columns: id, startup_id, investor_id, created_at
class ConversationEntity {
  final String id;

  /// `conversations.startup_id` — references `startup_profiles.id`
  final String startupId;

  /// `conversations.investor_id` — references `investor_profiles.id`
  final String investorId;

  /// `conversations.created_at`
  final DateTime createdAt;

  /// The profile ID of the other participant (resolved by the data source).
  final String otherParticipantProfileId;

  /// Display name of the other participant (resolved via users join).
  final String otherParticipantName;

  final String? otherParticipantAvatarUrl;

  /// Latest message preview (fetched separately by the data source).
  final String? latestMessageContent;
  final DateTime? latestMessageAt;

  const ConversationEntity({
    required this.id,
    required this.startupId,
    required this.investorId,
    required this.createdAt,
    required this.otherParticipantProfileId,
    required this.otherParticipantName,
    this.otherParticipantAvatarUrl,
    this.latestMessageContent,
    this.latestMessageAt,
  });
}
