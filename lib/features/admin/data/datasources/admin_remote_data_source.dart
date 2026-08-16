import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminModel> getAdminProfile(String id);
}