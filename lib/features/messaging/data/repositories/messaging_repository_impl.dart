import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_data_source.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource _remote;

  MessagingRepositoryImpl({required MessagingRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  @override
  Future<List<ConversationEntity>> getConversations() =>
      _remote.getConversations();

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) =>
      _remote.getMessages(conversationId);

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
  }) =>
      _remote.sendMessage(conversationId: conversationId, content: content);

  @override
  Stream<MessageEntity> subscribeToMessages(String conversationId) =>
      _remote.subscribeToMessages(conversationId);

  @override
  Future<ConversationEntity> getOrCreateConversation({
    required String startupProfileId,
    required String investorProfileId,
  }) =>
      _remote.getOrCreateConversation(
        startupProfileId: startupProfileId,
        investorProfileId: investorProfileId,
      );

  @override
  Future<String?> resolveInvestorProfileId() =>
      _remote.resolveInvestorProfileId();
}
