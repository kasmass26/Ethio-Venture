import 'package:ethioventure/core/constants/app_styles.dart';
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

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryDark : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
