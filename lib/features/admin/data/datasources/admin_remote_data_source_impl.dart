import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pending_approval_model.dart';
import 'admin_remote_data_source.dart';

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabase;

  const AdminRemoteDataSourceImpl(this.supabase);

  @override
  Future<List<PendingApprovalModel>> getPendingStartups() async {
    try {
      final response = await supabase
          .from('startup_profiles')
          .select('''
            id,
            user_id,
            business_name:startup_name,
            description,
            industry,
            funding_stage,
            funding_amount_sought:funding_amount_needed,
            location,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'pending')
          .order('created_at', ascending: false);

      developer.log(
        'Fetched ${response.length} pending startups',
        name: 'EthioVenture.Admin',
      );

      return (response as List)
          .map((json) => PendingApprovalModel.fromJson({
                ...json,
                'name': json['users']['full_name'],
                'email': json['users']['email'],
                'role': 'founder', // Startups are always founders
              }))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch pending startups',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<List<PendingApprovalModel>> getPendingInvestors() async {
    try {
      final response = await supabase
          .from('investor_profiles')
          .select('''
            id,
            user_id,
            organization_name,
            bio,
            investor_type,
            preferred_industries,
            preferred_stages,
            ticket_size_min,
            ticket_size_max,
            geographic_focus,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'pending')
          .order('created_at', ascending: false);

      developer.log(
        'Fetched ${response.length} pending investors',
        name: 'EthioVenture.Admin',
      );

      return (response as List)
          .map((json) {
            return PendingApprovalModel.fromJson({
              'id': json['id'],
              'user_id': json['user_id'],
              'name': json['users']['full_name'],
              'email': json['users']['email'],
              'role': 'investor',
              'business_name': json['organization_name'] ?? 'N/A',
              'description': json['bio'] ?? '',
              'industry': (json['preferred_industries'] as List?)?.join(', ') ?? '',
              'funding_stage': (json['preferred_stages'] as List?)?.join(', ') ?? '',
              'funding_amount_sought': json['ticket_size_max'] ?? 0.0,
              'location': (json['geographic_focus'] as List?)?.join(', ') ?? '',
              'logo_url': null,
              'created_at': json['created_at'],
              'approval_status': json['approval_status'],
              'rejection_reason': json['rejection_reason'],
              'approval_date': json['approval_date'],
            });
          })
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch pending investors',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<void> approveProfile(String profileId, String role) async {
    try {
      final table = role == 'founder' ? 'startup_profiles' : 'investor_profiles';
      
      await supabase
          .from(table)
          .update({
            'approval_status': 'approved',
            'rejection_reason': null,
            'approval_date': DateTime.now().toIso8601String(),
          })
          .eq('id', profileId);

      developer.log(
        'Approved profile: $profileId in table: $table',
        name: 'EthioVenture.Admin',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to approve profile: $profileId',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<void> rejectProfile(String profileId, String role, String rejectionReason) async {
    try {
      final table = role == 'founder' ? 'startup_profiles' : 'investor_profiles';
      
      await supabase
          .from(table)
          .update({
            'approval_status': 'rejected',
            'rejection_reason': rejectionReason,
            'approval_date': DateTime.now().toIso8601String(),
          })
          .eq('id', profileId);

      developer.log(
        'Rejected profile: $profileId in table: $table with reason: $rejectionReason',
        name: 'EthioVenture.Admin',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to reject profile: $profileId',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<List<PendingApprovalModel>> getApprovedStartups() async {
    try {
      final response = await supabase
          .from('startup_profiles')
          .select('''
            id,
            user_id,
            business_name:startup_name,
            description,
            industry,
            funding_stage,
            funding_amount_sought:funding_amount_needed,
            location,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PendingApprovalModel.fromJson({
                ...json,
                'name': json['users']['full_name'],
                'email': json['users']['email'],
                'role': 'founder',
              }))
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch approved startups',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<List<PendingApprovalModel>> getApprovedInvestors() async {
    try {
      final response = await supabase
          .from('investor_profiles')
          .select('''
            id,
            user_id,
            organization_name,
            bio,
            investor_type,
            preferred_industries,
            preferred_stages,
            ticket_size_min,
            ticket_size_max,
            geographic_focus,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) {
            return PendingApprovalModel.fromJson({
              'id': json['id'],
              'user_id': json['user_id'],
              'name': json['users']['full_name'],
              'email': json['users']['email'],
              'role': 'investor',
              'business_name': json['organization_name'] ?? 'N/A',
              'description': json['bio'] ?? '',
              'industry': (json['preferred_industries'] as List?)?.join(', ') ?? '',
              'funding_stage': (json['preferred_stages'] as List?)?.join(', ') ?? '',
              'funding_amount_sought': json['ticket_size_max'] ?? 0.0,
              'location': (json['geographic_focus'] as List?)?.join(', ') ?? '',
              'logo_url': null,
              'created_at': json['created_at'],
              'approval_status': json['approval_status'],
              'rejection_reason': json['rejection_reason'],
              'approval_date': json['approval_date'],
            });
          })
          .toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch approved investors',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  @override
  Future<List<PendingApprovalModel>> getRejectedProfiles() async {
    try {
      final startups = await supabase
          .from('startup_profiles')
          .select('''
            id,
            user_id,
            business_name:startup_name,
            description,
            industry,
            funding_stage,
            funding_amount_sought:funding_amount_needed,
            location,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'rejected')
          .order('created_at', ascending: false);

      final investors = await supabase
          .from('investor_profiles')
          .select('''
            id,
            user_id,
            organization_name,
            bio,
            investor_type,
            preferred_industries,
            preferred_stages,
            ticket_size_min,
            ticket_size_max,
            geographic_focus,
            created_at,
            approval_status,
            rejection_reason,
            approval_date,
            users!inner(full_name, email, account_type)
          ''')
          .eq('approval_status', 'rejected')
          .order('created_at', ascending: false);

      final allRejected = [
        ...(startups as List).map((json) => PendingApprovalModel.fromJson({
              ...json,
              'name': json['users']['full_name'],
              'email': json['users']['email'],
              'role': 'founder',
            })),
        ...(investors as List).map((json) {
            return PendingApprovalModel.fromJson({
              'id': json['id'],
              'user_id': json['user_id'],
              'name': json['users']['full_name'],
              'email': json['users']['email'],
              'role': 'investor',
              'business_name': json['organization_name'] ?? 'N/A',
              'description': json['bio'] ?? '',
              'industry': (json['preferred_industries'] as List?)?.join(', ') ?? '',
              'funding_stage': (json['preferred_stages'] as List?)?.join(', ') ?? '',
              'funding_amount_sought': json['ticket_size_max'] ?? 0.0,
              'location': (json['geographic_focus'] as List?)?.join(', ') ?? '',
              'logo_url': null,
              'created_at': json['created_at'],
              'approval_status': json['approval_status'],
              'rejection_reason': json['rejection_reason'],
              'approval_date': json['approval_date'],
            });
          }),
      ];

      allRejected.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allRejected;
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch rejected profiles',
        name: 'EthioVenture.Admin',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }
}
