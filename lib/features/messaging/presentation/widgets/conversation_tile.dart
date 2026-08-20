import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/conversation_entity.dart';
import 'conversation_avatar.dart';

/// A single row in the conversation list — matches the reference design:
///   [Avatar]  [Bold name ············ timestamp]
///             [Preview text truncated …         ]
///   ───────────────────────────────────────────────
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isUnread = false,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ts = conversation.latestMessageAt ?? conversation.createdAt;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ─────────────────────────────────────────────────────
            ConversationAvatar(
              name: conversation.otherParticipantName,
              avatarUrl: conversation.otherParticipantAvatarUrl,
              radius: 26,
            ),
            const SizedBox(width: AppSizes.md),

            // ── Text block ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherParticipantName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _formatTimestamp(ts),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Message preview
                  Text(
                    conversation.latestMessageContent ?? 'No messages yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
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
      // e.g. 09:42 AM
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } else if (msgDay == yesterday) {
      return 'Yesterday';
    } else {
      // e.g. Oct 12
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    }
  }
}
