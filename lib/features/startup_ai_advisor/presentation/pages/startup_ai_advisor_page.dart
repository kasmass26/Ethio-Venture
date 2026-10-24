import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';
import '../cubit/startup_ai_advisor_cubit.dart';
import '../cubit/startup_ai_advisor_state.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/quick_prompts_bar.dart';
import '../widgets/role_mode_switch.dart';
import '../widgets/startup_context_chip.dart';

class StartupAiAdvisorPage extends StatefulWidget {
  const StartupAiAdvisorPage({
    super.key,
    this.initialRole,
    this.initialStartup,
    this.initialPrompt,
  });

  final String? initialRole;
  final StartupProfileEntity? initialStartup;
  final String? initialPrompt;

  @override
  State<StartupAiAdvisorPage> createState() => _StartupAiAdvisorPageState();
}

class _StartupAiAdvisorPageState extends State<StartupAiAdvisorPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitPrompt(BuildContext context, String prompt) {
    if (prompt.trim().isEmpty) return;
    context.read<StartupAiAdvisorCubit>().sendMessage(prompt);
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StartupAiAdvisorCubit>()
        ..initialize(
          initialRole: widget.initialRole,
          initialStartup: widget.initialStartup,
          initialPrompt: widget.initialPrompt,
        ),
      child: BlocConsumer<StartupAiAdvisorCubit, StartupAiAdvisorState>(
        listener: (context, state) {
          if (state.status == AdvisorStatus.success ||
              state.status == AdvisorStatus.loading) {
            _scrollToBottom();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<StartupAiAdvisorCubit>();
          final config = state.modeConfig;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: config.softColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: config.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'EthioVenture AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: config.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                state.isFounderMode ? 'FOUNDER' : 'INVESTOR',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          config.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (state.messages.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.textSecondary),
                    tooltip: 'Clear Chat',
                    onPressed: () {
                      _showClearConfirmDialog(context, cubit);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded,
                      color: AppColors.textSecondary),
                  tooltip: 'About AI Advisor',
                  onPressed: () {
                    _showInfoDialog(context, config);
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: Column(
              children: [
                // 1. Role Mode Switcher (Founder Co-Pilot vs Investor Intelligence)
                RoleModeSwitch(
                  currentRole: state.roleMode,
                  onRoleChanged: (newRole) {
                    cubit.switchRoleMode(newRole);
                  },
                ),

                // 2. Active Startup Context Pill
                StartupContextChip(
                  selectedStartup: state.selectedStartup,
                  availableStartups: state.availableStartups,
                  onStartupSelected: (startup) {
                    cubit.selectStartup(startup);
                  },
                  primaryColor: config.primaryColor,
                  softColor: config.softColor,
                ),

                // 3. Conversation & Prompts Area
                Expanded(
                  child: state.messages.isEmpty
                      ? _buildEmptyState(context, cubit, state)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: state.messages.length +
                              (state.isGenerating ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < state.messages.length) {
                              final message = state.messages[index];
                              return AiMessageBubble(
                                message: message,
                                primaryColor: config.primaryColor,
                                softColor: config.softColor,
                                onFollowUpSelected: (followUp) {
                                  _submitPrompt(context, followUp);
                                },
                              );
                            } else {
                              return _buildGeneratingIndicator(config);
                            }
                          },
                        ),
                ),

                // 4. Quick prompts strip when chat is active
                if (state.messages.isNotEmpty)
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: config.presets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final preset = config.presets[idx];
                        return InkWell(
                          onTap: () => _submitPrompt(context, preset.prompt),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    config.primaryColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(preset.icon,
                                    size: 13, color: config.primaryColor),
                                const SizedBox(width: 5),
                                Text(
                                  preset.title,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: config.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // 5. Modern Bottom Input Row
                _buildInputBar(context, cubit, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    StartupAiAdvisorCubit cubit,
    StartupAiAdvisorState state,
  ) {
    final config = state.modeConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Welcome Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  config.softColor.withValues(alpha: 0.8),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: config.primaryColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: config.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: config.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        state.isFounderMode
                            ? Icons.rocket_launch_rounded
                            : Icons.shield_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.welcomeGreeting,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.isFounderMode
                                ? 'Empowering Ethiopian founders to build & raise'
                                : 'Assisting investors with rigorous venture diligence',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  config.welcomeDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Presets Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: config.primaryColor),
                const SizedBox(width: 6),
                Text(
                  'Recommended Starter Questions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Prompts Category Filter & Carousel
          QuickPromptsBar(
            config: config,
            activeCategory: state.activeCategory,
            onCategoryChanged: (cat) => cubit.setCategory(cat),
            onPromptSelected: (prompt) => _submitPrompt(context, prompt),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingIndicator(dynamic config) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: config.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is analyzing data & formulating recommendations...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    StartupAiAdvisorCubit cubit,
    StartupAiAdvisorState state,
  ) {
    final config = state.modeConfig;
    final hint = state.isFounderMode
        ? 'Ask about pitch, valuation, traction, NBE...'
        : 'Ask about due diligence, red flags, memo...';

    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) {
                  _submitPrompt(context, _textController.text);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: state.isGenerating
                  ? null
                  : () => _submitPrompt(context, _textController.text),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [config.primaryColor, config.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: config.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: state.isGenerating
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(
      BuildContext context, StartupAiAdvisorCubit cubit) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Conversation?'),
        content: const Text(
          'This will reset your conversation history. Would you like to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.clearChat();
              Navigator.pop(dialogCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, dynamic config) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: config.primaryColor),
            const SizedBox(width: 8),
            const Text('EthioVenture AI Advisor'),
          ],
        ),
        content: const Text(
          'EthioVenture AI provides specialized intelligence tailored for both Ethiopian startup founders and investors.\n\n'
          '• Founder Mode: Guides you on pitch decks, pre-seed valuation, unit economics, runway management, and local NBE regulations.\n\n'
          '• Investor Mode: Evaluates startups objectively, screens red flags, creates 12-point due diligence checklists, and drafts investment memos.\n\n'
          'Tip: Use the role switch at the top to test how an investor scrutinizes your startup!',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
