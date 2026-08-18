import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_state.dart';

class ChatCubit extends ChangeNotifier {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MessagingRepository repository;

  ChatState _state = const ChatInitial();
  ChatState get state => _state;
  StreamSubscription<List<MessageEntity>>? _streamSubscription;

  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
  });

  Future<void> loadChat({
    required ConversationEntity conversation,
    required String currentUserId,
  }) async {
    _state = const ChatLoading();
    notifyListeners();

    // Check authorization upfront
    if (!conversation.isParticipant(currentUserId)) {
      _state = const ChatError(
        'Access Denied: You are not an authorized participant in this conversation.',
        isAuthError: true,
      );
      notifyListeners();
      return;
    }

    final result = await getMessagesUseCase(
      GetMessagesParams(
        conversationId: conversation.id,
        currentUserId: currentUserId,
      ),
    );

    if (result.isSuccess) {
      _state = ChatLoaded(
        conversation: conversation,
        messages: result.dataOrNull ?? [],
        currentUserId: currentUserId,
      );
      // Mark messages as read
      await repository.markAsRead(
        conversationId: conversation.id,
        currentUserId: currentUserId,
      );

      // Subscribe to real-time updates
      _subscribeToRealtime(conversation.id);
    } else {
      final failure = result.failureOrNull;
      _state = ChatError(
        failure?.message ?? 'Failed to load messages',
        isAuthError: failure is AuthFailure,
      );
    }
    notifyListeners();
  }

  void _subscribeToRealtime(String conversationId) {
    _streamSubscription?.cancel();
    _streamSubscription = repository
        .streamMessages(conversationId: conversationId)
        .listen((updatedMessages) {
      if (_state is ChatLoaded) {
        final loaded = _state as ChatLoaded;
        _state = loaded.copyWith(messages: updatedMessages);
        notifyListeners();
      }
    });
  }

  Future<void> sendMessage(String text, {required String senderName}) async {
    if (_state is! ChatLoaded || text.trim().isEmpty) return;
    final loaded = _state as ChatLoaded;

    _state = loaded.copyWith(isSending: true);
    notifyListeners();

    final result = await sendMessageUseCase(
      SendMessageParams(
        conversationId: loaded.conversation.id,
        senderId: loaded.currentUserId,
        content: text.trim(),
        senderName: senderName,
      ),
    );

    if (result.isSuccess) {
      final newMsg = result.dataOrNull!;
      final updatedMessages = List<MessageEntity>.from(loaded.messages)..add(newMsg);
      final updatedConv = loaded.conversation.copyWith(
        lastMessage: newMsg,
        updatedAt: newMsg.sentAt,
      );

      _state = loaded.copyWith(
        conversation: updatedConv,
        messages: updatedMessages,
        isSending: false,
      );
    } else {
      _state = loaded.copyWith(isSending: false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
