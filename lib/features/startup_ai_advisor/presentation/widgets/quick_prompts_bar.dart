import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ai_advisor_mode.dart';

class QuickPromptsBar extends StatelessWidget {
  const QuickPromptsBar({
    super.key,
    required this.config,
    required this.activeCategory,
    required this.onCategoryChanged,
    required this.onPromptSelected,
  });

  final AdvisorModeConfig config;
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final filteredPresets = config.presets.where((p) {
      if (activeCategory == 'All') return true;
      return p.category == activeCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Pills
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: config.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = config.categories[index];
              final isSelected = cat == activeCategory;

              return InkWell(
                onTap: () => onCategoryChanged(cat),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? config.primaryColor
                        : config.softColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? config.primaryColor
                          : config.primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : config.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Preset Cards Carousel
        SizedBox(
          height: 94,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filteredPresets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = filteredPresets[index];

              return InkWell(
                onTap: () => onPromptSelected(preset.prompt),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.primaryColor.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: config.primaryColor.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: config.softColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(preset.icon,
                                size: 14, color: config.primaryColor),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: config.primaryColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      Text(
                        preset.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
