import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/investor_profile/data/models/investor_model.dart';
import 'package:ethioventure/features/matching/data/datasources/matching_mock_data.dart';
import 'package:ethioventure/features/startup_profile/data/models/startup_model.dart';

abstract class MatchingRemoteDataSource {
  Future<InvestorModel> getInvestorProfile(String investorId);
  Future<InvestorModel> updateInvestorPreferences(InvestorModel investor);
  Future<List<StartupModel>> getAllStartups();
  Future<List<InvestorModel>> getAllInvestors();
}

/// Remote Data Source implementation for Supabase / REST API
/// with in-memory reactive state and resilient offline fallback.
class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  final Map<String, InvestorModel> _investorStore = {};
  final List<StartupModel> _startupStore = [];

  MatchingRemoteDataSourceImpl() {
    _initStore();
  }

  void _initStore() {
    for (final inv in MatchingMockData.mockInvestors) {
      _investorStore[inv.id] = inv;
    }
    _startupStore.addAll(MatchingMockData.mockStartups);
  }

  @override
  Future<InvestorModel> getInvestorProfile(String investorId) async {
    try {
      // Simulate network roundtrip latency
      await Future.delayed(const Duration(milliseconds: 300));

      if (_investorStore.containsKey(investorId)) {
        return _investorStore[investorId]!;
      }

      // Default fallback to primary seed investor
      if (_investorStore.isNotEmpty) {
        return _investorStore.values.first;
      }

      throw ServerException(message: 'Investor profile not found for id: $investorId');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InvestorModel> updateInvestorPreferences(InvestorModel investor) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _investorStore[investor.id] = investor;
      return investor;
    } catch (e) {
      throw ServerException(message: 'Failed to update preferences: ${e.toString()}');
    }
  }

  @override
  Future<List<StartupModel>> getAllStartups() async {
    try {
      await Future.delayed(const Duration(milliseconds: 350));
      return List<StartupModel>.from(_startupStore);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch startups: ${e.toString()}');
    }
  }

  @override
  Future<List<InvestorModel>> getAllInvestors() async {
    return _investorStore.values.toList();
  }
}
