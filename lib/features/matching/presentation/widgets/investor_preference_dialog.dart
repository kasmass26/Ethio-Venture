import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/investor_preference_entity.dart';

class InvestorPreferenceDialog extends StatefulWidget {
  final InvestorPreferenceEntity currentPreferences;
  final Function(InvestorPreferenceEntity) onSavePreferences;

  const InvestorPreferenceDialog({
    super.key,
    required this.currentPreferences,
    required this.onSavePreferences,
  });

  @override
  State<InvestorPreferenceDialog> createState() =>
      _InvestorPreferenceDialogState();
}

class _InvestorPreferenceDialogState extends State<InvestorPreferenceDialog> {
  late List<String> _preferredIndustries;
  late List<String> _preferredStages;
  late RangeValues _ticketSizeRange;

  final List<String> _allIndustries = [
    'FinTech',
    'AgriTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'E-commerce',
    'Renewable Energy',
  ];

  final List<String> _allStages = ['Pre-seed', 'Seed', 'Series A', 'Series B'];

  @override
  void initState() {
    super.initState();
    _preferredIndustries = List.from(
      widget.currentPreferences.preferredIndustries,
    );
    _preferredStages = List.from(widget.currentPreferences.preferredStages);
    _ticketSizeRange = RangeValues(
      widget.currentPreferences.minTicketSize,
      widget.currentPreferences.maxTicketSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Investor Preferences',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Preferred Industries
              Text(
                'Target Industries',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _allIndustries.map((ind) {
                  final isSelected = _preferredIndustries.contains(ind);
                  return FilterChip(
                    label: Text(ind),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _preferredIndustries.add(ind);
                        } else {
                          _preferredIndustries.remove(ind);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Preferred Stages
              Text(
                'Preferred Funding Stages',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _allStages.map((stage) {
                  final isSelected = _preferredStages.contains(stage);
                  return FilterChip(
                    label: Text(stage),
                    selected: isSelected,
                    selectedColor: AppColors.secondary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _preferredStages.add(stage);
                        } else {
                          _preferredStages.remove(stage);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Investment Ticket Size Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticket Size Range',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${(_ticketSizeRange.start / 1000).toStringAsFixed(0)}k - \$${(_ticketSizeRange.end / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _ticketSizeRange,
                min: 10000.0,
                max: 1000000.0,
                divisions: 99,
                activeColor: AppColors.primary,
                onChanged: (values) {
                  setState(() => _ticketSizeRange = values);
                },
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = widget.currentPreferences.copyWith(
                      preferredIndustries: _preferredIndustries,
                      preferredStages: _preferredStages,
                      minTicketSize: _ticketSizeRange.start,
                      maxTicketSize: _ticketSizeRange.end,
                    );
                    widget.onSavePreferences(updated);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update AI Preferences'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
