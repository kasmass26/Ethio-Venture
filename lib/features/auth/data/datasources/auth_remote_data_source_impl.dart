import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'role': role,
      },
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Registration failed.');
    }

    try {
      await supabaseClient.from('profiles').upsert({
        'id': user.id,
        'role': role,
        'full_name': name,
      });
    } catch (_) {
      // Ignored if handled by database trigger or pending email confirmation
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
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Login failed.');
    }

    String fullName = nameFromUser(user);
    String userRole = roleFromUser(user);

    try {
      final profile = await supabaseClient
          .from('profiles')
          .select('id, role, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        fullName = profile['full_name']?.toString() ?? fullName;
        userRole = profile['role']?.toString() ?? userRole;
      }
    } catch (_) {
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
}