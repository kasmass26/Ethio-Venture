import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminProfile {
  final AdminRepository repository;

  GetAdminProfile(this.repository);

  Future<AdminEntity> call(String id) {
    return repository.getAdminProfile(id);
  }
}