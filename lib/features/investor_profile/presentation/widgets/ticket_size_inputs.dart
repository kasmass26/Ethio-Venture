import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form inputs for minimum and maximum ticket size in USD with comparison validation.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
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
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Center(
                widthFactor: 0,
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primary
                        : AppColors.secondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            suffixText: 'USD',
            suffixStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
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
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Center(
                widthFactor: 0,
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.primary
                        : AppColors.secondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            suffixText: 'USD',
            suffixStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
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
    );
  }
}
