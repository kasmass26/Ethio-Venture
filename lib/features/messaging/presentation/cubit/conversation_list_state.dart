import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';

sealed class ConversationListState {
  const ConversationListState();
}

class ConversationListInitial extends ConversationListState {
  const ConversationListInitial();
}

class ConversationListLoading extends ConversationListState {
  const ConversationListLoading();
}

class ConversationListLoaded extends ConversationListState {
  final List<ConversationEntity> conversations;
  final String currentUserId;
  final String currentUserName;
  final String currentUserRole;

  const ConversationListLoaded({
    required this.conversations,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
  });

  int get totalUnreadCount => conversations.fold(
        0,
        (sum, conv) => sum + conv.getUnreadCountFor(currentUserId),
      );
}

class ConversationListError extends ConversationListState {
  final String message;
  const ConversationListError(this.message);
}
