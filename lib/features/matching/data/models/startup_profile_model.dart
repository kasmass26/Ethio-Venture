import '../../domain/entities/startup_profile_entity.dart';

/// JSON ↔ domain mapping for the `startup_profiles` Supabase table.
class StartupProfileModel extends StartupProfileEntity {
  const StartupProfileModel({
    required super.id,
    required super.userId,
    required super.businessName,
    super.description,
    super.industry,
    super.fundingStage,
    super.location,
    super.fundingAmountSought,
  });

  factory StartupProfileModel.fromJson(Map<String, dynamic> json) {
    // Prefer business_name; fall back to startup_name if present.
    final name = json['business_name']?.toString().isNotEmpty == true
        ? json['business_name'].toString()
        : (json['startup_name']?.toString() ?? 'Unnamed Startup');

    // Prefer funding_amount_sought; fall back to funding_amount_needed.
    final amount = _toDouble(json['funding_amount_sought']) ??
        _toDouble(json['funding_amount_needed']);

    return StartupProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      businessName: name,
      description: json['description']?.toString(),
      industry: json['industry']?.toString(),
      fundingStage: json['funding_stage']?.toString(),
      location: json['location']?.toString(),
      fundingAmountSought: amount,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
