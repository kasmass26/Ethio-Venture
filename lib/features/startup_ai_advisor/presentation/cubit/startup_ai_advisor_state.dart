import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/ai_advisor_mode.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';

enum AdvisorStatus { initial, loading, success, failure }

class StartupAiAdvisorState extends Equatable {
  const StartupAiAdvisorState({
    this.status = AdvisorStatus.initial,
    this.roleMode = 'founder',
    this.messages = const [],
    this.selectedStartup,
    this.availableStartups = const [],
    this.isLoadingStartups = false,
    this.errorMessage,
    this.activeCategory = 'All',
  });

  final AdvisorStatus status;

  /// 'founder' or 'investor'
  final String roleMode;

  final List<AiChatMessage> messages;

  final StartupProfileEntity? selectedStartup;

  final List<StartupProfileEntity> availableStartups;

  final bool isLoadingStartups;

  final String? errorMessage;

  final String activeCategory;

  bool get isGenerating => status == AdvisorStatus.loading;
  bool get isFounderMode => roleMode.toLowerCase() != 'investor';
  AdvisorModeConfig get modeConfig => AdvisorModeConfig.fromRole(roleMode);

  StartupAiAdvisorState copyWith({
    AdvisorStatus? status,
    String? roleMode,
    List<AiChatMessage>? messages,
    StartupProfileEntity? Function()? selectedStartup,
    List<StartupProfileEntity>? availableStartups,
    bool? isLoadingStartups,
    String? errorMessage,
    String? activeCategory,
  }) {
    return StartupAiAdvisorState(
      status: status ?? this.status,
      roleMode: roleMode ?? this.roleMode,
      messages: messages ?? this.messages,
      selectedStartup:
          selectedStartup != null ? selectedStartup() : this.selectedStartup,
      availableStartups: availableStartups ?? this.availableStartups,
      isLoadingStartups: isLoadingStartups ?? this.isLoadingStartups,
      errorMessage: errorMessage ?? this.errorMessage,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  @override
  List<Object?> get props => [
        status,
        roleMode,
        messages,
        selectedStartup,
        availableStartups,
        isLoadingStartups,
        errorMessage,
        activeCategory,
      ];
}
