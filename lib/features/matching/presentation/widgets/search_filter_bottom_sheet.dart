import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startup_filter_params.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final StartupFilterParams currentParams;
  final Function(StartupFilterParams) onApplyFilters;
  final VoidCallback onResetFilters;

  const SearchFilterBottomSheet({
    super.key,
    required this.currentParams,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late String _selectedIndustry;
  late String _selectedStage;
  late String _selectedLocation;
  late String _selectedSort;
  late RangeValues _targetAmountRange;

  final List<String> _industries = [
    'All',
    'FinTech',
    'AgriTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'E-commerce',
    'Renewable Energy',
  ];

  final List<String> _stages = [
    'All',
    'Pre-seed',
    'Seed',
    'Series A',
    'Series B',
  ];

  final List<String> _locations = [
    'All',
    'Addis Ababa',
    'Hawassa',
    'Jimma',
    'Bahir Dar',
  ];

  final Map<String, String> _sortOptions = {
    'relevance': 'Most Relevant',
    'target_high': 'Highest Funding Target',
    'target_low': 'Lowest Funding Target',
    'progress_high': 'Highest Progress',
    'newest': 'Newest Startups',
  };

  @override
  void initState() {
    super.initState();
    _selectedIndustry = widget.currentParams.industry ?? 'All';
    _selectedStage = widget.currentParams.fundingStage ?? 'All';
    _selectedLocation = widget.currentParams.location ?? 'All';
    _selectedSort = widget.currentParams.sortBy;
    _targetAmountRange = RangeValues(
      widget.currentParams.minTargetAmount ?? 100000.0,
      widget.currentParams.maxTargetAmount ?? 5000000.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Reset Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Startups',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onResetFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // 1. Industry / Sector
            Text(
              'Industry / Sector',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _industries.map((ind) {
                final isSelected = _selectedIndustry == ind;
                return ChoiceChip(
                  label: Text(ind),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedIndustry = ind);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 2. Funding Stage
            Text(
              'Funding Stage',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _stages.map((stage) {
                final isSelected = _selectedStage == stage;
                return ChoiceChip(
                  label: Text(stage),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedStage = stage);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 3. Location
            Text(
              'Location',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations.map((loc) {
                final isSelected = _selectedLocation == loc;
                return ChoiceChip(
                  label: Text(loc),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : AppColors.textPrimary),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedLocation = loc);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 4. Target Funding Range Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target Funding Range',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${(_targetAmountRange.start / 1000).toStringAsFixed(0)}k - \$${(_targetAmountRange.end / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _targetAmountRange,
              min: 50000.0,
              max: 5000000.0,
              divisions: 99,
              activeColor: AppColors.primary,
              onChanged: (values) {
                setState(() => _targetAmountRange = values);
              },
            ),
            const SizedBox(height: 16),

            // 5. Sort By Dropdown
            Text(
              'Sort By',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSort,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _sortOptions.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSort = val);
              },
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final updatedParams = widget.currentParams.copyWith(
                    industry: _selectedIndustry == 'All'
                        ? null
                        : _selectedIndustry,
                    fundingStage: _selectedStage == 'All'
                        ? null
                        : _selectedStage,
                    location: _selectedLocation == 'All'
                        ? null
                        : _selectedLocation,
                    minTargetAmount: _targetAmountRange.start,
                    maxTargetAmount: _targetAmountRange.end,
                    sortBy: _selectedSort,
                  );
                  widget.onApplyFilters(updatedParams);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
