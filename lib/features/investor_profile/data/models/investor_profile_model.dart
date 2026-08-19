import '../../domain/entities/investor_profile_entity.dart';

class InvestorProfileModel extends InvestorProfileEntity {
  const InvestorProfileModel({
    required super.id,
    required super.userId,
    required super.investorType,
    super.organizationName,
    super.bio,
    super.preferredIndustries,
    super.preferredStages,
    super.ticketSizeMin,
    super.ticketSizeMax,
    super.geographicFocus,
    required super.createdAt,
  });

  factory InvestorProfileModel.fromJson(Map<String, dynamic> json) {
    return InvestorProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      investorType: json['investor_type'] as String,
      organizationName: json['organization_name'] as String?,
      bio: json['bio'] as String?,
      preferredIndustries: _parseStringList(json['preferred_industries']),
      preferredStages: _parseStringList(json['preferred_stages']),
      ticketSizeMin: _parseDouble(json['ticket_size_min']),
      ticketSizeMax: _parseDouble(json['ticket_size_max']),
      geographicFocus: _parseStringList(json['geographic_focus']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'investor_type': investorType,
      'organization_name': organizationName,
      'bio': bio,
      'preferred_industries': preferredIndustries,
      'preferred_stages': preferredStages,
      'ticket_size_min': ticketSizeMin,
      'ticket_size_max': ticketSizeMax,
      'geographic_focus': geographicFocus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is List) {
      return value.map((item) => item as String).toList();
    }

    return const [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      return double.parse(value);
    }

    return null;
  }
}
