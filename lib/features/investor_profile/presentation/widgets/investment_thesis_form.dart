import 'package:ethioventure/core/theme/app_colors.dart';
import 'package:ethioventure/core/theme/app_sizes.dart';
import 'package:ethioventure/core/utils/input_validators.dart';
import 'package:ethioventure/features/investor_profile/domain/entities/investor_profile_entity.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/industry_selector.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/section_card.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/stage_selector.dart';
import 'package:ethioventure/features/investor_profile/presentation/widgets/ticket_size_inputs.dart';
import 'package:flutter/material.dart';

/// Modern form encapsulating the "Investment Thesis Setup & Edit" interface.
class InvestmentThesisForm extends StatefulWidget {
  const InvestmentThesisForm({
    super.key,
    this.initialProfile,
    required this.onSaveDraft,
    required this.onCompleteProfile,
    this.isSaving = false,
  });

  final InvestorProfileEntity? initialProfile;
  final ValueChanged<InvestorProfileEntity> onSaveDraft;
  final ValueChanged<InvestorProfileEntity> onCompleteProfile;
  final bool isSaving;

  @override
  State<InvestmentThesisForm> createState() => _InvestmentThesisFormState();
}

class _InvestmentThesisFormState extends State<InvestmentThesisForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _orgNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _ticketMinController;
  late final TextEditingController _ticketMaxController;

  late Set<String> _selectedIndustries;
  late Set<String> _selectedStages;

  String? _industryError;
  String? _stageError;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _orgNameController =
        TextEditingController(text: profile?.organizationName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _ticketMinController = TextEditingController(
      text: profile?.ticketSizeMin != null
          ? profile!.ticketSizeMin!.toStringAsFixed(0)
          : '',
    );
    _ticketMaxController = TextEditingController(
      text: profile?.ticketSizeMax != null
          ? profile!.ticketSizeMax!.toStringAsFixed(0)
          : '',
    );
    _selectedIndustries = Set<String>.from(profile?.preferredIndustries ?? []);
    _selectedStages = Set<String>.from(profile?.preferredStages ?? []);
  }

  @override
  void didUpdateWidget(covariant InvestmentThesisForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile &&
        widget.initialProfile != null) {
      final profile = widget.initialProfile!;
      _orgNameController.text = profile.organizationName ?? '';
      _bioController.text = profile.bio ?? '';
      _ticketMinController.text = profile.ticketSizeMin != null
          ? profile.ticketSizeMin!.toStringAsFixed(0)
          : '';
      _ticketMaxController.text = profile.ticketSizeMax != null
          ? profile.ticketSizeMax!.toStringAsFixed(0)
          : '';
      setState(() {
        _selectedIndustries = Set<String>.from(profile.preferredIndustries);
        _selectedStages = Set<String>.from(profile.preferredStages);
      });
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _bioController.dispose();
    _ticketMinController.dispose();
    _ticketMaxController.dispose();
    super.dispose();
  }

  InvestorProfileEntity _buildEntity() {
    final existing = widget.initialProfile;
    final minAmount = double.tryParse(
      _ticketMinController.text.replaceAll(',', '').trim(),
    );
    final maxAmount = double.tryParse(
      _ticketMaxController.text.replaceAll(',', '').trim(),
    );

    return InvestorProfileEntity(
      id: existing?.id ?? '',
      userId: existing?.userId ?? '',
      investorType: existing?.investorType ?? 'firm',
      organizationName: _orgNameController.text.trim().isEmpty
          ? null
          : _orgNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      preferredIndustries: _selectedIndustries.toList(),
      preferredStages: _selectedStages.toList(),
      ticketSizeMin: minAmount,
      ticketSizeMax: maxAmount,
      geographicFocus: existing?.geographicFocus ?? const ['Ethiopia'],
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
  }

  void _handleSaveDraft() {
    widget.onSaveDraft(_buildEntity());
  }

  void _handleCompleteProfile() {
    setState(() {
      _industryError = _selectedIndustries.isEmpty
          ? 'Please select at least one preferred industry'
          : null;
      _stageError = _selectedStages.isEmpty
          ? 'Please select at least one target funding stage'
          : null;
    });

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _industryError != null || _stageError != null) {
      return;
    }

    widget.onCompleteProfile(_buildEntity());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: Organization Details
          SectionCard(
            sectionNumber: 1,
            title: 'Organization Identity & Bio',
            subtitle: 'Provide your firm name and fund overview.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _orgNameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization / Firm Name',
                    hintText: 'e.g. Addis Capital Syndicate',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (val) => InputValidators.notEmpty(
                    val,
                    field: 'Organization name',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Investment Thesis & Bio (Optional)',
                    hintText:
                        'Describe your firm, thesis, key focus sectors, and value-add for Ethiopian startups.',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: Icon(Icons.description_outlined),
                    ),
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Section 2: Preferred Industries
          SectionCard(
            sectionNumber: 2,
            title: 'Preferred Investment Sectors',
            subtitle: 'Select up to 5 industries you actively invest in.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Text(
                '${_selectedIndustries.length}/5 selected',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _selectedIndustries.length == 5
                      ? (isDark ? AppColors.primary : AppColors.secondary)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
              ),
            ),
            child: IndustrySelector(
              selectedIndustries: _selectedIndustries,
              errorText: _industryError,
              onChanged: (updated) {
                setState(() {
                  _selectedIndustries = updated;
                  if (updated.isNotEmpty) {
                    _industryError = null;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Section 3: Target Funding Stages
          SectionCard(
            sectionNumber: 3,
            title: 'Target Funding Stages',
            subtitle: 'Choose the growth stages of startups you back.',
            child: StageSelector(
              selectedStages: _selectedStages,
              errorText: _stageError,
              onChanged: (updated) {
                setState(() {
                  _selectedStages = updated;
                  if (updated.isNotEmpty) {
                    _stageError = null;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Section 4: Typical Ticket Size
          SectionCard(
            sectionNumber: 4,
            title: 'Typical Check / Ticket Size Range',
            subtitle:
                'Specify your typical minimum and maximum investment range in USD.',
            child: TicketSizeInputs(
              minController: _ticketMinController,
              maxController: _ticketMaxController,
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Actions Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 480;

              final saveDraftBtn = OutlinedButton.icon(
                onPressed: widget.isSaving ? null : _handleSaveDraft,
                icon: const Icon(Icons.bookmark_border_rounded, size: 18),
                label: const Text('Save as Draft'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
              );

              final completeProfileBtn = Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isSaving ? null : _handleCompleteProfile,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      child: widget.isSaving
                          ? const Center(
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 19, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  widget.initialProfile != null
                                      ? 'Save Changes'
                                      : 'Complete Profile',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: saveDraftBtn),
                    const SizedBox(width: AppSizes.md),
                    Expanded(flex: 2, child: completeProfileBtn),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  completeProfileBtn,
                  const SizedBox(height: AppSizes.sm),
                  saveDraftBtn,
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}
