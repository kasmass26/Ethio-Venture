import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_validators.dart';
import '../../domain/entities/startup_profile_entity.dart';
import '../cubit/startup_profile_cubit.dart';
import '../cubit/startup_profile_state.dart';

class CreateStartupProfilePage extends StatefulWidget {
  const CreateStartupProfilePage({super.key});

  @override
  State<CreateStartupProfilePage> createState() =>
      _CreateStartupProfilePageState();
}

class _CreateStartupProfilePageState extends State<CreateStartupProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _founderNameController = TextEditingController();
  final _founderEmailController = TextEditingController();
  final _founderRoleController = TextEditingController(text: 'Founder & CEO');

  String _selectedIndustry = 'FinTech';
  String _selectedStage = 'Seed';

  final List<String> _industries = [
    'FinTech',
    'AgriTech',
    'HealthTech',
    'EdTech',
    'AI / ML',
    'E-commerce',
    'Renewable Energy',
  ];

  final List<String> _stages = [
    'Pre-seed',
    'Seed',
    'Series A',
    'Series B',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _targetAmountController.dispose();
    _founderNameController.dispose();
    _founderEmailController.dispose();
    _founderRoleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newProfile = StartupProfileEntity(
        id: 'st_${DateTime.now().millisecondsSinceEpoch}',
        companyName: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
        description: _descController.text.trim(),
        industry: _selectedIndustry,
        fundingStage: _selectedStage,
        targetFundingAmount: double.parse(_targetAmountController.text.trim()),
        raisedFundingAmount: 0.0,
        companyValuation:
            double.parse(_targetAmountController.text.trim()) * 5,
        monthlyBurnRate: 15000.0,
        monthlyRevenue: 0.0,
        location: _locationController.text.trim(),
        websiteUrl: _websiteController.text.trim(),
        logoUrl: '',
        founderName: _founderNameController.text.trim(),
        founderEmail: _founderEmailController.text.trim(),
        founderRole: _founderRoleController.text.trim(),
        teamMembers: const [],
        documents: const [],
        updatedAt: DateTime.now(),
      );

      context.read<StartupProfileCubit>().createProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Startup Profile'),
      ),
      body: SafeArea(
        child: BlocConsumer<StartupProfileCubit, StartupProfileState>(
          listener: (context, state) {
            if (state is StartupProfileLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Startup profile created successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            } else if (state is StartupProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is StartupProfileCreating;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Startup Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Startup Name *
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Startup Name *',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                      validator: (v) =>
                          InputValidators.notEmpty(v, field: 'Startup name'),
                    ),
                    const SizedBox(height: 12),

                    // Tagline
                    TextFormField(
                      controller: _taglineController,
                      decoration: const InputDecoration(
                        labelText: 'Tagline',
                        prefixIcon: Icon(Icons.subtitles_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description *
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: Icon(Icons.description_rounded),
                      ),
                      validator: (v) =>
                          InputValidators.notEmpty(v, field: 'Description'),
                    ),
                    const SizedBox(height: 12),

                    // Industry & Stage Dropdowns *
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedIndustry,
                            decoration:
                                const InputDecoration(labelText: 'Industry *'),
                            items: _industries
                                .map((ind) => DropdownMenuItem(
                                    value: ind, child: Text(ind)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedIndustry = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStage,
                            decoration: const InputDecoration(
                                labelText: 'Funding Stage *'),
                            items: _stages
                                .map((stg) => DropdownMenuItem(
                                    value: stg, child: Text(stg)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStage = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Target Funding Amount Needed *
                    TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Funding Amount Needed (\$) *',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (v) => InputValidators.positiveNumber(v,
                          field: 'Funding amount needed'),
                    ),
                    const SizedBox(height: 12),

                    // Location *
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                      validator: (v) =>
                          InputValidators.notEmpty(v, field: 'Location'),
                    ),
                    const SizedBox(height: 12),

                    // Website URL
                    TextFormField(
                      controller: _websiteController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Website URL',
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Founder & Contact Information Section *
                    Text(
                      'Founder & Contact Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Founder Name *
                    TextFormField(
                      controller: _founderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Founder Name *',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (v) =>
                          InputValidators.notEmpty(v, field: 'Founder name'),
                    ),
                    const SizedBox(height: 12),

                    // Founder Email *
                    TextFormField(
                      controller: _founderEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Founder Email *',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      validator: (v) => InputValidators.email(v),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Create Profile',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
