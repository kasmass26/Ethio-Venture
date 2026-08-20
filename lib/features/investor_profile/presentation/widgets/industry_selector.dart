import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Multi-select chip selector for investor preferred industries with icons and a 5-item limit.
class IndustrySelector extends StatelessWidget {
  const IndustrySelector({
    super.key,
    required this.selectedIndustries,
    required this.onChanged,
    this.errorText,
    this.maxSelections = 5,
  });

  final Set<String> selectedIndustries;
  final ValueChanged<Set<String>> onChanged;
  final String? errorText;
  final int maxSelections;

  static const Map<String, IconData> industryIcons = {
    'Fintech': Icons.account_balance_outlined,
    'Agri-Tech': Icons.agriculture_outlined,
    'EdTech': Icons.school_outlined,
    'HealthTech': Icons.medical_services_outlined,
    'E-commerce': Icons.shopping_bag_outlined,
    'Clean Energy': Icons.bolt_outlined,
    'Logistics': Icons.local_shipping_outlined,
  };

  static List<String> get availableIndustries => industryIcons.keys.toList();

  void _toggleIndustry(BuildContext context, String industry) {
    final updated = Set<String>.from(selectedIndustries);
    if (updated.contains(industry)) {
      updated.remove(industry);
      onChanged(updated);
    } else {
      if (updated.length >= maxSelections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can select up to $maxSelections industries only.'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      updated.add(industry);
      onChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: industryIcons.entries.map((entry) {
            final industry = entry.key;
            final icon = entry.value;
            final isSelected = selectedIndustries.contains(industry);

            return InkWell(
              onTap: () => _toggleIndustry(context, industry),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primary : AppColors.secondary)
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark ? AppColors.primary : AppColors.secondary)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : icon,
                      size: 16,
                      color: isSelected
                          ? (isDark ? AppColors.secondary : Colors.white)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      industry,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? AppColors.secondary : Colors.white)
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
