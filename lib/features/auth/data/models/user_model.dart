import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['user_metadata'] is Map
        ? Map<String, dynamic>.from(json['user_metadata'] as Map)
        : <String, dynamic>{};
    final appMetadata = json['app_metadata'] is Map
        ? Map<String, dynamic>.from(json['app_metadata'] as Map)
        : <String, dynamic>{};

    final name = metadata['full_name']?.toString() ??
        metadata['name']?.toString() ??
        appMetadata['full_name']?.toString() ??
        appMetadata['name']?.toString() ??
        json['name']?.toString() ??
        (json['email'] ?? '').toString().split('@').first;

    final roleName = (metadata['role'] ?? appMetadata['role'] ?? json['role'])
        ?.toString()
        .toLowerCase();

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: name,
      email: json['email']?.toString() ?? '',
      role: roleName == 'investor' ? UserRole.investor : UserRole.startup,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.investor ? 'investor' : 'startup',
    };
  }
}