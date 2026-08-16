import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/core/usecases/usecase.dart';
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
    required String currentUserId,
    required String currentUserName,
    required String currentUserRole,
    required String otherUserId,
    required String otherUserName,
    required String otherUserRole,
    String? startupId,
    String? startupName,
  }) async {
    try {
      final conv = await remoteDataSource.getOrCreateConversation(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserRole: currentUserRole,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserRole: otherUserRole,
        startupId: startupId,
        startupName: startupName,
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
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        content: content,
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
}
