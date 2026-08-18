import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import '../../domain/entities/startup_profile_entity.dart';

/// Reusable Startup Profile Form widget.
///
/// Styled according to the Ethio Venture Design System tokens.
/// Features high-contrast field labels, prominent required asterisks,
/// and clean white input cards.
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
    required String hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      hintStyle: const TextStyle(
        color: AppColors.slate,
        fontSize: 14,
      ),
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
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildFieldLabel(String labelText) {
    final cleanLabel = labelText.replaceAll(' *', '');
    final isRequired = labelText.contains('*');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: RichText(
        text: TextSpan(
          text: cleanLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Startup Name
          _buildFieldLabel('Startup Name *'),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Startup name'),
            decoration: _buildInputDecoration(
              hintText: 'e.g. EthioPay Solutions',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Startup Description
          _buildFieldLabel('Startup Description *'),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Description'),
            decoration: _buildInputDecoration(
              hintText: 'Describe your vision, product, and target market...',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Industry Sector Dropdown
          _buildFieldLabel('Industry Sector *'),
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            dropdownColor: AppColors.white,
            iconEnabledColor: AppColors.emerald,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            items: _industries
                .map((ind) => DropdownMenuItem(
                      value: ind,
                      child: Text(
                        ind,
                        style: const TextStyle(color: AppColors.ink),
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedIndustry = val);
            },
            decoration: _buildInputDecoration(
              hintText: 'Select industry',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Stage Dropdown
          _buildFieldLabel('Funding Stage *'),
          DropdownButtonFormField<String>(
            initialValue: _selectedFundingStage,
            dropdownColor: AppColors.white,
            iconEnabledColor: AppColors.emerald,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            items: _fundingStages
                .map((stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(
                        stage,
                        style: const TextStyle(color: AppColors.ink),
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFundingStage = val);
            },
            decoration: _buildInputDecoration(
              hintText: 'Select funding stage',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Amount Needed
          _buildFieldLabel('Funding Amount Needed (USD) *'),
          TextFormField(
            controller: _fundingAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) =>
                InputValidators.positiveAmount(v, field: 'Funding amount'),
            decoration: _buildInputDecoration(
              hintText: '50000.00',
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Location
          _buildFieldLabel('Location *'),
          TextFormField(
            controller: _locationController,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) => InputValidators.notEmpty(v, field: 'Location'),
            decoration: _buildInputDecoration(
              hintText: 'e.g. Addis Ababa, Ethiopia',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Team Information
          _buildFieldLabel('Team Information *'),
          TextFormField(
            controller: _teamController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) =>
                InputValidators.notEmpty(v, field: 'Team information'),
            decoration: _buildInputDecoration(
              hintText: 'Overview of founders, key roles, and skills...',
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Contact Information
          _buildFieldLabel('Contact Information *'),
          TextFormField(
            controller: _contactController,
            style: const TextStyle(color: AppColors.ink, fontSize: 15),
            validator: (v) =>
                InputValidators.notEmpty(v, field: 'Contact information'),
            decoration: _buildInputDecoration(
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
