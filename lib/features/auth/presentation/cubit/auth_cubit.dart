import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_remote_data_source_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? repository})
      : _repository = repository ??
            AuthRepositoryImpl(AuthRemoteDataSourceImpl()),
        super(AuthInitial());

  final AuthRepository _repository;

  bool get isAuthenticated => state is AuthSuccess;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    emit(AuthLoading());

    try {
      final cleanName = name.trim();
      final cleanEmail = email.trim();

      if (cleanName.isEmpty) {
        throw const FormatException('Please enter your name.');
      }

      if (!cleanEmail.contains('@')) {
        throw const FormatException('Please enter a valid email address.');
      }

      if (password.length < 6) {
        throw const FormatException(
          'Password must be at least 6 characters long.',
        );
      }

      final user = await _repository.register(
        email: cleanEmail,
        password: password,
        role: role,
      );

      emit(AuthSuccess(user));
    } on FormatException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final cleanEmail = email.trim();

      if (!cleanEmail.contains('@')) {
        throw const FormatException('Please enter a valid email address.');
      }

      if (password.length < 6) {
        throw const FormatException(
          'Password must be at least 6 characters long.',
        );
      }

      final user = await _repository.login(
        email: cleanEmail,
        password: password,
      );

      emit(AuthSuccess(user));
    } on FormatException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}