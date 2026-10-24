import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/startup_ai_advisor_repository.dart';
import '../datasources/startup_ai_advisor_remote_data_source.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';

class StartupAiAdvisorRepositoryImpl implements StartupAiAdvisorRepository {
  const StartupAiAdvisorRepositoryImpl(this._remoteDataSource);

  final StartupAiAdvisorRemoteDataSource _remoteDataSource;

  @override
  Future<AiChatMessage> askAdvisor({
    required String prompt,
    required String roleMode,
    StartupProfileEntity? startupContext,
    List<AiChatMessage> conversationHistory = const [],
  }) {
    return _remoteDataSource.generateAdvisorResponse(
      prompt: prompt,
      roleMode: roleMode,
      startupContext: startupContext,
      conversationHistory: conversationHistory,
    );
  }
}
