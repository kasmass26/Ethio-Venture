import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show AuthException;
import 'package:ethioventure/core/error/exceptions.dart';
import '../models/user_model.dart';

/// Contract for remote Supabase Authentication operations.
abstract interface class AuthRemoteDataSource {
  /// Signs in a Startup Founder with email and password.
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Registers a new Startup Founder account.
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Logs out current Supabase user session.
  Future<void> logout();

  /// Gets current active Supabase user session details.
  Future<UserModel?> getCurrentUser();
}

/// Concrete implementation of [AuthRemoteDataSource] using Supabase Auth SDK.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const String _usersTable = 'users';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const ServerException(message: 'Invalid credentials or user session.');
      }

      // Fetch user profile attributes from public.users table
      final dbUser = await _client
          .from(_usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (dbUser != null) {
        return UserModel.fromJson(dbUser);
      }

      return UserModel(
        id: user.id,
        email: user.email ?? email,
        fullName: 'Startup Founder',
        accountType: 'startup',
      );
    } on supabase.AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to sign in: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'account_type': 'startup'},
      );

      final user = authResponse.user;
      if (user == null) {
        throw const ServerException(message: 'Failed to create user account.');
      }

      final userModel = UserModel(
        id: user.id,
        email: email,
        fullName: fullName,
        accountType: 'startup',
      );

      // Upsert into public.users database table
      try {
        await _client.from(_usersTable).upsert(userModel.toJson());
      } catch (_) {}

      return userModel;
    } on supabase.AuthException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to register account: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw ServerException(message: 'Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final dbUser = await _client
          .from(_usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (dbUser != null) {
        return UserModel.fromJson(dbUser);
      }

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: 'Startup Founder',
        accountType: 'startup',
      );
    } catch (_) {
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: 'Startup Founder',
        accountType: 'startup',
      );
    }
  }
}
