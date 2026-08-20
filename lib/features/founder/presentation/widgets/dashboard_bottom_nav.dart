import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DashboardBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  static const _items = [
    (icon: Icons.grid_view_rounded, label: 'Dashboard'),
    (icon: Icons.people_alt_outlined, label: 'Investors'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

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
        children: List.generate(_items.length, (i) {
          final selected = i == currentIndex;
          final item = _items[i];
          return _NavItem(
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

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  Future<int>? _countFuture;

  @override
  void initState() {
    super.initState();
    if (widget.label.toLowerCase() == 'messages') {
      _countFuture = _fetchConversationsCount();
    }
  }

  Future<int> _fetchConversationsCount() async {
    try {
      if (!sl.isRegistered<MessagingRepository>()) return 0;
      final conversations = await sl<MessagingRepository>().getConversations();
      return conversations.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? AppColors.primaryDark : AppColors.textSecondary;
    final isMessagesTab = widget.label.toLowerCase() == 'messages';

    Widget iconWidget = Icon(widget.icon, size: 20, color: color);

    if (isMessagesTab) {
      iconWidget = FutureBuilder<int>(
        future: _countFuture,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(widget.icon, size: 20, color: color),
              if (count > 0)
                Positioned(
                  top: -5,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: AppColors.coral,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
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
        },
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
            Text(widget.label, style: AppTextStyles.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
