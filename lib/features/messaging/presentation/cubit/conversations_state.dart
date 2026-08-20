import '../../domain/entities/conversation_entity.dart';

sealed class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  final List<ConversationEntity> conversations;
  const ConversationsLoaded(this.conversations);
}

class ConversationsError extends ConversationsState {
  final String message;
  const ConversationsError(this.message);
}

class ConversationsUnauthenticated extends ConversationsState {
  const ConversationsUnauthenticated();
}
