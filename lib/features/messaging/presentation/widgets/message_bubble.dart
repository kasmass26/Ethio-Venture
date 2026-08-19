import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// A single chat message bubble.
///
/// Outgoing messages (sent by the current user) appear on the right
/// in the primary colour. Incoming messages appear on the left in a
/// light surface variant.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.content,
    required this.sentAt,
    required this.isOutgoing,
  });

  /// `messages.content`
  final String content;

  /// `messages.sent_at`
  final DateTime sentAt;

  final bool isOutgoing;

  @override
  Widget build(BuildContext context) {
    const outgoingColor = AppColors.secondary;
    const incomingColor = AppColors.surfaceVariant;

    final bubbleColor = isOutgoing ? outgoingColor : incomingColor;
    final textColor = isOutgoing ? Colors.white : AppColors.textPrimary;
    final timeColor = isOutgoing ? Colors.white70 : AppColors.textSecondary;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppSizes.radiusLg),
      topRight: const Radius.circular(AppSizes.radiusLg),
      bottomLeft: isOutgoing
          ? const Radius.circular(AppSizes.radiusLg)
          : const Radius.circular(4),
      bottomRight: isOutgoing
          ? const Radius.circular(4)
          : const Radius.circular(AppSizes.radiusLg),
    );

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          margin: EdgeInsets.only(
            left: isOutgoing ? 60 : 0,
            right: isOutgoing ? 0 : 60,
            bottom: AppSizes.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm + 2,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: isOutgoing
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(sentAt),
                style: TextStyle(color: timeColor, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
