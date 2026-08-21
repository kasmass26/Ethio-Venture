import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/models/user_model.dart';

/// Service to get the current authenticated user's information
class UserService {
  final SupabaseClient _supabaseClient;

  UserService(this._supabaseClient);

  /// Get the currently authenticated user
  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabaseClient.auth.currentUser;
    
    if (authUser == null) {
      return null;
    }

    String fullName = _nameFromUser(authUser);
    String userRole = _roleFromUser(authUser);

    try {
      final profile = await _supabaseClient
          .from('users')
          .select('id, account_type, full_name')
          .eq('id', authUser.id)
          .maybeSingle();

      if (profile != null) {
        fullName = profile['full_name']?.toString() ?? fullName;
        final mappedRole = _appRoleFromAccountType(profile['account_type']?.toString());
        if (mappedRole.isNotEmpty) {
          userRole = mappedRole;
        }
      }
    } catch (e) {
      // Fall back to metadata if profile fetch fails
    }

    return UserModel(
      id: authUser.id,
      name: fullName.isNotEmpty ? fullName : (authUser.email ?? 'User'),
      email: authUser.email ?? '',
      role: userRole.isNotEmpty ? userRole : 'founder',
    );
  }

  /// Get the user's first name from their full name
  String getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  static String _nameFromUser(User user) {
    final meta = user.userMetadata;
    return meta?['full_name']?.toString() ?? meta?['name']?.toString() ?? '';
  }

  static String _roleFromUser(User user) {
    final role = user.userMetadata?['role']?.toString() ?? '';
    return _appRoleFromAccountType(role).isNotEmpty
        ? _appRoleFromAccountType(role)
        : role;
  }

  static String _appRoleFromAccountType(String? accountType) {
    return switch (accountType?.toLowerCase().trim()) {
      'startup' || 'founder' => 'founder',
      'investor' => 'investor',
      'admin' => 'admin',
      _ => '',
    };
  }
}
