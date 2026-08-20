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
    if (user == null) {
      emit(const ConversationsUnauthenticated());
      return;
    }

    emit(const ConversationsLoading());
    try {
      final list = await _repository.getConversations();
      emit(ConversationsLoaded(list));
    } catch (e) {
      emit(ConversationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
