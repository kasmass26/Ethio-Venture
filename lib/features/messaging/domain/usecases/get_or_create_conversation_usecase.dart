import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class GetOrCreateConversationParams {
  final String currentUserId;
  final String currentUserName;
  final String currentUserRole;
  final String otherUserId;
  final String otherUserName;
  final String otherUserRole;
  final String? startupId;
  final String? startupName;

  const GetOrCreateConversationParams({
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
    this.startupId,
    this.startupName,
  });
}

class GetOrCreateConversationUseCase
    implements UseCase<ConversationEntity, GetOrCreateConversationParams> {
  final MessagingRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  @override
  Future<Result<ConversationEntity>> call(GetOrCreateConversationParams params) async {
    return await repository.getOrCreateConversation(
      currentUserId: params.currentUserId,
      currentUserName: params.currentUserName,
      currentUserRole: params.currentUserRole,
      otherUserId: params.otherUserId,
      otherUserName: params.otherUserName,
      otherUserRole: params.otherUserRole,
      startupId: params.startupId,
      startupName: params.startupName,
    );
  }
}
