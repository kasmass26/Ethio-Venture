import '../../domain/entities/match_result_entity.dart';

sealed class RecommendationsState {
  const RecommendationsState();
}

class RecommendationsInitial extends RecommendationsState {
  const RecommendationsInitial();
}

class RecommendationsLoading extends RecommendationsState {
  const RecommendationsLoading();
}

class RecommendationsLoaded extends RecommendationsState {
  final List<MatchResultEntity> results;

  /// When non-null, the cubit has just resolved (or created) a conversation
  /// and the UI should navigate to [ChatPage] with this data.
  final ConversationPayload? pendingConversation;

  const RecommendationsLoaded(this.results, {this.pendingConversation});

  RecommendationsLoaded copyWith({
    List<MatchResultEntity>? results,
    ConversationPayload? pendingConversation,
    bool clearPending = false,
  }) {
    return RecommendationsLoaded(
      results ?? this.results,
      pendingConversation:
          clearPending ? null : (pendingConversation ?? this.pendingConversation),
    );
  }
}

/// Thin data-holder so the page knows where to navigate after the cubit
/// resolves getOrCreateConversation.
class ConversationPayload {
  final String conversationId;
  final String participantName;

  const ConversationPayload({
    required this.conversationId,
    required this.participantName,
  });
}

class RecommendationsOpeningConversation extends RecommendationsState {
  /// The startup profile ID for which a conversation is being opened —
  /// used to show a per-card loading indicator.
  final String startupProfileId;
  final List<MatchResultEntity> results;

  const RecommendationsOpeningConversation({
    required this.startupProfileId,
    required this.results,
  });
}

class RecommendationsError extends RecommendationsState {
  final String message;
  const RecommendationsError(this.message);
}

class RecommendationsUnauthenticated extends RecommendationsState {
  const RecommendationsUnauthenticated();
}

class RecommendationsNotInvestor extends RecommendationsState {
  const RecommendationsNotInvestor();
}
