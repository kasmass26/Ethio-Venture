import '../../domain/entities/investor_preferences_entity.dart';

/// JSON ↔ domain mapping for the `investor_profiles` Supabase table.
///
/// Investor preferences are stored directly on investor_profiles —
/// there is no separate investment_preferences table.
class InvestorPreferencesModel extends InvestorPreferencesEntity {
  const InvestorPreferencesModel({
    required super.id,
    required super.userId,
    required super.preferredIndustries,
    required super.preferredStages,
    required super.geographicFocus,
    super.ticketSizeMin,
    super.ticketSizeMax,
  });

  factory InvestorPreferencesModel.fromJson(Map<String, dynamic> json) {
    return InvestorPreferencesModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      preferredIndustries: _toStringList(json['preferred_industries']),
      preferredStages: _toStringList(json['preferred_stages']),
      geographicFocus: _toStringList(json['geographic_focus']),
      ticketSizeMin: _toDouble(json['ticket_size_min']),
      ticketSizeMax: _toDouble(json['ticket_size_max']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    // Postgres text[] can arrive as a raw string like '{fintech,agritech}'.
    if (value is String && value.isNotEmpty) {
      return value
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
