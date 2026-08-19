import '../../domain/entities/message_entity.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isSending;

  /// The resolved `startup_profiles.id` or `investor_profiles.id` for the
  /// authenticated user — used to distinguish outgoing vs incoming bubbles.
  /// Matches `messages.sender_id`.
  final String myProfileId;

  const ChatLoaded({
    required this.messages,
    required this.myProfileId,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? isSending,
    String? myProfileId,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      myProfileId: myProfileId ?? this.myProfileId,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}

class ChatUnauthenticated extends ChatState {
  const ChatUnauthenticated();
}
