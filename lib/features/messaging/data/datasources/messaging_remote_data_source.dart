import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_mock_data.dart';
import 'package:ethioventure/features/messaging/data/models/conversation_model.dart';
import 'package:ethioventure/features/messaging/data/models/message_model.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);

  Future<ConversationModel> getOrCreateConversation({
    required String startupId,
    required String investorId,
    String? currentUserId,
  });

  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required String currentUserId,
  });

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? senderName,
  });

  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
  });

  Stream<List<MessageModel>> streamMessages({
    required String conversationId,
  });
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final SupabaseClient? _supabaseClient;
  final Map<String, ConversationModel> _mockConversations = {};
  final List<MessageModel> _mockMessages = [];
  final Map<String, StreamController<List<MessageModel>>> _streamControllers = {};

  MessagingRemoteDataSourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient {
    _initMockStore();
  }

  void _initMockStore() {
    for (final conv in MessagingMockData.initialConversations) {
      _mockConversations[conv.id] = conv;
    }
    _mockMessages.addAll(MessagingMockData.initialMessages);
  }

  bool get _hasActiveSupabaseSession =>
      _supabaseClient != null && _supabaseClient.auth.currentUser != null;

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    if (_hasActiveSupabaseSession) {
      try {
        final response = await _supabaseClient!
            .from('conversations')
            .select('''
              id,
              startup_id,
              investor_id,
              created_at,
              startup_profiles ( id, user_id, business_name, logo_url ),
              investor_profiles ( id, user_id, organization_name, investor_type ),
              messages ( id, conversation_id, sender_id, content, sent_at, read_at )
            ''')
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return list;
      } catch (e) {
        throw ServerException(message: 'Failed to fetch conversations from Supabase: $e');
      }
    }

    // In-memory fallback
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _mockConversations.values
        .where((conv) => conv.isParticipant(userId))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String startupId,
    required String investorId,
    String? currentUserId,
  }) async {
    final client = _supabaseClient;
    if (client != null && _hasActiveSupabaseSession) {
      try {
        // 1. Check if conversation already exists to prevent duplicates
        final existing = await client
            .from('conversations')
            .select('''
              id,
              startup_id,
              investor_id,
              created_at,
              startup_profiles ( id, user_id, business_name, logo_url ),
              investor_profiles ( id, user_id, organization_name, investor_type )
            ''')
            .eq('startup_id', startupId)
            .eq('investor_id', investorId)
            .maybeSingle();

        if (existing != null) {
          return ConversationModel.fromJson(existing);
        }

        // 2. Insert new conversation
        final created = await client
            .from('conversations')
            .insert({
              'startup_id': startupId,
              'investor_id': investorId,
            })
            .select('''
              id,
              startup_id,
              investor_id,
              created_at,
              startup_profiles ( id, user_id, business_name, logo_url ),
              investor_profiles ( id, user_id, organization_name, investor_type )
            ''')
            .single();

        return ConversationModel.fromJson(created);
      } catch (e) {
        throw ServerException(message: 'Failed to create conversation: $e');
      }
    }

    // In-memory fallback
    await Future.delayed(const Duration(milliseconds: 100));
    for (final conv in _mockConversations.values) {
      if (conv.startupId == startupId && conv.investorId == investorId) {
        return conv;
      }
    }

    final newId = 'c0000000-0000-0000-0000-${DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0')}';
    final now = DateTime.now();
    final newConv = ConversationModel(
      id: newId,
      startupId: startupId,
      investorId: investorId,
      startupUserId: currentUserId,
      startupName: 'Startup $startupId',
      investorUserId: currentUserId,
      investorName: 'Investor $investorId',
      unreadCounts: {},
      createdAt: now,
      updatedAt: now,
    );

    _mockConversations[newId] = newConv;
    return newConv;
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    if (_hasActiveSupabaseSession) {
      try {
        final response = await _supabaseClient!
            .from('messages')
            .select('''
              id,
              conversation_id,
              sender_id,
              content,
              sent_at,
              read_at,
              users ( full_name )
            ''')
            .eq('conversation_id', conversationId)
            .order('sent_at', ascending: true);

        return (response as List<dynamic>)
            .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw ServerException(message: 'Failed to retrieve messages from Supabase: $e');
      }
    }

    // In-memory fallback with strict participant authorization check
    await Future.delayed(const Duration(milliseconds: 100));
    final conversation = _mockConversations[conversationId];
    if (conversation == null) {
      throw ServerException(message: 'Conversation not found: $conversationId');
    }

    if (!conversation.isParticipant(currentUserId)) {
      throw AuthException(
        message: 'Access denied: You are not authorized to view messages in this conversation.',
      );
    }

    final history = _mockMessages
        .where((msg) => msg.conversationId == conversationId)
        .toList();
    history.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return history;
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? senderName,
  }) async {
    if (_hasActiveSupabaseSession) {
      try {
        final response = await _supabaseClient!
            .from('messages')
            .insert({
              'conversation_id': conversationId,
              'sender_id': senderId,
              'content': content,
            })
            .select('''
              id,
              conversation_id,
              sender_id,
              content,
              sent_at,
              read_at
            ''')
            .single();

        return MessageModel.fromJson(response);
      } catch (e) {
        throw ServerException(message: 'Failed to send message via Supabase: $e');
      }
    }

    // In-memory fallback with authorization
    await Future.delayed(const Duration(milliseconds: 100));
    final conversation = _mockConversations[conversationId];
    if (conversation == null) {
      throw ServerException(message: 'Conversation not found: $conversationId');
    }

    if (!conversation.isParticipant(senderId)) {
      throw AuthException(
        message: 'Access denied: You are not a participant in this conversation.',
      );
    }

    final now = DateTime.now();
    final msg = MessageModel(
      id: 'm0000000-0000-0000-0000-${now.millisecondsSinceEpoch.toString().padLeft(12, '0')}',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName ?? 'User',
      content: content,
      sentAt: now,
    );

    _mockMessages.add(msg);

    // Update conversation state
    _mockConversations[conversationId] = conversation.copyWith(
      lastMessage: msg,
      updatedAt: now,
    );

    // Emit to active stream listeners
    if (_streamControllers.containsKey(conversationId)) {
      final updatedHistory = _mockMessages
          .where((m) => m.conversationId == conversationId)
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      _streamControllers[conversationId]?.add(updatedHistory);
    }

    return msg;
  }

  @override
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    if (_hasActiveSupabaseSession) {
      try {
        await _supabaseClient!
            .from('messages')
            .update({'read_at': DateTime.now().toIso8601String()})
            .eq('conversation_id', conversationId)
            .neq('sender_id', currentUserId)
            .isFilter('read_at', null);
      } catch (_) {}
      return;
    }

    final conversation = _mockConversations[conversationId];
    if (conversation != null && conversation.isParticipant(currentUserId)) {
      final updatedUnread = Map<String, int>.from(conversation.unreadCounts);
      updatedUnread[currentUserId] = 0;
      _mockConversations[conversationId] = conversation.copyWith(
        unreadCounts: updatedUnread,
      );
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages({required String conversationId}) {
    if (_hasActiveSupabaseSession) {
      return _supabaseClient!
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('sent_at', ascending: true)
          .map((rows) => rows.map((json) => MessageModel.fromJson(json)).toList());
    }

    // In-memory stream
    _streamControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<MessageModel>>.broadcast(),
    );

    // Seed current history
    final initialHistory = _mockMessages
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

    Future.microtask(() {
      _streamControllers[conversationId]?.add(initialHistory);
    });

    return _streamControllers[conversationId]!.stream;
  }
}
