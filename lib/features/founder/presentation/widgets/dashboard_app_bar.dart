import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotification;

  const DashboardAppBar({
    super.key,
    this.onNotificationTap,
    this.hasUnreadNotification = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Text('Ethio Venture', style: AppTextStyles.appBarTitle),
          const Spacer(),
          _NotificationButton(
            hasUnread: hasUnreadNotification,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback? onTap;

  const _NotificationButton({required this.hasUnread, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
            if (hasUnread)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}