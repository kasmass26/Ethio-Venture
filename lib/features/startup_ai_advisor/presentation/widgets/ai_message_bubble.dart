import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_chat_message.dart';
import 'ai_rich_text_view.dart';

class AiMessageBubble extends StatelessWidget {
  const AiMessageBubble({
    super.key,
    required this.message,
    required this.primaryColor,
    required this.softColor,
    required this.onFollowUpSelected,
  });

  final AiChatMessage message;
  final Color primaryColor;
  final Color softColor;
  final ValueChanged<String> onFollowUpSelected;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    }
    return _buildAiBubble(context);
  }

  Widget _buildUserBubble(BuildContext context) {
    final isFounder = message.roleMode.toLowerCase() != 'investor';
    final gradientColors = isFounder
        ? [AppColors.secondary, AppColors.secondaryLight]
        : [const Color(0xFF4C3E9E), AppColors.violet];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 48),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(BuildContext context) {
    final isFounder = message.roleMode.toLowerCase() != 'investor';
    final avatarIcon = isFounder ? Icons.rocket_launch_rounded : Icons.shield_rounded;
    final roleTitle = isFounder ? 'Startup Co-Pilot' : 'Deal Intelligence';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Avatar and Identity
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(avatarIcon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          roleTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                        if (message.startupName != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: softColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                message.startupName!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Copy Button
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                tooltip: 'Copy response',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Response copied to clipboard'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Content Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AiRichTextView(
                  content: message.content,
                  primaryColor: primaryColor,
                  textColor: AppColors.textPrimary,
                ),

                // Key Takeaways Section (if present)
                if (message.keyTakeaways.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: softColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded,
                                size: 16, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              'Key Takeaways',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...message.keyTakeaways.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 14, color: primaryColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.secondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Items Section (if present)
                if (message.actionItems.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.playlist_add_check_rounded,
                                size: 16, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            const Text(
                              'Recommended Next Steps',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...message.actionItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.arrow_right_rounded,
                                    size: 18, color: AppColors.primaryDark),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Follow-up Suggestions Chips
          if (message.suggestedFollowUps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Suggested Follow-ups:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: message.suggestedFollowUps.map((question) {
                return InkWell(
                  onTap: () => onFollowUpSelected(question),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: softColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Icon(Icons.subdirectory_arrow_right_rounded,
                              size: 13, color: primaryColor),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            question,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
