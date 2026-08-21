import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_endpoints.dart';
import '../pages/founder_dashboard_page.dart';
import 'founder_metrics_state.dart';

class FounderMetricsCubit extends Cubit<FounderMetricsState> {
  final SupabaseClient _client;

  FounderMetricsCubit({required SupabaseClient supabaseClient})
      : _client = supabaseClient,
        super(const FounderMetricsInitial());

  Future<void> loadMetrics({
    required String userId,
    String? startupProfileId,
    String? industry,
  }) async {
    emit(const FounderMetricsLoading());

    try {
      // 1. Connection Requests sent by founder
      List<dynamic> requestsList = [];
      try {
        final res = await _client
            .from(ApiEndpoints.connectionRequests)
            .select('id, status')
            .eq('founder_user_id', userId);
        requestsList = res as List;
      } catch (e) {
        developer.log('Error fetching connection requests: $e', name: 'FounderMetricsCubit');
      }

      // 2. Conversations for startup profile
      List<dynamic> conversationsList = [];
      if (startupProfileId != null && startupProfileId.isNotEmpty) {
        try {
          final res = await _client
              .from(ApiEndpoints.conversations)
              .select('id')
              .eq('startup_id', startupProfileId);
          conversationsList = res as List;
        } catch (e) {
          developer.log('Error fetching conversations: $e', name: 'FounderMetricsCubit');
        }
      }

      // 3. Documents for startup profile
      List<dynamic> documentsList = [];
      if (startupProfileId != null && startupProfileId.isNotEmpty) {
        try {
          final res = await _client
              .from(ApiEndpoints.documents)
              .select('id')
              .eq('startup_id', startupProfileId);
          documentsList = res as List;
        } catch (e) {
          developer.log('Error fetching documents: $e', name: 'FounderMetricsCubit');
        }
      }

      // 4. Matching approved investors
      List<dynamic> investorsList = [];
      try {
        final res = await _client
            .from(ApiEndpoints.investorProfiles)
            .select('id, preferred_industries, approval_status')
            .eq('approval_status', 'approved');
        investorsList = res as List;
      } catch (e) {
        developer.log('First investor query failed, attempting fallback: $e', name: 'FounderMetricsCubit');
        try {
          final res = await _client
              .from(ApiEndpoints.investorProfiles)
              .select('id, preferred_industries');
          investorsList = res as List;
        } catch (e2) {
          developer.log('Error fetching investor matches: $e2', name: 'FounderMetricsCubit');
        }
      }

      // Calculate Connection Request details
      final totalRequests = requestsList.length;
      final acceptedRequests = requestsList
          .where((r) => (r['status'] as String?)?.toLowerCase() == 'accepted')
          .length;
      final pendingRequests = requestsList
          .where((r) => (r['status'] as String?)?.toLowerCase() == 'pending')
          .length;

      // Calculate Conversations
      final conversationsCount = conversationsList.length;

      // Calculate Documents
      final documentsCount = documentsList.length;

      // Calculate Investor Matches (filtered by industry if available)
      int matchingInvestorsCount = 0;
      if (industry != null && industry.isNotEmpty) {
        matchingInvestorsCount = investorsList.where((inv) {
          final industries = inv['preferred_industries'];
          if (industries is List) {
            return industries.any(
              (ind) => ind.toString().toLowerCase().contains(industry.toLowerCase()),
            );
          }
          return true;
        }).length;
      } else {
        matchingInvestorsCount = investorsList.length;
      }

      final List<DashboardMetric> metrics = [
        DashboardMetric(
          label: 'Investor Requests',
          value: '$totalRequests',
          deltaText: totalRequests > 0
              ? '$acceptedRequests accepted, $pendingRequests pending'
              : '0 requests sent',
          iconAsset: 'interest',
          isPositive: acceptedRequests > 0 || totalRequests > 0,
        ),
        DashboardMetric(
          label: 'Conversations',
          value: '$conversationsCount',
          deltaText: conversationsCount > 0
              ? '$conversationsCount active chats'
              : 'No active chats',
          iconAsset: 'conversations',
          isPositive: conversationsCount > 0,
        ),
        DashboardMetric(
          label: 'Pitch Deck & Docs',
          value: '$documentsCount',
          deltaText: documentsCount > 0
              ? '$documentsCount docs uploaded'
              : 'No documents uploaded',
          iconAsset: 'views',
          isPositive: documentsCount > 0,
        ),
        DashboardMetric(
          label: 'Investor Matches',
          value: '$matchingInvestorsCount',
          deltaText: matchingInvestorsCount > 0
              ? '$matchingInvestorsCount target investors'
              : 'No matches found',
          iconAsset: 'matches',
          isPositive: matchingInvestorsCount > 0,
        ),
      ];

      final List<IconData> icons = [
        Icons.handshake_outlined,
        Icons.chat_bubble_outline_rounded,
        Icons.description_outlined,
        Icons.people_alt_outlined,
      ];

      emit(FounderMetricsLoaded(metrics: metrics, icons: icons));
    } catch (e, st) {
      developer.log('Unexpected error loading founder metrics: $e', name: 'FounderMetricsCubit', error: e, stackTrace: st);
      emit(FounderMetricsError(e.toString()));
    }
  }
}
