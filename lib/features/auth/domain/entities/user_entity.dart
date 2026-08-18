/// Pure domain entity representing an authenticated Startup Founder user.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.accountType = 'startup',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String accountType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
