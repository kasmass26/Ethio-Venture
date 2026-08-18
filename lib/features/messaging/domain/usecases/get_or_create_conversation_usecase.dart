import 'package:ethioventure/core/error/result.dart';
import 'package:ethioventure/core/usecases/usecase.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';

class GetOrCreateConversationParams {
  final String startupId;
  final String investorId;
  final String? currentUserId;

  const GetOrCreateConversationParams({
    required this.startupId,
    required this.investorId,
    this.currentUserId,
  });
}

class GetOrCreateConversationUseCase
    implements UseCase<Result<ConversationEntity>, GetOrCreateConversationParams> {
  final MessagingRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  @override
  Future<Result<ConversationEntity>> call(GetOrCreateConversationParams params) async {
    return await repository.getOrCreateConversation(
      startupId: params.startupId,
      investorId: params.investorId,
      currentUserId: params.currentUserId,
    );
  }
}
