import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/core/error/result.dart';
import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class SendMessageParams {
  final String conversationId;
  final String senderId;
  final String content;
  final String? senderName;

  const SendMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.senderName,
  });
}

class SendMessageUseCase
    implements UseCase<Result<MessageEntity>, SendMessageParams> {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Result<MessageEntity>> call(SendMessageParams params) async {
    // Validate empty or whitespace-only messages
    if (params.content.trim().isEmpty) {
      return const Error(ValidationFailure('Message content cannot be empty'));
    }

    if (params.conversationId.trim().isEmpty) {
      return const Error(ValidationFailure('Conversation ID cannot be empty'));
    }

    if (params.senderId.trim().isEmpty) {
      return const Error(ValidationFailure('Sender ID cannot be empty'));
    }

    return await repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      content: params.content.trim(),
      senderName: params.senderName,
    );
  }
}
