import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../domain/entities/pending_approval_entity.dart';

/// Modal dialog for capturing a mandatory rejection reason from an admin.
class RejectionReasonDialog extends StatefulWidget {
  final PendingApprovalEntity profile;

  const RejectionReasonDialog({
    super.key,
    required this.profile,
  });

  /// Helper to show dialog and return the non-empty rejection reason string, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required PendingApprovalEntity profile,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RejectionReasonDialog(profile: profile),
    );
  }

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  final FocusNode _focusNode = FocusNode();

  static const List<String> _presetReasons = [
    'Incomplete business profile details',
    'Pitch deck/documentation missing or invalid',
    'Funding target does not match stage criteria',
    'Unverified or invalid contact information',
    'Business model does not meet platform scope',
    'Needs clearer value proposition & team info',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectPreset(String preset) {
    setState(() {
      _reasonController.text = preset;
      _reasonController.selection = TextSelection.fromPosition(
        TextPosition(offset: preset.length),
      );
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _reasonController.text.trim();
      Navigator.of(context).pop(reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStartup = widget.profile.role == 'founder';
    final roleLabel = isStartup ? 'Startup' : 'Investor';

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reject Application',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Provide a clear reason for rejecting this $roleLabel.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                const Divider(height: 1),
                const SizedBox(height: AppSizes.md),

                // Profile Summary Banner
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm + 2),
                  decoration: BoxDecoration(
                    color: AppColors.fog,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isStartup ? Icons.business : Icons.account_balance,
                        size: 20,
                        color: isStartup ? AppColors.primary : AppColors.violet,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          widget.profile.businessName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isStartup
                              ? AppColors.primarySoft
                              : AppColors.violetTint,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isStartup
                                ? AppColors.primary
                                : AppColors.violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Quick presets
                const Text(
                  'Quick Presets:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Wrap(
                  spacing: AppSizes.xs + 2,
                  runSpacing: AppSizes.xs,
                  children: _presetReasons.map((preset) {
                    final isSelected = _reasonController.text == preset;
                    return InkWell(
                      onTap: () => _selectPreset(preset),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.fog,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSm),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.error
                                : AppColors.hairline,
                          ),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.error
                                : AppColors.slate,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.md),

                // Multi-line Reason Input
                const Text(
                  'Rejection Reason *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                TextFormField(
                  controller: _reasonController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 400,
                  style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText:
                        'Enter a detailed explanation so the applicant can correct their profile and resubmit...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.slate,
                    ),
                    filled: true,
                    fillColor: AppColors.fog,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Rejection reason is required.';
                    }
                    if (trimmed.length < 5) {
                      return 'Please provide a more descriptive reason (min 5 characters).';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),

                // Note info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 15,
                      color: AppColors.slate.withOpacity(0.8),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Expanded(
                      child: Text(
                        'This reason will be visible to the user on their dashboard so they understand why their application was rejected.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.slate.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.slate,
                          side: const BorderSide(color: AppColors.hairline),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Confirm Rejection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size.fromHeight(46),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
