import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';

class StartupSelectionBottomSheet extends StatefulWidget {
  const StartupSelectionBottomSheet({
    super.key,
    required this.startups,
    required this.selectedStartup,
    required this.onSelected,
    required this.primaryColor,
  });

  final List<StartupProfileEntity> startups;
  final StartupProfileEntity? selectedStartup;
  final ValueChanged<StartupProfileEntity?> onSelected;
  final Color primaryColor;

  static void show(
    BuildContext context, {
    required List<StartupProfileEntity> startups,
    required StartupProfileEntity? selectedStartup,
    required ValueChanged<StartupProfileEntity?> onSelected,
    required Color primaryColor,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StartupSelectionBottomSheet(
        startups: startups,
        selectedStartup: selectedStartup,
        onSelected: onSelected,
        primaryColor: primaryColor,
      ),
    );
  }

  @override
  State<StartupSelectionBottomSheet> createState() =>
      _StartupSelectionBottomSheetState();
}

class _StartupSelectionBottomSheetState
    extends State<StartupSelectionBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.startups.where((s) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.startupName.toLowerCase().contains(q) ||
          s.industry.toLowerCase().contains(q) ||
          s.fundingStage.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Startup Context',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'The AI will tailor all advice and due diligence to this company.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by startup name or sector...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),

          // Option to clear / general query
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: widget.selectedStartup == null
                      ? widget.primaryColor
                      : AppColors.border,
                ),
              ),
              tileColor: widget.selectedStartup == null
                  ? widget.primaryColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hub_rounded, size: 18, color: widget.primaryColor),
              ),
              title: const Text(
                'No specific startup (General Mode)',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Ask broad market, ecosystem, or venture strategy questions',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              trailing: widget.selectedStartup == null
                  ? Icon(Icons.check_circle_rounded, color: widget.primaryColor, size: 20)
                  : null,
              onTap: () {
                widget.onSelected(null);
                Navigator.pop(context);
              },
            ),
          ),

          const Divider(height: 16),

          // Startup list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching startups found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final startup = filtered[index];
                      final isSelected = widget.selectedStartup?.id == startup.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.primaryColor.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? widget.primaryColor : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            widget.onSelected(startup);
                            Navigator.pop(context);
                          },
                          leading: CircleAvatar(
                            backgroundColor: widget.primaryColor.withValues(alpha: 0.12),
                            child: Text(
                              startup.startupName.isNotEmpty
                                  ? startup.startupName[0].toUpperCase()
                                  : 'S',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: widget.primaryColor,
                              ),
                            ),
                          ),
                          title: Text(
                            startup.startupName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                          subtitle: Text(
                            '${startup.industry} · ${startup.fundingStage} · \$${startup.fundingAmountNeeded.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded,
                                  color: widget.primaryColor, size: 20)
                              : const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.border),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
