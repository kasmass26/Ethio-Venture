import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class GetMessagesParams {
  final String conversationId;
  final String currentUserId;

  const GetMessagesParams({
    required this.conversationId,
    required this.currentUserId,
  });
}

class GetMessagesUseCase implements UseCase<List<MessageEntity>, GetMessagesParams> {
  final MessagingRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Result<List<MessageEntity>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      conversationId: params.conversationId,
      currentUserId: params.currentUserId,
    );
  }
}
