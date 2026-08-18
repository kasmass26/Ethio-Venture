import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Multi-select chip selector for investor preferred industries with a 5-item limit.
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

  static const List<String> availableIndustries = [
    'Fintech',
    'Agri-Tech',
    'EdTech',
    'HealthTech',
    'E-commerce',
    'Clean Energy',
    'Logistics',
  ];

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
          children: availableIndustries.map((industry) {
            final isSelected = selectedIndustries.contains(industry);
            return FilterChip(
              label: Text(industry),
              selected: isSelected,
              onSelected: (_) => _toggleIndustry(context, industry),
              checkmarkColor: Colors.white,
              selectedColor: isDark ? AppColors.primary : AppColors.secondary,
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.secondary : Colors.white)
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceVariant,
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
