import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    developer.log(
      'Starting sign-up. email=$email, role=$role',
      name: 'EthioVenture.Auth',
    );

    late final AuthResponse response;
    try {
      response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': role},
      );
    } catch (error, stackTrace) {
      developer.log(
        'Sign-up request failed. email=$email, role=$role',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }

    final user = response.user;

    developer.log(
      'Sign-up response received. userId=${user?.id}, '
      'hasSession=${response.session != null}',
      name: 'EthioVenture.Auth',
    );

    if (user == null) {
      throw Exception('Registration failed.');
    }

    // `auth.users` is managed by Supabase. Store the application-facing user
    // record in the public.users table immediately after successful sign-up.
    // This uses the "Users can insert their own profile" RLS policy from the
    // supplied schema, so it only runs while sign-up has a valid session.
    if (response.session != null) {
      final accountType = role == 'investor' ? 'investor' : 'startup';
      try {
        await supabaseClient.from('users').insert({
          'id': user.id,
          'email': user.email ?? email,
          'full_name': name,
          'account_type': accountType,
        });
        developer.log(
          'Application user stored. userId=${user.id}, '
          'accountType=$accountType',
          name: 'EthioVenture.Auth',
        );
      } on PostgrestException catch (error, stackTrace) {
        // A database trigger may have created the same row first. In that
        // case the desired public.users record already exists.
        if (error.code == '23505') {
          developer.log(
            'Application user already exists. userId=${user.id}',
            name: 'EthioVenture.Auth',
          );
        } else {
          developer.log(
            'Could not store application user. userId=${user.id}',
            name: 'EthioVenture.Auth',
            error: error,
            stackTrace: stackTrace,
            level: 1000,
          );
          rethrow;
        }
      }
    } else {
      developer.log(
        'Sign-up has no session; public.users must be created by the '
        'on_auth_user_created database trigger after email confirmation.',
        name: 'EthioVenture.Auth',
        level: 900,
      );
    }

    return UserModel(
      id: user.id,
      name: name,
      email: user.email ?? email,
      role: role,
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    developer.log('Starting sign-in. email=$email', name: 'EthioVenture.Auth');

    late final AuthResponse response;
    try {
      response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Sign-in request failed. email=$email',
        name: 'EthioVenture.Auth',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }

    final user = response.user;

    developer.log(
      'Sign-in response received. userId=${user?.id}, '
      'hasSession=${response.session != null}',
      name: 'EthioVenture.Auth',
    );

    if (user == null) {
      throw Exception('Login failed.');
    }

    String fullName = nameFromUser(user);
    String userRole = roleFromUser(user);

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
      // Fall back to metadata
    }

    return UserModel(
      id: user.id,
      name: fullName.isNotEmpty ? fullName : (user.email ?? email),
      email: user.email ?? email,
      role: userRole.isNotEmpty ? userRole : 'founder',
    );
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  static String nameFromUser(User user) {
    final meta = user.userMetadata;
    return meta?['full_name']?.toString() ?? meta?['name']?.toString() ?? '';
  }

  static String roleFromUser(User user) {
    final meta = user.userMetadata;
    return meta?['role']?.toString() ?? '';
  }

  static String _appRoleFromAccountType(String? accountType) {
    return switch (accountType) {
      'startup' => 'founder',
      'investor' => 'investor',
      _ => '',
    };
  }
}
