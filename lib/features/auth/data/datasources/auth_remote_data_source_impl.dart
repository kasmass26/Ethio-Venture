import 'package:flutter/foundation.dart';
// Import only the Supabase types we need. We do NOT import AuthException from
// supabase_flutter because our own AuthException in core/error/exceptions.dart
// takes precedence and keeps the architecture consistent.
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

  // ── Register ─────────────────────────────────────────────────────────────

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // 1. Create the Supabase Auth user.
    final AuthResponse response;
    try {
      response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'role': role},
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw AuthException(message: 'Sign-up failed: $e');
    }

    final user = response.user;
    if (user == null) {
      throw const AuthException(
        message: 'Registration failed: no user was returned by Supabase.',
      );
    }

    // 2. Detect email-confirmation-required state.
    //    When session is null the account exists in auth.users but is not yet
    //    active. Throw a typed exception so the cubit can emit the correct state
    //    instead of pretending the user is authenticated.
    if (response.session == null) {
      debugPrint(
        '[Auth] signUp succeeded for ${user.email} but session is null — '
        'email confirmation is required.',
      );
      throw EmailConfirmationRequiredException(email: user.email ?? email);
    }

    // 3. Session is live — write the application profile record.
    //    Errors are surfaced, not swallowed, so we can diagnose table/RLS issues.
    try {
      await supabaseClient.from('profiles').upsert({
        'id': user.id,     // FK → auth.users.id  (same UUID)
        'full_name': name,
        'role': role,
      });
    } on PostgrestException catch (e) {
      debugPrint('[Auth] profiles upsert failed: ${e.message} (code: ${e.code})');
      throw ServerException(
        message: 'Account created but profile record could not be saved. '
            'Supabase error: ${e.message}',
      );
    } catch (e) {
      debugPrint('[Auth] profiles upsert unexpected error: $e');
      throw ServerException(
        message: 'Account created but profile save failed: $e',
      );
    }

    return UserModel(
      id: user.id,
      name: name,
      email: user.email ?? email,
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

    // Enrich with the profiles table; fall back to auth metadata on error.
    try {
      final profile = await supabaseClient
          .from('profiles')
          .select('full_name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        fullName = profile['full_name']?.toString() ?? fullName;
        userRole = profile['role']?.toString() ?? userRole;
      }
    } on PostgrestException catch (e) {
      // Non-fatal: log and continue with auth metadata values.
      debugPrint('[Auth] profiles fetch failed on login: ${e.message}');
    } catch (e) {
      debugPrint('[Auth] profiles fetch unexpected error on login: $e');
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
    return user.userMetadata?['role']?.toString() ?? '';
  }
}
