import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethioventure/core/services/user_service.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/get_startup_profile.dart';
import 'package:ethioventure/features/startup_profile/domain/usecases/search_startups.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/usecases/ask_startup_ai_usecase.dart';
import 'startup_ai_advisor_state.dart';

class StartupAiAdvisorCubit extends Cubit<StartupAiAdvisorState> {
  StartupAiAdvisorCubit({
    required AskStartupAiUseCase askStartupAiUseCase,
    required UserService userService,
    required GetStartupProfileUseCase getStartupProfileUseCase,
    required SearchStartups searchStartupsUseCase,
  })  : _askStartupAi = askStartupAiUseCase,
        _userService = userService,
        _getStartupProfile = getStartupProfileUseCase,
        _searchStartups = searchStartupsUseCase,
        super(const StartupAiAdvisorState());

  final AskStartupAiUseCase _askStartupAi;
  final UserService _userService;
  final GetStartupProfileUseCase _getStartupProfile;
  final SearchStartups _searchStartups;

  Future<void> initialize({
    String? initialRole,
    StartupProfileEntity? initialStartup,
    String? initialPrompt,
  }) async {
    // 1. Determine active role
    String role = initialRole ?? 'founder';
    final user = await _userService.getCurrentUser();
    if (initialRole == null && user != null) {
      role = user.role.toLowerCase() == 'investor' ? 'investor' : 'founder';
    }

    emit(state.copyWith(
      roleMode: role,
      selectedStartup: () => initialStartup,
      isLoadingStartups: true,
    ));

    // 2. Fetch available platform startups in background for selection sheet
    List<StartupProfileEntity> availableStartups = [];
    try {
      availableStartups = await _searchStartups(const StartupFilter(pageSize: 30));
    } catch (_) {}

    // 3. If founder mode and no initial startup provided, try to auto-load founder's startup
    StartupProfileEntity? startup = initialStartup;
    if (startup == null && role == 'founder' && user != null) {
      try {
        startup = await _getStartupProfile(user.id);
      } catch (_) {}
    }

    emit(state.copyWith(
      selectedStartup: () => startup,
      availableStartups: availableStartups,
      isLoadingStartups: false,
    ));

    // 4. Send initial prompt if provided
    if (initialPrompt != null && initialPrompt.trim().isNotEmpty) {
      await sendMessage(initialPrompt.trim());
    }
  }

  void switchRoleMode(String newRole) {
    if (state.roleMode == newRole) return;
    emit(state.copyWith(
      roleMode: newRole,
      activeCategory: 'All',
    ));
  }

  void selectStartup(StartupProfileEntity? startup) {
    emit(state.copyWith(selectedStartup: () => startup));
  }

  void setCategory(String category) {
    emit(state.copyWith(activeCategory: category));
  }

  void clearChat() {
    emit(state.copyWith(
      messages: [],
      status: AdvisorStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isGenerating) return;

    final userMessage = AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
      roleMode: state.roleMode,
      startupName: state.selectedStartup?.startupName,
    );

    final updatedMessages = List<AiChatMessage>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      messages: updatedMessages,
      status: AdvisorStatus.loading,
      errorMessage: null,
    ));

    try {
      final aiResponse = await _askStartupAi(
        prompt: trimmed,
        roleMode: state.roleMode,
        startupContext: state.selectedStartup,
        conversationHistory: state.messages,
      );

      emit(state.copyWith(
        messages: List<AiChatMessage>.from(state.messages)..add(aiResponse),
        status: AdvisorStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdvisorStatus.failure,
        errorMessage: 'Unable to get advice right now: ${e.toString()}',
      ));
    }
  }
}
