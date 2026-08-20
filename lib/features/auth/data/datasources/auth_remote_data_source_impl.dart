import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthResponse,
        PostgrestException,
        SupabaseClient,
        User;
import 'package:supabase_flutter/supabase_flutter.dart'
    as sb show AuthException;

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  final SupabaseClient supabaseClient;

  // ── Register ──────────────────────────────────────────────────────────────

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final AuthResponse response;
    try {
      response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'name': name, 'role': role},
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Registration failed: $e');
    }

    final user = response.user;
    if (user == null) {
      throw const AuthException(
        message: 'Registration failed: no user returned.',
      );
    }

    final accountType = _accountTypeFromAppRole(role);

    try {
      await supabaseClient.from('users').upsert({
        'id': user.id,
        'email': email,
        'full_name': name,
        'account_type': accountType,
      }, onConflict: 'id');
    } on PostgrestException catch (e) {
      developer.log(
        'users insert failed after signUp. userId=${user.id}, code=${e.code}',
        name: 'EthioVenture.Auth',
        error: e,
        level: 900,
      );
    } catch (e, st) {
      developer.log(
        'Unexpected error populating users row. userId=${user.id}',
        name: 'EthioVenture.Auth',
        error: e,
        stackTrace: st,
        level: 900,
      );
    }

    return UserModel(
      id: user.id,
      name: name,
      email: email,
      role: role,
    );
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final AuthResponse response;
    try {
      response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Sign-in failed: $e');
    }

    final user = response.user;
    if (user == null) {
      throw const AuthException(message: 'Login failed: no user returned.');
    }

    String fullName = _nameFromUser(user);
    String userRole = _roleFromUser(user);

    try {
      final profile = await supabaseClient
          .from('users')
          .select('id, account_type, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        fullName = profile['full_name']?.toString() ?? fullName;
        userRole = _appRoleFromAccountType(profile['account_type']?.toString());
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not load profile. userId=${user.id}',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 900,
      );
    }

    return UserModel(
      id: user.id,
      name: fullName.isNotEmpty ? fullName : (user.email ?? email),
      email: user.email ?? email,
      role: userRole.isNotEmpty ? userRole : 'founder',
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _nameFromUser(User user) {
    final meta = user.userMetadata;
    return meta?['full_name']?.toString() ?? meta?['name']?.toString() ?? '';
  }

  static String _roleFromUser(User user) {
    final meta = user.userMetadata;
    return meta?['role']?.toString() ?? '';
  }

  static String _accountTypeFromAppRole(String role) {
    return role.toLowerCase() == 'investor' ? 'investor' : 'startup';
  }

  static String _appRoleFromAccountType(String? type) {
    if (type == null) return '';
    return type.toLowerCase() == 'investor' ? 'investor' : 'founder';
  }
}
