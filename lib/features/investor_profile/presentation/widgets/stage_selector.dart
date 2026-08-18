import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// Multi-select chip selector for target funding stages.
class StageSelector extends StatelessWidget {
  const StageSelector({
    super.key,
    required this.selectedStages,
    required this.onChanged,
    this.errorText,
  });

  final Set<String> selectedStages;
  final ValueChanged<Set<String>> onChanged;
  final String? errorText;

  static const List<String> availableStages = [
    'Pre-Seed',
    'Seed',
    'Series A',
    'Series B+',
  ];

  void _toggleStage(String stage) {
    final updated = Set<String>.from(selectedStages);
    if (updated.contains(stage)) {
      updated.remove(stage);
    } else {
      updated.add(stage);
    }
    onChanged(updated);
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
          children: availableStages.map((stage) {
            final isSelected = selectedStages.contains(stage);
            return FilterChip(
              label: Text(stage),
              selected: isSelected,
              onSelected: (_) => _toggleStage(stage),
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
                horizontal: AppSizes.md,
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
