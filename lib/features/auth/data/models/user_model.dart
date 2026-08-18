import '../../domain/entities/user_entity.dart';

/// Data model representing a Startup Founder User in the Data Layer.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.accountType = 'startup',
    super.createdAt,
    super.updatedAt,
  });

  /// Constructs a [UserModel] from a Supabase PostgreSQL JSON map or auth metadata.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName'] ?? 'Startup Founder').toString(),
      accountType: (json['account_type'] ?? json['accountType'] ?? 'startup').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Converts a [UserEntity] domain instance into a [UserModel].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      accountType: entity.accountType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// JSON map for database operations on `public.users`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'account_type': accountType,
    };
  }
}
