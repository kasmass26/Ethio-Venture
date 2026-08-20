import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final Map<String, Color> colors;

  const ChartCard({
    super.key,
    required this.title,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<double>(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                'Total: ${total.toInt()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: AppColors.slate, fontSize: 13),
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: data.entries.map((entry) {
                    final fraction = total > 0 ? entry.value / total : 0.0;
                    if (fraction == 0) return const SizedBox.shrink();
                    return Expanded(
                      flex: (fraction * 1000).toInt(),
                      child: Container(
                        color: colors[entry.key] ?? AppColors.primary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.xs,
              children: data.entries.map((entry) {
                final count = entry.value.toInt();
                final percentage =
                    total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0';
                final color = colors[entry.key] ?? AppColors.primary;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '$count ($percentage%)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
