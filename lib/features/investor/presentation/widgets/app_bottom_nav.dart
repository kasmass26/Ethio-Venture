import 'dart:async';

import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/core/services/notification_service.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared bottom navigation shell. Each dashboard passes in its own
/// [items] list, so the same visual chrome serves the founder dashboard
/// (Dashboard/Profile/Investors/Messages) and the investor dashboard
/// (Dashboard/Discover/Messages/Profile) without duplicating layout code.
class AppBottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const investorNavItems = [
    NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    NavItem(icon: Icons.search_rounded, label: 'Discover'),
    NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  const AppBottomNav({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 12,
        right: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final item = items[i];
          return _NavTab(
            icon: item.icon,
            label: item.label,
            selected: selected,
            onTap: () => onTap?.call(i),
          );
        }),
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  StreamSubscription<int>? _unreadSub;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.label.toLowerCase() == 'messages') {
      // Seed with the cached value so the badge appears instantly.
      _unreadCount = NotificationService.instance.cachedUnreadCount;
      // Then listen for live updates.
      _unreadSub =
          NotificationService.instance.unreadCountStream.listen((count) {
        if (mounted) setState(() => _unreadCount = count);
      });
    }
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.selected ? AppColors.primaryDark : AppColors.textSecondary;
    final isMessagesTab = widget.label.toLowerCase() == 'messages';

    Widget iconWidget = Icon(widget.icon, size: 20, color: color);

    if (isMessagesTab) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(widget.icon, size: 20, color: color),
          if (_unreadCount > 0)
            Positioned(
              top: -5,
              right: -8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.coral,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: widget.selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(widget.label,
                style: AppTextStyles.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// One tab in the bottom navigation bar.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}