import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  AdminModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}