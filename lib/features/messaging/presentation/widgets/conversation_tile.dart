import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/conversation_entity.dart';
import 'conversation_avatar.dart';

/// A modern, elevated row in the conversation list.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isUnread = false,
    this.isOnline = true,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;
  final bool isUnread;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = conversation.latestMessageAt ?? conversation.createdAt;
    final hasMessage = conversation.latestMessageContent != null &&
        conversation.latestMessageContent!.trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primarySoft.withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Avatar with online status ──────────────────────────────
              ConversationAvatar(
                name: conversation.otherParticipantName,
                avatarUrl: conversation.otherParticipantAvatarUrl,
                radius: 26,
                isOnline: isOnline,
                showOnlineBadge: true,
              ),
              const SizedBox(width: AppSizes.md),

              // ── Main Content ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Name + timestamp
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherParticipantName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          _formatTimestamp(ts),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w400,
                            color: isUnread
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Bottom row: Message preview + unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasMessage
                                ? conversation.latestMessageContent!
                                : 'Tap to start a conversation…',
                            style: TextStyle(
                              fontSize: 13,
                              color: isUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.normal,
                              fontStyle: hasMessage
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Timestamp helpers ──────────────────────────────────────────────────────

  static String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    if (msgDay == today) {
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } else if (msgDay == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    }
  }
}
