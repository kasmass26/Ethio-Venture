import 'package:flutter/material.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import '../../domain/entities/startup_profile_entity.dart';

/// Reusable Startup Profile Form widget.
///
/// Used for both creating a new profile and editing an existing one.
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
    _locationController = TextEditingController(text: p?.location ?? 'Addis Ababa, Ethiopia');
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Startup Name
          Text(
            'Startup Name *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _nameController,
            validator: (v) => InputValidators.notEmpty(v, field: 'Startup name'),
            decoration: InputDecoration(
              hintText: 'e.g. EthioPay Solutions',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Description
          Text(
            'Startup Description *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            validator: (v) => InputValidators.notEmpty(v, field: 'Description'),
            decoration: InputDecoration(
              hintText: 'Describe your vision, product, and target market...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Industry Dropdown
          Text(
            'Industry Sector *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            initialValue: _selectedIndustry,
            items: _industries
                .map((ind) => DropdownMenuItem(value: ind, child: Text(ind)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedIndustry = val);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Stage Dropdown
          Text(
            'Funding Stage *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          DropdownButtonFormField<String>(
            initialValue: _selectedFundingStage,
            items: _fundingStages
                .map((stage) => DropdownMenuItem(value: stage, child: Text(stage)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFundingStage = val);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Funding Amount Needed
          Text(
            'Funding Amount Needed (USD) *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _fundingAmountController,
            keyboardType: TextInputType.number,
            validator: (v) => InputValidators.positiveAmount(v, field: 'Funding amount'),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'e.g. 50000.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Location
          Text(
            'Location *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _locationController,
            validator: (v) => InputValidators.notEmpty(v, field: 'Location'),
            decoration: InputDecoration(
              hintText: 'e.g. Addis Ababa, Ethiopia',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Team Information
          Text(
            'Team Information *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _teamController,
            maxLines: 3,
            validator: (v) => InputValidators.notEmpty(v, field: 'Team information'),
            decoration: InputDecoration(
              hintText: 'Overview of founders, key roles, and skills...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Contact Information
          Text(
            'Contact Information *',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
          ),
          const SizedBox(height: AppSizes.xs),
          TextFormField(
            controller: _contactController,
            validator: (v) => InputValidators.notEmpty(v, field: 'Contact information'),
            decoration: InputDecoration(
              hintText: 'e.g. founder@startup.com / +251 91 234 5678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Submit Button
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
            ),
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
