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
  /// There is no `status` column on startup_profiles, so all rows are
  /// returned. The scorer will rank them; zero-score results appear last.
  Future<List<StartupProfileModel>> getStartupProfiles() async {
    final rows = await _client
        .from(ApiEndpoints.startupProfiles)
        .select(
          'id, user_id, business_name, startup_name, description, '
          'industry, funding_stage, funding_amount_sought, '
          'funding_amount_needed, location',
        )
        .order('created_at', ascending: false);

    return (rows as List)
        .map(
          (r) => StartupProfileModel.fromJson(
            Map<String, dynamic>.from(r as Map),
          ),
        )
        .toList();
  }
}
