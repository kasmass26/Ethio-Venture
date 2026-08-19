import 'package:ethioventure/core/constants/app_styles.dart';
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

class _NavTab extends StatelessWidget {
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


/// One tab in the bottom navigation bar.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}