import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import '../../domain/entities/startup_profile_entity.dart';

/// Reusable Startup Profile Form widget.
///
/// Styled according to the Ethio Venture Design System tokens.
/// Supports both Light and Dark themes with full high-contrast readability.
class StartupProfileForm extends StatefulWidget {
  const StartupProfileForm({
    super.key,
    this.initialProfile,
    required this.userId,
    required this.onSubmit,
    required this.isSubmitting,
    required this.buttonText,
  });

  final StartupProfileEntity? initialProfile;
  final String userId;
  final void Function(StartupProfileEntity profile) onSubmit;
  final bool isSubmitting;
  final String buttonText;

  @override
  State<StartupProfileForm> createState() => _StartupProfileFormState();
}

class _StartupProfileFormState extends State<StartupProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _fundingAmountController;
  late final TextEditingController _locationController;
  late final TextEditingController _teamController;
  late final TextEditingController _contactController;

  String _selectedIndustry = 'Fintech';
  String _selectedFundingStage = 'MVP';

  static const List<String> _industries = [
    'Fintech',
    'AgriTech',
    'HealthTech',
    'EduTech',
    'CleanTech',
    'Logistics',
    'E-commerce',
    'Other',
  ];

  static const List<String> _fundingStages = [
    'Idea',
    'MVP',
    'Early Stage',
    'Seed',
    'Growth',
    'Series A',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(text: p?.startupName ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _fundingAmountController = TextEditingController(
      text: p != null ? p.fundingAmountNeeded.toStringAsFixed(2) : '',
    );
    _locationController = TextEditingController(
      text: p?.location ?? 'Addis Ababa, Ethiopia',
    );
    _teamController = TextEditingController(text: p?.teamInformation ?? '');
    _contactController = TextEditingController(text: p?.contactInformation ?? '');

    if (p != null && _industries.contains(p.industry)) {
      _selectedIndustry = p.industry;
    }
    if (p != null && _fundingStages.contains(p.fundingStage)) {
      _selectedFundingStage = p.fundingStage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _fundingAmountController.dispose();
    _locationController.dispose();
    _teamController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(
            _fundingAmountController.text.replaceAll(',', '').trim(),
          ) ??
          0.0;

      final profile = StartupProfileEntity(
        id: widget.initialProfile?.id ?? '',
        userId: widget.userId,
        startupName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        industry: _selectedIndustry,
        fundingStage: _selectedFundingStage,
        fundingAmountNeeded: amount,
        location: _locationController.text.trim(),
        teamInformation: _teamController.text.trim(),
        contactInformation: _contactController.text.trim(),
        createdAt: widget.initialProfile?.createdAt,
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(profile);
    }
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    String? prefixText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.surfaceDark : AppColors.fog;
    final borderColor = isDark ? AppColors.borderDark : AppColors.hairline;

    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      hintStyle: TextStyle(
        color: isDark ? AppColors.textSecondaryDark : AppColors.slate,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.ink;
    final dropdownBgColor = isDark ? AppColors.surfaceDark : AppColors.white;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Startup Name
          _buildFieldLabel(context, 'Startup Name *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Startup name'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'e.g. EthioPay Solutions',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Startup Description
          _buildFieldLabel(context, 'Startup Description *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Description'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'Describe your vision, product, and target market...',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Industry Sector Dropdown
          _buildFieldLabel(context, 'Industry Sector *'),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            dropdownColor: dropdownBgColor,
            style: TextStyle(color: textColor, fontSize: 15),
            items: _industries
                .map((ind) => DropdownMenuItem(
                      value: ind,
                      child: Text(ind, style: TextStyle(color: textColor)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedIndustry = val);
            },
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'Select industry',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Stage Dropdown
          _buildFieldLabel(context, 'Funding Stage *'),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            initialValue: _selectedFundingStage,
            dropdownColor: dropdownBgColor,
            style: TextStyle(color: textColor, fontSize: 15),
            items: _fundingStages
                .map((stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(stage, style: TextStyle(color: textColor)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFundingStage = val);
            },
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'Select funding stage',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Amount Needed
          _buildFieldLabel(context, 'Funding Amount Needed (USD) *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _fundingAmountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) =>
                InputValidators.positiveAmount(v, field: 'Funding amount'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: '50000.00',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Location
          _buildFieldLabel(context, 'Location *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _locationController,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Location'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'e.g. Addis Ababa, Ethiopia',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Team Information
          _buildFieldLabel(context, 'Team Information *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _teamController,
            maxLines: 3,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) =>
                InputValidators.notEmpty(v, field: 'Team information'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'Overview of founders, key roles, and skills...',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Contact Information
          _buildFieldLabel(context, 'Contact Information *'),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _contactController,
            style: TextStyle(color: textColor, fontSize: 15),
            validator: (v) =>
                InputValidators.notEmpty(v, field: 'Contact information'),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'e.g. founder@startup.com / +251 91 234 5678',
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Submit Button
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
