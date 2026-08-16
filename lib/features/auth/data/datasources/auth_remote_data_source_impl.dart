import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String role,
  }) async {
    // TODO: Replace this local mock response with the real authentication endpoint
    // once the backend contract is available.
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim();
    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    final roleValue = role == UserRole.investor.name
        ? UserRole.investor
        : UserRole.startup;

    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: normalizedEmail.split('@').first,
      email: normalizedEmail,
      role: roleValue,
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace this stub with the real login API call once the backend contract is available.
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedEmail = email.trim();
    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    return UserModel(
      id: 'demo-user-id',
      name: normalizedEmail.split('@').first,
      email: normalizedEmail,
      role: UserRole.startup,
    );
  }

  @override
  Future<void> logout() async {
    // TODO: Clear token/session when the real backend adds auth persistence.
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
