import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_mock_data.dart';
import 'package:ethioventure/features/messaging/data/models/conversation_model.dart';
import 'package:ethioventure/features/messaging/data/models/message_model.dart';

abstract class MessagingRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String userId);
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String currentUserRole,
    required String otherUserId,
    required String otherUserName,
    required String otherUserRole,
    String? startupId,
    String? startupName,
  });
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required String currentUserId,
  });
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  });
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
  });
}

class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final Map<String, ConversationModel> _conversations = {};
  final List<MessageModel> _messages = [];

  MessagingRemoteDataSourceImpl() {
    _initStore();
  }

  void _initStore() {
    for (final conv in MessagingMockData.initialConversations) {
      _conversations[conv.id] = conv;
    }
    _messages.addAll(MessagingMockData.initialMessages);
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = _conversations.values
        .where((conv) => conv.participantIds.contains(userId))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String currentUserRole,
    required String otherUserId,
    required String otherUserName,
    required String otherUserRole,
    String? startupId,
    String? startupName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Check if an existing conversation exists between these two participants
    for (final conv in _conversations.values) {
      if (conv.participantIds.contains(currentUserId) &&
          conv.participantIds.contains(otherUserId)) {
        return conv;
      }
    }

    // Create a new conversation thread
    final newId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final newConv = ConversationModel(
      id: newId,
      participantIds: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      participantRoles: {
        currentUserId: currentUserRole,
        otherUserId: otherUserRole,
      },
      startupId: startupId,
      startupName: startupName,
      unreadCounts: {currentUserId: 0, otherUserId: 0},
      updatedAt: now,
      createdAt: now,
    );

    _conversations[newId] = newConv;
    return newConv;
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final conversation = _conversations[conversationId];
    if (conversation == null) {
      throw ServerException(message: 'Conversation not found: $conversationId');
    }

    // Strict Authorization Check: User must be a registered participant
    if (!conversation.isParticipant(currentUserId)) {
      throw AuthException(
        message: 'Access denied: You are not authorized to view this conversation.',
      );
    }

    final history = _messages
        .where((msg) => msg.conversationId == conversationId)
        .toList();
    history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return history;
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final conversation = _conversations[conversationId];
    if (conversation == null) {
      throw ServerException(message: 'Conversation not found: $conversationId');
    }

    // Strict Authorization Check
    if (!conversation.isParticipant(senderId)) {
      throw AuthException(
        message: 'Access denied: You cannot send messages in this conversation.',
      );
    }

    final now = DateTime.now();
    final msg = MessageModel(
      id: 'msg_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      timestamp: now,
      isRead: false,
    );

    _messages.add(msg);

    // Update conversation metadata
    final updatedUnread = Map<String, int>.from(conversation.unreadCounts);
    updatedUnread[receiverId] = (updatedUnread[receiverId] ?? 0) + 1;

    _conversations[conversationId] = conversation.copyWith(
      lastMessage: msg,
      updatedAt: now,
      unreadCounts: updatedUnread,
    ) as ConversationModel;

    return msg;
  }

  @override
  Future<void> markAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final conversation = _conversations[conversationId];
    if (conversation != null && conversation.isParticipant(currentUserId)) {
      final updatedUnread = Map<String, int>.from(conversation.unreadCounts);
      updatedUnread[currentUserId] = 0;
      _conversations[conversationId] = conversation.copyWith(
        unreadCounts: updatedUnread,
      ) as ConversationModel;
    }
  }
}
