import 'package:ethioventure/core/error/result.dart';
import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class GetConversationsParams {
  final String userId;
  const GetConversationsParams({required this.userId});
}

class GetConversationsUseCase
    implements UseCase<Result<List<ConversationEntity>>, GetConversationsParams> {
  final MessagingRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Result<List<ConversationEntity>>> call(GetConversationsParams params) async {
    return await repository.getConversations(userId: params.userId);
  }
}
