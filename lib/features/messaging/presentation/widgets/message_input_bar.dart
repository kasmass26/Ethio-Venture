import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// Modern, feature-rich message input bar with attachment actions,
/// reply-to preview banner, emoji insertion, and animated send button.
class MessageInputBar extends StatefulWidget {
  const MessageInputBar({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.onTap,
    this.replyToMessage,
    this.replyToSender,
    this.onCancelReply,
    this.onAttachFile,
  });

  final ValueChanged<String> onSend;
  final bool isSending;
  final VoidCallback? onTap;
  final String? replyToMessage;
  final String? replyToSender;
  final VoidCallback? onCancelReply;
  final VoidCallback? onAttachFile;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _controller.clear();
  }

  void _showAttachmentSheet() {
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
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Share & Collaborate',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachOption(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Pitch Deck',
                    color: const Color(0xFFE53E3E),
                    onTap: () {
                      Navigator.pop(ctx);
                      _controller.text = '📄 [Pitch Deck PDF] Attached for review';
                    },
                  ),
                  _buildAttachOption(
                    icon: Icons.image_rounded,
                    label: 'Image',
                    color: const Color(0xFF3182CE),
                    onTap: () {
                      Navigator.pop(ctx);
                      _controller.text = '🖼️ [Screenshot/Image] Shared';
                    },
                  ),
                  _buildAttachOption(
                    icon: Icons.calendar_today_rounded,
                    label: 'Meeting',
                    color: const Color(0xFF38A169),
                    onTap: () {
                      Navigator.pop(ctx);
                      _controller.text =
                          '📅 Available for an intro call: Tomorrow at 2:00 PM (EAT)';
                    },
                  ),
                  _buildAttachOption(
                    icon: Icons.insights_rounded,
                    label: 'Metrics',
                    color: const Color(0xFF805AD5),
                    onTap: () {
                      Navigator.pop(ctx);
                      _controller.text =
                          '📊 Monthly Traction Update: +25% MoM revenue growth';
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Replying Preview Banner ───────────────────────────────────
            if (widget.replyToMessage != null)
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.xs,
                  AppSizes.sm,
                  AppSizes.xs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.replyToSender != null)
                            Text(
                              'Replying to ${widget.replyToSender}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          Text(
                            widget.replyToMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.textSecondary,
                      onPressed: widget.onCancelReply,
                    ),
                  ],
                ),
              ),

            // ── Input Row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs + 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.secondary,
                      size: 26,
                    ),
                    onPressed: _showAttachmentSheet,
                    tooltip: 'Share attachment',
                  ),

                  // Text input container
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm + 4,
                        vertical: 2,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onTap: widget.onTap,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Write a message…',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Send button
                  AnimatedScale(
                    scale: _hasText || widget.isSending ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 150),
                    child: Material(
                      color: _hasText
                          ? AppColors.primary
                          : AppColors.secondary.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      elevation: _hasText ? 3 : 0,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.isSending ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.all(11),
                          child: widget.isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: _hasText
                                      ? AppColors.secondary
                                      : Colors.white,
                                  size: 19,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
