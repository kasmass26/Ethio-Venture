import '../entities/ai_chat_message.dart';
import '../repositories/startup_ai_advisor_repository.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

class AskStartupAiUseCase {
  const AskStartupAiUseCase(this._repository);

  final StartupAiAdvisorRepository _repository;

  Future<AiChatMessage> call({
    required String prompt,
    required String roleMode,
    StartupProfileEntity? startupContext,
    List<AiChatMessage> conversationHistory = const [],
  }) {
    return _repository.askAdvisor(
      prompt: prompt,
      roleMode: roleMode,
      startupContext: startupContext,
      conversationHistory: conversationHistory,
    );
  }
}
