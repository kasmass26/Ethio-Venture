import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular avatar for a conversation participant.
/// Falls back to styled initials when no image URL is provided.
class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 26,
  });

  final String name;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
        backgroundColor: AppColors.primarySoft,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondarySoft,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: radius * 0.58,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
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
