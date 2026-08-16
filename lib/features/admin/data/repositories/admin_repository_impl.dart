import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<AdminEntity> getAdminProfile(String id) {
    return remoteDataSource.getAdminProfile(id);
  }
}
