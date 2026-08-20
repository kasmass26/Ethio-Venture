import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form inputs for minimum and maximum ticket size in USD with comparison validation and preset quick chips.
class TicketSizeInputs extends StatelessWidget {
  const TicketSizeInputs({
    super.key,
    required this.minController,
    required this.maxController,
    this.minFocusNode,
    this.maxFocusNode,
    this.onChanged,
  });

  final TextEditingController minController;
  final TextEditingController maxController;
  final FocusNode? minFocusNode;
  final FocusNode? maxFocusNode;
  final VoidCallback? onChanged;

  String? _validateMin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Minimum investment is required';
    }
    final min = double.tryParse(value.replaceAll(',', '').trim());
    if (min == null || min <= 0) {
      return 'Enter a valid positive amount';
    }
    return null;
  }

  String? _validateMax(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Maximum investment is required';
    }
    final max = double.tryParse(value.replaceAll(',', '').trim());
    if (max == null || max <= 0) {
      return 'Enter a valid positive amount';
    }

    final minText = minController.text.replaceAll(',', '').trim();
    final min = double.tryParse(minText);
    if (min != null && max < min) {
      return 'Max ticket must not be less than min (\$${min.toStringAsFixed(0)})';
    }
    return null;
  }

  void _applyPreset(double min, double max) {
    minController.text = min.toStringAsFixed(0);
    maxController.text = max.toStringAsFixed(0);
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final presets = [
      {'label': '\$10k – \$50k', 'min': 10000.0, 'max': 50000.0},
      {'label': '\$50k – \$250k', 'min': 50000.0, 'max': 250000.0},
      {'label': '\$250k – \$1M', 'min': 250000.0, 'max': 1000000.0},
      {'label': '\$1M+', 'min': 1000000.0, 'max': 5000000.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Presets Bar
        Text(
          'QUICK PRESET RANGES',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((preset) {
              final label = preset['label'] as String;
              final min = preset['min'] as double;
              final max = preset['max'] as double;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(label),
                  onPressed: () => _applyPreset(min, max),
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceVariant,
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Custom Min/Max Inputs
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 480;

            final minField = TextFormField(
              controller: minController,
              focusNode: minFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Minimum Investment',
                hintText: 'e.g. 25,000',
                prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                suffixText: 'USD',
                suffixStyle: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              validator: _validateMin,
              onChanged: (_) => onChanged?.call(),
            );

            final maxField = TextFormField(
              controller: maxController,
              focusNode: maxFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Maximum Investment',
                hintText: 'e.g. 500,000',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                suffixText: 'USD',
                suffixStyle: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              validator: _validateMax,
              onChanged: (_) => onChanged?.call(),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: minField),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: maxField),
                ],
              );
            }

            return Column(
              children: [
                minField,
                const SizedBox(height: AppSizes.md),
                maxField,
              ],
            );
          },
        ),
      ],
    );
  }
}
