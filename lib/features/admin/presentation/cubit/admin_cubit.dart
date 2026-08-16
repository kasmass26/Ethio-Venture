import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/admin_remote_data_source_impl.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit({AdminRepository? repository})
      : _repository = repository ??
            AdminRepositoryImpl(AdminRemoteDataSourceImpl()),
        super(AdminInitial());

  final AdminRepository _repository;

  Future<void> loadProfile(String id) async {
    emit(AdminLoading());

    try {
      final admin = await _repository.getAdminProfile(id);
      emit(AdminLoaded(admin));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> refreshProfile(String id) async {
    await loadProfile(id);
  }
}
