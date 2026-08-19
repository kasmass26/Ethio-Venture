import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/industry_selector.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/stage_selector.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_filter.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for startup discovery filters.
///
/// Exposes all [StartupFilter] criteria except [query] (the search bar lives
/// on the main page). Multiple criteria can be set simultaneously.
///
/// Calls [onApply] with the new filter when the user taps "Apply Filters".
/// Calls [onClear] when the user taps "Clear All".
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => StartupFilterSheet(
///     currentFilter: cubit.currentFilter,
///     onApply: (f) => cubit.applyFilters(...),
///     onClear: cubit.clearFilters,
///   ),
/// );
/// ```
class StartupFilterSheet extends StatefulWidget {
  const StartupFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  final StartupFilter currentFilter;
  final void Function(StartupFilterSheetResult result) onApply;
  final VoidCallback onClear;

  @override
  State<StartupFilterSheet> createState() => _StartupFilterSheetState();
}

class _StartupFilterSheetState extends State<StartupFilterSheet> {
  late String? _industry;
  late String? _stage;
  late final TextEditingController _locationController;
  late final TextEditingController _minFundingController;
  late final TextEditingController _maxFundingController;

  String? _fundingError;

  @override
  void initState() {
    super.initState();
    final f = widget.currentFilter;
    _industry = f.industry;
    _stage = f.stage;
    _locationController = TextEditingController(text: f.location ?? '');
    _minFundingController = TextEditingController(
      text: f.minFundingTarget != null
          ? f.minFundingTarget!.toStringAsFixed(0)
          : '',
    );
    _maxFundingController = TextEditingController(
      text: f.maxFundingTarget != null
          ? f.maxFundingTarget!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minFundingController.dispose();
    _maxFundingController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _industry != null ||
      _stage != null ||
      _locationController.text.trim().isNotEmpty ||
      _minFundingController.text.trim().isNotEmpty ||
      _maxFundingController.text.trim().isNotEmpty;

  void _validate() {
    final min = double.tryParse(
      _minFundingController.text.replaceAll(',', '').trim(),
    );
    final max = double.tryParse(
      _maxFundingController.text.replaceAll(',', '').trim(),
    );
    if (min != null && max != null && max < min) {
      setState(() => _fundingError = 'Max must be ≥ Min');
      return;
    }
    setState(() => _fundingError = null);

    widget.onApply(
      StartupFilterSheetResult(
        industry: _industry,
        stage: _stage,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        minFundingTarget: min,
        maxFundingTarget: max,
      ),
    );
    Navigator.of(context).pop();
  }

  void _clearAll() {
    widget.onClear();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────
          const SizedBox(height: AppSizes.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Startups',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.secondary,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          const Divider(height: AppSizes.lg),

          // ── Scrollable body ─────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSizes.lg,
                right: AppSizes.lg,
                bottom: mediaQuery.viewInsets.bottom + AppSizes.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Industry ───────────────────────────────────────────────
                  _SectionLabel('Industry'),
                  const SizedBox(height: AppSizes.sm),
                  // Single-select: tapping again deselects.
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: IndustrySelector.availableIndustries.map((i) {
                      final selected = _industry == i;
                      return FilterChip(
                        label: Text(i),
                        selected: selected,
                        checkmarkColor: Colors.white,
                        selectedColor:
                            isDark ? AppColors.primary : AppColors.secondary,
                        labelStyle: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? (isDark ? AppColors.secondary : Colors.white)
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                        backgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceVariant,
                        side: BorderSide(
                          color: selected
                              ? Colors.transparent
                              : (isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXl),
                        ),
                        onSelected: (_) => setState(
                          () => _industry = selected ? null : i,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Funding Stage ──────────────────────────────────────────
                  _SectionLabel('Funding Stage'),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: StageSelector.availableStages.map((s) {
                      final selected = _stage == s;
                      return FilterChip(
                        label: Text(s),
                        selected: selected,
                        checkmarkColor: Colors.white,
                        selectedColor:
                            isDark ? AppColors.primary : AppColors.secondary,
                        labelStyle: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? (isDark ? AppColors.secondary : Colors.white)
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                        backgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceVariant,
                        side: BorderSide(
                          color: selected
                              ? Colors.transparent
                              : (isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusXl),
                        ),
                        onSelected: (_) => setState(
                          () => _stage = selected ? null : s,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Location ───────────────────────────────────────────────
                  _SectionLabel('Location'),
                  const SizedBox(height: AppSizes.sm),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Addis Ababa',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Funding Range ──────────────────────────────────────────
                  _SectionLabel('Funding Target (USD)'),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minFundingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            prefixText: '\$ ',
                          ),
                          onChanged: (_) =>
                              setState(() => _fundingError = null),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        child: Text('–'),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _maxFundingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            prefixText: '\$ ',
                          ),
                          onChanged: (_) =>
                              setState(() => _fundingError = null),
                        ),
                      ),
                    ],
                  ),
                  if (_fundingError != null) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      _fundingError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),

                  // Apply button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _validate,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result object returned to the page ────────────────────────────────────

/// Carries the selected filter values from [StartupFilterSheet] to the caller.
class StartupFilterSheetResult {
  const StartupFilterSheetResult({
    this.industry,
    this.stage,
    this.location,
    this.minFundingTarget,
    this.maxFundingTarget,
  });

  final String? industry;
  final String? stage;
  final String? location;
  final double? minFundingTarget;
  final double? maxFundingTarget;
}

// ── Private section label helper ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.secondary,
          ),
    );
  }
}
