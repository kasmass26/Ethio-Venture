import '../../domain/entities/connection_request_entity.dart';

/// Data model for a connection request — maps to/from Supabase JSON.
class ConnectionRequestModel extends ConnectionRequestEntity {
  const ConnectionRequestModel({
    required super.id,
    required super.founderUserId,
    required super.investorUserId,
    super.startupProfileId,
    super.investorProfileId,
    required super.status,
    super.message,
    required super.createdAt,
    required super.updatedAt,
    super.founderName,
    super.startupName,
    super.investorName,
  });

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle nested join data when present
    final founderName = json['founder_name']?.toString() ??
        json['founder']?['full_name']?.toString();
    final startupName = json['startup_name']?.toString() ??
        json['startup_profiles']?['startup_name']?.toString();
    final investorName = json['investor_name']?.toString() ??
        json['investor_profiles']?['display_name']?.toString();

    return ConnectionRequestModel(
      id: json['id']?.toString() ?? '',
      founderUserId: json['founder_user_id']?.toString() ?? '',
      investorUserId: json['investor_user_id']?.toString() ?? '',
      startupProfileId: json['startup_profile_id']?.toString(),
      investorProfileId: json['investor_profile_id']?.toString(),
      status: ConnectionRequestStatus.fromString(
        json['status']?.toString() ?? 'pending',
      ),
      message: json['message']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      founderName: founderName,
      startupName: startupName,
      investorName: investorName,
    );
  }

  Map<String, dynamic> toInsertJson({
    required String founderUserId,
    required String investorUserId,
    String? startupProfileId,
    String? investorProfileId,
    String? message,
  }) {
    return {
      'founder_user_id': founderUserId,
      'investor_user_id': investorUserId,
      if (startupProfileId != null) 'startup_profile_id': startupProfileId,
      if (investorProfileId != null) 'investor_profile_id': investorProfileId,
      'status': 'pending',
      if (message != null && message.isNotEmpty) 'message': message,
    };
  }
}
