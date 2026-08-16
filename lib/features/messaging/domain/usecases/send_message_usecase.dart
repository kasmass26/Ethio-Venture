import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class SendMessageParams {
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;

  const SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
  });
}

class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Result<MessageEntity>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      senderName: params.senderName,
      receiverId: params.receiverId,
      content: params.content,
    );
  }
}
