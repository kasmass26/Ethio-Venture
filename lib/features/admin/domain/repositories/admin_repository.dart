import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<AdminEntity> getAdminProfile(String id);
}