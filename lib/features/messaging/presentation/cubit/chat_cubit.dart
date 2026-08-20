import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
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
    if (user == null) {
      emit(const ChatUnauthenticated());
      return;
    }

    _conversationId = conversationId;
    emit(const ChatLoading());

    try {
      // Resolve the profile ID that matches messages.sender_id.
      // auth.uid() == users.id, but sender_id == startup_profiles.id
      // or investor_profiles.id.  We try startup first, then investor.
      final myProfileId = await _resolveProfileId(user.id);

      final messages = await _repository.getMessages(conversationId);
      emit(ChatLoaded(messages: messages, myProfileId: myProfileId));
      _subscribeToNewMessages(conversationId);
    } catch (e) {
      emit(ChatError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Returns the startup_profiles.id or investor_profiles.id for [userId].
  ///
  /// Uses [ApiEndpoints] constants for all table names.
  /// Falls back to [userId] itself so the UI degrades gracefully rather
  /// than crashing if neither profile exists yet.
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

    // No profile found — return auth user id as a last resort so the
    // UI still renders rather than crashing.
    return userId;
  }

  void _subscribeToNewMessages(String conversationId) {
    _subscription?.cancel();
    _subscription =
        _repository.subscribeToMessages(conversationId).listen((newMsg) {
      final current = state;
      if (current is ChatLoaded) {
        final updated = List<MessageEntity>.from(current.messages);
        if (!updated.any((m) => m.id == newMsg.id)) {
          updated.add(newMsg);
          emit(current.copyWith(messages: updated));
        }
      }
    });
  }

  Future<void> sendMessage(String content) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;

    final current = state;
    if (current is! ChatLoaded) return;

    emit(current.copyWith(isSending: true));
    try {
      final msg = await _repository.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final updated = List<MessageEntity>.from(current.messages);
      if (!updated.any((m) => m.id == msg.id)) {
        updated.add(msg);
      }
      emit(current.copyWith(messages: updated, isSending: false));
    } catch (e) {
      // Emit transient error then restore loaded state so user can retry.
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
