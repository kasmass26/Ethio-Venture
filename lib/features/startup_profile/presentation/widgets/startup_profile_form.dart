import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import '../../domain/entities/startup_profile_entity.dart';

/// Reusable Startup Profile Form widget.
///
/// Styled according to the Ethio Venture Design System tokens.
/// Features high-contrast field labels, prominent required asterisks,
/// clean card grouping, and input validation.
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
  late final TextEditingController _websiteController;

  String _selectedIndustry = 'Fintech';
  String _selectedFundingStage = 'Seed';

  static const List<String> _industries = [
    'Fintech',
    'AgriTech',
    'HealthTech',
    'EduTech',
    'CleanTech',
    'Logistics',
    'E-commerce',
    'AI & Data',
    'SaaS',
    'Hardware & IoT',
    'Other',
  ];

  static const List<String> _fundingStages = [
    'Idea',
    'MVP',
    'Early Stage',
    'Pre-Seed',
    'Seed',
    'Series A',
    'Series B',
    'Series C',
    'Series D',
    'Growth',
  ];

  List<String> get _availableIndustries {
    final list = List<String>.from(_industries);
    if (_selectedIndustry.isNotEmpty && !list.contains(_selectedIndustry)) {
      list.add(_selectedIndustry);
    }
    return list;
  }

  List<String> get _availableFundingStages {
    final list = List<String>.from(_fundingStages);
    if (_selectedFundingStage.isNotEmpty && !list.contains(_selectedFundingStage)) {
      list.add(_selectedFundingStage);
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    final userEmail = sl<SupabaseClient>().auth.currentUser?.email ?? '';

    _nameController = TextEditingController(text: p?.startupName ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _fundingAmountController = TextEditingController(
      text: p != null && p.fundingAmountNeeded > 0
          ? p.fundingAmountNeeded.toStringAsFixed(2)
          : '',
    );
    _locationController = TextEditingController(
      text: p?.location.isNotEmpty == true
          ? p!.location
          : 'Addis Ababa, Ethiopia',
    );
    _teamController = TextEditingController(text: p?.teamInformation ?? '');
    _contactController = TextEditingController(
      text: (p?.contactInformation.trim().isNotEmpty == true)
          ? p!.contactInformation
          : userEmail,
    );
    _websiteController = TextEditingController(
      text: p?.websiteUrl ?? '',
    );

    if (p != null && p.industry.isNotEmpty) {
      _selectedIndustry = p.industry;
    }
    if (p != null && p.fundingStage.isNotEmpty) {
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
    _websiteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount =
          double.tryParse(
            _fundingAmountController.text.replaceAll(',', '').trim(),
          ) ??
          0.0;

      String website = _websiteController.text.trim();
      if (website.isNotEmpty &&
          !website.startsWith('http://') &&
          !website.startsWith('https://')) {
        website = 'https://$website';
      }

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
        websiteUrl: website,
        createdAt: widget.initialProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(profile);
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: AppColors.slate)
          : null,
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
      hintStyle: const TextStyle(color: AppColors.slate, fontSize: 14),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: AppSizes.md),
          ...children,
        ],
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
            fontSize: 14.5,
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
          // ── Section 1: Core Details ──────────────────────────────────────
          _buildSectionCard(
            title: 'General Information',
            subtitle: 'Core details about your startup entity',
            icon: Icons.rocket_launch_rounded,
            children: [
              // Startup Name
              _buildFieldLabel('Startup Name *'),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                validator: (v) =>
                    InputValidators.notEmpty(v, field: 'Startup name'),
                decoration: _buildInputDecoration(
                  hintText: 'e.g. EthioPay Solutions',
                  prefixIcon: Icons.business_rounded,
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
                  hintText: 'Describe your value proposition, target market, and vision...',
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Industry Sector Dropdown
              _buildFieldLabel('Industry Sector *'),
              DropdownButtonFormField<String>(
                initialValue: _availableIndustries.contains(_selectedIndustry)
                    ? _selectedIndustry
                    : _availableIndustries.first,
                dropdownColor: AppColors.white,
                iconEnabledColor: AppColors.primary,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                items: _availableIndustries
                    .map(
                      (ind) => DropdownMenuItem(
                        value: ind,
                        child: Text(
                          ind,
                          style: const TextStyle(color: AppColors.ink),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIndustry = val);
                },
                decoration: _buildInputDecoration(
                  hintText: 'Select industry',
                  prefixIcon: Icons.category_rounded,
                ),
              ),
            ],
          ),

          // ── Section 2: Funding & Location ─────────────────────────────────
          _buildSectionCard(
            title: 'Funding & Location',
            subtitle: 'Capital requirements and operating location',
            icon: Icons.account_balance_wallet_rounded,
            children: [
              // Funding Stage Dropdown
              _buildFieldLabel('Funding Stage *'),
              DropdownButtonFormField<String>(
                initialValue: _availableFundingStages.contains(_selectedFundingStage)
                    ? _selectedFundingStage
                    : _availableFundingStages.first,
                dropdownColor: AppColors.white,
                iconEnabledColor: AppColors.primary,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                items: _availableFundingStages
                    .map(
                      (stage) => DropdownMenuItem(
                        value: stage,
                        child: Text(
                          stage,
                          style: const TextStyle(color: AppColors.ink),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFundingStage = val);
                },
                decoration: _buildInputDecoration(
                  hintText: 'Select funding stage',
                  prefixIcon: Icons.trending_up_rounded,
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
                  hintText: 'e.g. 100000.00',
                  prefixText: '\$ ',
                  prefixIcon: Icons.attach_money_rounded,
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Location
              _buildFieldLabel('Headquarters / City *'),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                validator: (v) => InputValidators.notEmpty(v, field: 'Location'),
                decoration: _buildInputDecoration(
                  hintText: 'e.g. Addis Ababa, Ethiopia',
                  prefixIcon: Icons.location_on_rounded,
                ),
              ),
            ],
          ),

          // ── Section 3: Online Presence & Team ─────────────────────────────
          _buildSectionCard(
            title: 'Web/App Link & Team',
            subtitle: 'Showcase your website or app and team composition',
            icon: Icons.language_rounded,
            children: [
              // Website / Mobile App URL (Optional / New requirement)
              _buildFieldLabel('Website or App URL'),
              TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                decoration: _buildInputDecoration(
                  hintText: 'e.g. https://www.mystartup.com or App Store link',
                  prefixIcon: Icons.link_rounded,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              const Text(
                'Provide your website, web app, or mobile app store link so investors can explore live products.',
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(height: AppSizes.md),

              // Team Information
              _buildFieldLabel('Team Overview & Key Roles *'),
              TextFormField(
                controller: _teamController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                validator: (v) =>
                    InputValidators.notEmpty(v, field: 'Team information'),
                decoration: _buildInputDecoration(
                  hintText: 'Founders, background, key engineers, advisor credentials...',
                ),
              ),
            ],
          ),

          // ── Section 4: Contact ───────────────────────────────────────────
          _buildSectionCard(
            title: 'Contact Details',
            subtitle: 'Direct contact info for interested investors',
            icon: Icons.contact_mail_rounded,
            children: [
              Builder(
                builder: (context) {
                  final userEmail =
                      sl<SupabaseClient>().auth.currentUser?.email ?? '';
                  if (userEmail.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Signed-in Account Email:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildFieldLabel('Contact Information *'),
              TextFormField(
                controller: _contactController,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                validator: (v) =>
                    InputValidators.notEmpty(v, field: 'Contact information'),
                decoration: _buildInputDecoration(
                  hintText: 'e.g. founder@startup.com / +251 91 123 4567',
                  prefixIcon: Icons.email_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.md),

          // Submit Button
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(54),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}
