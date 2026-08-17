import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim();
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw const FormatException('Please enter your name.');
    }

    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    final userRole = role == UserRole.investor.name
        ? UserRole.investor
        : UserRole.startup;

    try {
      final response = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': cleanName,
          'role': userRole.name,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(message: 'Unable to create your account.');
      }

      return UserModel(
        id: user.id,
        name: user.userMetadata?['full_name']?.toString() ?? cleanName,
        email: user.email ?? normalizedEmail,
        role: userRole,
      );
    } on AuthException {
      rethrow;
    } on FormatException {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } catch (error) {
      throw ServerException(message: 'Unable to create your account. Please try again.');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    if (!normalizedEmail.contains('@')) {
      throw const FormatException('Please enter a valid email address.');
    }

    if (password.length < 6) {
      throw const FormatException(
        'Password must be at least 6 characters long.',
      );
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final sessionUser = response.user;
      if (sessionUser == null) {
        throw const AuthException(message: 'Invalid email or password');
      }

      final metadata = sessionUser.userMetadata ?? const {};
      final role = _roleFromMetadata(metadata['role']);

      return UserModel(
        id: sessionUser.id,
        name: metadata['full_name']?.toString() ??
            metadata['name']?.toString() ??
            normalizedEmail.split('@').first,
        email: sessionUser.email ?? normalizedEmail,
        role: role,
      );
    } on AuthException catch (error) {
      throw ServerException(message: error.message);
    } on FormatException {
      rethrow;
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    } catch (_) {
      throw const ServerException(
        message: 'Something went wrong. Please try again later.',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  UserRole _roleFromMetadata(dynamic value) {
    final roleName = value?.toString().toLowerCase();
    if (roleName == UserRole.investor.name) {
      return UserRole.investor;
    }
    return UserRole.startup;
  }
}
