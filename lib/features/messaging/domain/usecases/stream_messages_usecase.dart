import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class StreamMessagesUseCase {
  final MessagingRepository repository;

  StreamMessagesUseCase(this.repository);

  Stream<List<MessageEntity>> call(String conversationId) {
    return repository.streamMessages(conversationId: conversationId);
  }
}
