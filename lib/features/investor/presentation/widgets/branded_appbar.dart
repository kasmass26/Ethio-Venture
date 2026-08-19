import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:flutter/material.dart';


/// Shared top bar: brand/page title, optional back button, notification bell.
/// Used by both the founder dashboard (no back button, brand title) and the
/// investor dashboard (back button, page title) so the chrome stays visually
/// identical across the app.
class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotification;

  const BrandedAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackTap,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (showBackButton)
            _IconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(left: showBackButton ? 4 : 8),
            child: Text(title, style: AppTextStyles.appBarTitle),
          ),
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

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.secondary),
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