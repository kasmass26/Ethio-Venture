import '../../domain/entities/investor_discovery_entity.dart';

class InvestorDiscoveryModel extends InvestorDiscoveryEntity {
  const InvestorDiscoveryModel({
    required super.id,
    required super.userId,
    required super.investorType,
    super.organizationName,
    super.fullName,
    super.email,
    super.bio,
    super.preferredIndustries,
    super.preferredStages,
    super.ticketSizeMin,
    super.ticketSizeMax,
    super.geographicFocus,
    super.approvalStatus,
    required super.createdAt,
    super.matchScore,
    super.matchReasons,
    super.isSaved,
  });

  factory InvestorDiscoveryModel.fromJson(Map<String, dynamic> json) {
    String? fullName;
    String? email;
    if (json['users'] != null && json['users'] is Map) {
      final userMap = json['users'] as Map<String, dynamic>;
      fullName = userMap['full_name'] as String?;
      email = userMap['email'] as String?;
    }

    return InvestorDiscoveryModel(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      investorType: (json['investor_type'] as String?) ?? 'angel',
      organizationName: json['organization_name'] as String?,
      fullName: fullName,
      email: email,
      bio: json['bio'] as String?,
      preferredIndustries: _parseStringList(json['preferred_industries']),
      preferredStages: _parseStringList(json['preferred_stages']),
      ticketSizeMin: _parseDouble(json['ticket_size_min']),
      ticketSizeMax: _parseDouble(json['ticket_size_max']),
      geographicFocus: _parseStringList(json['geographic_focus']),
      approvalStatus: (json['approval_status'] as String?) ?? 'approved',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      if (value.startsWith('[') && value.endsWith(']')) {
        final inner = value.substring(1, value.length - 1);
        return inner
            .split(',')
            .map((s) => s.replaceAll('"', '').replaceAll("'", '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [value];
    }
    return const [];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
