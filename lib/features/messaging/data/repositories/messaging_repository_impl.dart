import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/core/error/result.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;

  MessagingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ConversationEntity>>> getConversations({
    required String userId,
  }) async {
    try {
      final list = await remoteDataSource.getConversations(userId);
      return Success(list);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<ConversationEntity>> getOrCreateConversation({
    required String startupId,
    required String investorId,
    String? currentUserId,
  }) async {
    try {
      final conv = await remoteDataSource.getOrCreateConversation(
        startupId: startupId,
        investorId: investorId,
        currentUserId: currentUserId,
      );
      return Success(conv);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MessageEntity>>> getMessages({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      final messages = await remoteDataSource.getMessages(
        conversationId: conversationId,
        currentUserId: currentUserId,
      );
      return Success(messages);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? senderName,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        senderName: senderName,
      );
      return Success(message);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    try {
      await remoteDataSource.markAsRead(
        conversationId: conversationId,
        currentUserId: currentUserId,
      );
      return const Success(null);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> streamMessages({required String conversationId}) {
    return remoteDataSource.streamMessages(conversationId: conversationId);
  }
}
