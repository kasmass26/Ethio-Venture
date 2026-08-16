import '../models/admin_model.dart';
import 'admin_remote_data_source.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  @override
  Future<AdminModel> getAdminProfile(String id) async {
    // TODO: Replace this local stub with the real admin API endpoint when the backend is available.
    await Future.delayed(const Duration(milliseconds: 400));

    return AdminModel(
      id: id.isEmpty ? 'admin-1' : id,
      name: 'System Admin',
      email: 'admin@ethioventure.local',
    );
  }
}