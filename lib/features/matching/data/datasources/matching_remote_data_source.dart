import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/investor_preferences_model.dart';
import '../models/startup_profile_model.dart';

/// All Supabase queries for the matching/recommendation feature.
class MatchingRemoteDataSource {
  final SupabaseClient _client;

  MatchingRemoteDataSource({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  // ─── helpers ──────────────────────────────────────────────────────────────

  String get _currentUserId {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user.');
    return uid;
  }

  // ─── investor preferences ─────────────────────────────────────────────────

  /// Fetches investor preferences for the authenticated user.
  ///
  /// Preferences are stored directly on `investor_profiles` —
  /// there is NO separate investment_preferences table.
  ///
  /// Relationship: auth.uid() == users.id == investor_profiles.user_id
  Future<InvestorPreferencesModel> getInvestorPreferences() async {
    final userId = _currentUserId;

    final row = await _client
        .from(ApiEndpoints.investorProfiles)
        .select(
          'id, user_id, preferred_industries, preferred_stages, '
          'geographic_focus, ticket_size_min, ticket_size_max',
        )
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) {
      throw Exception(
        'No investor profile found. Please complete your investor profile.',
      );
    }

    return InvestorPreferencesModel.fromJson(
      Map<String, dynamic>.from(row as Map),
    );
  }

  // ─── startups ─────────────────────────────────────────────────────────────

  /// Fetches all startup profiles.
  ///
  /// There is no `status` column on startup_profiles, so all non-rejected rows are
  /// returned. The scorer will rank them; zero-score results appear last.
  Future<List<StartupProfileModel>> getStartupProfiles() async {
    List<dynamic> rows = [];
    try {
      final data = await _client
          .from(ApiEndpoints.startupProfiles)
          .select()
          .order('created_at', ascending: false);
      rows = (data as List).cast<dynamic>();
    } catch (e) {
      final data = await _client
          .from(ApiEndpoints.startupProfiles)
          .select();
      rows = (data as List).cast<dynamic>();
    }

    final models = <StartupProfileModel>[];
    for (final r in rows) {
      final map = Map<String, dynamic>.from(r as Map);
      final status = map['approval_status']?.toString().toLowerCase();
      if (status == 'rejected') continue;
      models.add(StartupProfileModel.fromJson(map));
    }
    return models;
  }
}
