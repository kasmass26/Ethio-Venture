import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Modern, interactive chat message bubble.
/// Supports gradient backgrounds, delivery ticks, long-press context sheet,
/// copy to clipboard, and quick reactions.
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.content,
    required this.sentAt,
    required this.isOutgoing,
    this.replyToContent,
    this.replyToSender,
    this.onReply,
  });

  final String content;
  final DateTime sentAt;
  final bool isOutgoing;
  final String? replyToContent;
  final String? replyToSender;
  final VoidCallback? onReply;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String? _selectedReaction;

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Quick Reactions Bar ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['❤️', '👍', '🚀', '🔥', '💡', '👏'].map((emoji) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReaction =
                              _selectedReaction == emoji ? null : emoji;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // ── Actions ─────────────────────────────────────────────────
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: AppColors.textPrimary),
                title: const Text(
                  'Copy Message',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.content));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Copied to clipboard',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.primarySoft,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              if (widget.onReply != null)
                ListTile(
                  leading:
                      const Icon(Icons.reply_rounded, color: AppColors.textPrimary),
                  title: const Text(
                    'Reply',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onReply?.call();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOut = widget.isOutgoing;
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isOut ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isOut ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Align(
      alignment: isOut ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showContextMenu(context);
        },
        child: Container(
          margin: EdgeInsets.only(
            left: isOut ? 48 : 0,
            right: isOut ? 0 : 48,
            bottom: AppSizes.xs,
          ),
          child: Column(
            crossAxisAlignment:
                isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // ── Bubble Box ───────────────────────────────────────────────
              Container(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isOut
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary,
                            Color(0xFF163E63),
                          ],
                        )
                      : null,
                  color: isOut ? null : AppColors.surface,
                  borderRadius: radius,
                  border: isOut
                      ? null
                      : Border.all(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: isOut
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Optional Quoted reply block
                    if (widget.replyToContent != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOut
                              ? Colors.white.withValues(alpha: 0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: isOut
                                  ? AppColors.primary
                                  : AppColors.secondary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.replyToSender != null)
                              Text(
                                widget.replyToSender!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isOut
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                ),
                              ),
                            Text(
                              widget.replyToContent!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isOut
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Message text
                    Text(
                      widget.content,
                      style: TextStyle(
                        color: isOut ? Colors.white : AppColors.textPrimary,
                        fontSize: 14.5,
                        height: 1.35,
                        letterSpacing: -0.1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Timestamp + read receipts
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(widget.sentAt),
                          style: TextStyle(
                            color: isOut
                                ? Colors.white.withValues(alpha: 0.7)
                                : AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isOut) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.done_all_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Emoji Reaction badge ────────────────────────────────────
              if (_selectedReaction != null)
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _selectedReaction!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
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
