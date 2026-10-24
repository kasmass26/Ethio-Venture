import '../entities/ai_chat_message.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

abstract interface class StartupAiAdvisorRepository {
  Future<AiChatMessage> askAdvisor({
    required String prompt,
    required String roleMode,
    StartupProfileEntity? startupContext,
    List<AiChatMessage> conversationHistory = const [],
  });
}
