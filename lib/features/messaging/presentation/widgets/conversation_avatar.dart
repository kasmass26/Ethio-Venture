import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular avatar for a conversation participant.
/// Falls back to styled initials with gradient background when no image URL is provided.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 26,
    this.isOnline = false,
    this.showOnlineBadge = false,
    this.hasRing = false,
    this.ringColor,
  });

  final String name;
  final String? avatarUrl;
  final double radius;
  final bool isOnline;
  final bool showOnlineBadge;
  final bool hasRing;
  final Color? ringColor;

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF0A2540), Color(0xFF1E4E79)],
    [Color(0xFF009BC2), Color(0xFF00D1FF)],
    [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
    [Color(0xFF2C7A7B), Color(0xFF38B2AC)],
    [Color(0xFFC05621), Color(0xFFED8936)],
    [Color(0xFF2B6CB0), Color(0xFF4299E1)],
  ];

  List<Color> _getGradientForName(String name) {
    if (name.isEmpty) return _avatarGradients.first;
    final hash = name.codeUnits.fold(0, (acc, val) => acc + val);
    return _avatarGradients[hash % _avatarGradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    final gradient = _getGradientForName(name);
    final badgeSize = (radius * 0.58).clamp(9.0, 15.0);

    Widget avatarCore;
    if (url != null && url.trim().isNotEmpty) {
      avatarCore = ClipOval(
        child: Image.network(
          url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(gradient),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: AppColors.surfaceVariant,
              child: const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      avatarCore = _buildInitials(gradient);
    }

    Widget content = hasRing
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ringColor ?? AppColors.primary,
                width: 2,
              ),
            ),
            child: avatarCore,
          )
        : avatarCore;

    if (!showOnlineBadge) {
      return content;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : const Color(0xFF9E9E9E),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.surface,
                width: 2,
              ),
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(List<Color> gradient) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: radius * 0.58,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
