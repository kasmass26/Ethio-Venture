import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/messaging_repository.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final MessagingRepository _repository;

  ConversationsCubit({required MessagingRepository repository})
      : _repository = repository,
        super(const ConversationsInitial());

  Future<void> loadConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    developer.log(
      'ConversationsCubit.loadConversations called. auth uid: "${user?.id}"',
      name: 'ConversationsCubit.loadConversations',
    );

    if (user == null) {
      developer.log(
        'ConversationsCubit.loadConversations: User is unauthenticated.',
        name: 'ConversationsCubit.loadConversations',
        level: 900,
      );
      if (!isClosed) emit(const ConversationsUnauthenticated());
      return;
    }

    if (!isClosed) emit(const ConversationsLoading());
    try {
      final list = await _repository.getConversations();
      if (isClosed) return;
      developer.log(
        'ConversationsCubit.loadConversations: Loaded ${list.length} conversation(s)',
        name: 'ConversationsCubit.loadConversations',
      );
      emit(ConversationsLoaded(list));
    } catch (e, st) {
      if (isClosed) return;
      developer.log(
        'ConversationsCubit.loadConversations ERROR: $e',
        name: 'ConversationsCubit.loadConversations',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      emit(ConversationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
