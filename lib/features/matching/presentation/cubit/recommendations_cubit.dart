import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/matching_repository.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';
import 'recommendations_state.dart';

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final MatchingRepository _matchingRepository;
  final MessagingRepository _messagingRepository;

  RecommendationsCubit({
    required MatchingRepository repository,
    required MessagingRepository messagingRepository,
  })  : _matchingRepository = repository,
        _messagingRepository = messagingRepository,
        super(const RecommendationsInitial());

  Future<void> loadRecommendations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      emit(const RecommendationsUnauthenticated());
      return;
    }

    emit(const RecommendationsLoading());
    try {
      final results = await _matchingRepository.getRecommendations();
      emit(RecommendationsLoaded(results));
    } on Exception catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.toLowerCase().contains('no investor profile')) {
        emit(const RecommendationsNotInvestor());
      } else {
        emit(RecommendationsError(msg));
      }
    } catch (e) {
      emit(RecommendationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Opens (or creates) a direct conversation between the authenticated
  /// investor and the given startup, then signals the UI to navigate.
  ///
  /// [startupProfileId] — `startup_profiles.id`
  /// [startupName]      — display name shown in the chat AppBar
  Future<void> openConversationWith({
    required String startupProfileId,
    required String startupName,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      emit(const RecommendationsUnauthenticated());
      return;
    }

    // Snapshot the current results list so we can restore after navigation.
    final currentResults = switch (state) {
      RecommendationsLoaded(:final results) => results,
      RecommendationsOpeningConversation(:final results) => results,
      _ => <dynamic>[],
    };

    emit(RecommendationsOpeningConversation(
      startupProfileId: startupProfileId,
      results: List.unmodifiable(currentResults),
    ));

    try {
      // Resolve the current user's investor_profiles.id via the repository —
      // keeps Supabase access out of the presentation layer.
      final investorProfileId =
          await _messagingRepository.resolveInvestorProfileId();

      if (investorProfileId == null) {
        emit(const RecommendationsNotInvestor());
        return;
      }

      // Pass names so the returned model has a populated participant name
      // and the ChatPage AppBar shows the correct title immediately.
      final conversation = await _messagingRepository.getOrCreateConversation(
        startupProfileId: startupProfileId,
        investorProfileId: investorProfileId,
      );

      emit(RecommendationsLoaded(
        List.unmodifiable(currentResults),
        pendingConversation: ConversationPayload(
          conversationId: conversation.id,
          participantName: startupName,
        ),
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(RecommendationsError(msg));
      await loadRecommendations();
    }
  }

  /// Called by the page after it has consumed the navigation payload so the
  /// state does not re-trigger navigation on rebuild.
  void clearPendingConversation() {
    final current = state;
    if (current is RecommendationsLoaded &&
        current.pendingConversation != null) {
      emit(current.copyWith(clearPending: true));
    }
  }
}
