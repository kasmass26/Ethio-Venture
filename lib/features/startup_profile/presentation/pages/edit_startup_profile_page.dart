import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../cubit/startup_profile_cubit.dart';

class EditStartupProfilePage extends StatefulWidget {
  final StartupProfileEntity profile;

  const EditStartupProfilePage({super.key, required this.profile});

  @override
  State<EditStartupProfilePage> createState() => _EditStartupProfilePageState();
}

class _EditStartupProfilePageState extends State<EditStartupProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _taglineController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _targetAmountController;
  late TextEditingController _raisedAmountController;
  late TextEditingController _valuationController;
  late TextEditingController _burnRateController;
  late TextEditingController _revenueController;
  late TextEditingController _founderNameController;

  late String _selectedIndustry;
  late String _selectedStage;

  final List<String> _industries = [
    'FinTech',
    'AgriTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'E-commerce',
    'Renewable Energy',
  ];

  final List<String> _stages = ['Pre-seed', 'Seed', 'Series A', 'Series B'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.companyName);
    _taglineController = TextEditingController(text: p.tagline);
    _descController = TextEditingController(text: p.description);
    _locationController = TextEditingController(text: p.location);
    _websiteController = TextEditingController(text: p.websiteUrl);
    _targetAmountController = TextEditingController(
      text: p.targetFundingAmount.toStringAsFixed(0),
    );
    _raisedAmountController = TextEditingController(
      text: p.raisedFundingAmount.toStringAsFixed(0),
    );
    _valuationController = TextEditingController(
      text: p.companyValuation.toStringAsFixed(0),
    );
    _burnRateController = TextEditingController(
      text: p.monthlyBurnRate.toStringAsFixed(0),
    );
    _revenueController = TextEditingController(
      text: p.monthlyRevenue.toStringAsFixed(0),
    );
    _founderNameController = TextEditingController(text: p.founderName);

    _selectedIndustry = p.industry;
    _selectedStage = p.fundingStage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _targetAmountController.dispose();
    _raisedAmountController.dispose();
    _valuationController.dispose();
    _burnRateController.dispose();
    _revenueController.dispose();
    _founderNameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.profile.copyWith(
        companyName: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
        description: _descController.text.trim(),
        industry: _selectedIndustry,
        fundingStage: _selectedStage,
        location: _locationController.text.trim(),
        websiteUrl: _websiteController.text.trim(),
        founderName: _founderNameController.text.trim(),
        targetFundingAmount:
            double.tryParse(_targetAmountController.text) ?? 0.0,
        raisedFundingAmount:
            double.tryParse(_raisedAmountController.text) ?? 0.0,
        companyValuation: double.tryParse(_valuationController.text) ?? 0.0,
        monthlyBurnRate: double.tryParse(_burnRateController.text) ?? 0.0,
        monthlyRevenue: double.tryParse(_revenueController.text) ?? 0.0,
      );

      context.read<StartupProfileCubit>().updateProfile(updated);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Startup Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter company name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _taglineController,
                  decoration: const InputDecoration(labelText: 'Tagline'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedIndustry,
                        decoration: const InputDecoration(
                          labelText: 'Industry',
                        ),
                        items: _industries
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedIndustry = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStage,
                        decoration: const InputDecoration(
                          labelText: 'Funding Stage',
                        ),
                        items: _stages
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedStage = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(labelText: 'Website URL'),
                ),
                const SizedBox(height: 24),

                Text(
                  'Financial & Valuation Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target Funding (\$)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _raisedAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Raised Funding (\$)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valuationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valuation (\$)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _burnRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Burn (\$)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _revenueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Revenue / MRR (\$)',
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Founder Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _founderNameController,
                  decoration: const InputDecoration(labelText: 'Founder Name'),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Profile Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
