import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessagingRepository _repository;
  StreamSubscription<MessageEntity>? _subscription;
  String? _conversationId;

  ChatCubit({required MessagingRepository repository})
      : _repository = repository,
        super(const ChatInitial());

  Future<void> loadMessages(String conversationId) async {
    final user = Supabase.instance.client.auth.currentUser;
    developer.log(
      'ChatCubit.loadMessages called for conversationId: "$conversationId", auth uid: "${user?.id}"',
      name: 'ChatCubit.loadMessages',
    );

    if (user == null) {
      developer.log(
        'ChatCubit.loadMessages: User is unauthenticated.',
        name: 'ChatCubit.loadMessages',
        level: 900,
      );
      emit(const ChatUnauthenticated());
      return;
    }

    _conversationId = conversationId;
    emit(const ChatLoading());

    try {
      final myProfileId = await _resolveProfileId(user.id);
      developer.log(
        'ChatCubit.loadMessages: Resolved myProfileId: "$myProfileId"',
        name: 'ChatCubit.loadMessages',
      );

      final messages = await _repository.getMessages(conversationId);
      developer.log(
        'ChatCubit.loadMessages: Received ${messages.length} message(s)',
        name: 'ChatCubit.loadMessages',
      );
      emit(ChatLoaded(messages: messages, myProfileId: myProfileId));
      _subscribeToNewMessages(conversationId);
    } catch (e, st) {
      developer.log(
        'ChatCubit.loadMessages ERROR: $e',
        name: 'ChatCubit.loadMessages',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<String> _resolveProfileId(String userId) async {
    final client = Supabase.instance.client;

    final startupRow = await client
        .from(ApiEndpoints.startupProfiles)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (startupRow != null) return startupRow['id'].toString();

    final investorRow = await client
        .from(ApiEndpoints.investorProfiles)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (investorRow != null) return investorRow['id'].toString();

    return userId;
  }

  void _subscribeToNewMessages(String conversationId) {
    _subscription?.cancel();
    developer.log(
      'ChatCubit: Subscribing to stream for conversation "$conversationId"',
      name: 'ChatCubit.subscribe',
    );
    _subscription =
        _repository.subscribeToMessages(conversationId).listen((newMsg) {
      developer.log(
        'ChatCubit: Received realtime message: "${newMsg.content}" (id: ${newMsg.id})',
        name: 'ChatCubit.stream',
      );
      final current = state;
      if (current is ChatLoaded) {
        final updated = List<MessageEntity>.from(current.messages);
        if (!updated.any((m) => m.id == newMsg.id)) {
          updated.add(newMsg);
          emit(current.copyWith(messages: updated));

          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          if (newMsg.senderId != current.myProfileId &&
              newMsg.senderId != currentUserId) {
            NotificationService.instance.showLocalNotification(
              id: newMsg.id.hashCode,
              title: 'New Message',
              body: newMsg.content,
              payload: jsonEncode({'conversation_id': conversationId}),
            );
          }
        }
      }
    }, onError: (err, st) {
      developer.log(
        'ChatCubit: Stream error: $err',
        name: 'ChatCubit.stream',
        error: err,
        stackTrace: st,
        level: 900,
      );
    });
  }

  Future<void> sendMessage(String content) async {
    final conversationId = _conversationId;
    if (conversationId == null) {
      developer.log(
        'ChatCubit.sendMessage: conversationId is null, cannot send.',
        name: 'ChatCubit.sendMessage',
        level: 900,
      );
      return;
    }

    final current = state;
    if (current is! ChatLoaded) return;

    developer.log(
      'ChatCubit.sendMessage: Sending message "$content" to conversation "$conversationId"',
      name: 'ChatCubit.sendMessage',
    );

    emit(current.copyWith(isSending: true));
    try {
      final msg = await _repository.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      developer.log(
        'ChatCubit.sendMessage: Successfully sent message id "${msg.id}"',
        name: 'ChatCubit.sendMessage',
      );
      final updated = List<MessageEntity>.from(current.messages);
      if (!updated.any((m) => m.id == msg.id)) {
        updated.add(msg);
      }
      emit(current.copyWith(messages: updated, isSending: false));
    } catch (e, st) {
      developer.log(
        'ChatCubit.sendMessage ERROR: $e',
        name: 'ChatCubit.sendMessage',
        error: e,
        stackTrace: st,
        level: 1000,
      );
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
      emit(current.copyWith(isSending: false));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
