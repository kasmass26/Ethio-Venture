import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_model.dart';
import '../models/startup_profile_model.dart';

abstract class StartupProfileRemoteDataSource {
  Future<StartupProfileModel> createStartupProfile(StartupProfileModel profile);

  Future<StartupProfileModel> getStartupProfile(String id);

  Future<StartupProfileModel> updateStartupProfile(StartupProfileModel profile);

  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  });

  Future<void> deleteDocument({
    required String startupId,
    required String documentId,
  });
}

class StartupProfileRemoteDataSourceImpl
    implements StartupProfileRemoteDataSource {
  final SupabaseClient? supabaseClient;

  StartupProfileRemoteDataSourceImpl({this.supabaseClient});

  SupabaseClient get _client => supabaseClient ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  // In-memory fallback dataset for offline/tests
  StartupProfileModel _fallbackProfile = StartupProfileModel(
    id: 'st_01',
    userId: 'user_fallback',
    companyName: 'Chapa Financial Technologies',
    tagline:
        'Modern payment infrastructure connecting African merchants to global commerce.',
    description:
        'Chapa provides developer-friendly REST APIs and payment gateways enabling Ethiopian businesses to process digital transactions via Telebirr, CBE Birr, cards, and bank transfers.',
    industry: 'FinTech',
    fundingStage: 'Series A',
    targetFundingAmount: 1500000.0,
    raisedFundingAmount: 950000.0,
    companyValuation: 12000000.0,
    monthlyBurnRate: 45000.0,
    monthlyRevenue: 85000.0,
    location: 'Addis Ababa, Ethiopia',
    websiteUrl: 'https://chapa.co',
    logoUrl: 'https://via.placeholder.com/150/1B4332/FFFFFF?text=Chapa',
    founderName: 'Nael Hailemariam',
    founderEmail: 'nael@chapa.co',
    founderRole: 'Co-Founder & CEO',
    teamMembers: const [
      'Israel Goytom (Co-Founder & CTO)',
      'Tigist Tadesse (Head of Product)',
      'Amanuel Bekele (Lead Software Architect)',
    ],
    documents: [
      DocumentModel(
        id: 'doc_01',
        fileName: 'Chapa_Pitch_Deck_2025_v2.pdf',
        fileType: 'PDF',
        category: 'Pitch Deck',
        fileSizeBytes: 4850000,
        downloadUrl: 'https://ethioventure.com/docs/chapa_deck.pdf',
        uploadedAt: DateTime(2025, 2, 10),
        isVerified: true,
      ),
    ],
    updatedAt: DateTime.now(),
  );

  @override
  Future<StartupProfileModel> createStartupProfile(
    StartupProfileModel profile,
  ) async {
    try {
      final currentUid = _currentUserId;
      final data = profile.toSupabaseJson();
      if (currentUid != null && currentUid.isNotEmpty) {
        data['user_id'] = currentUid;
      }

      final response = await _client
          .from('startup_profiles')
          .insert(data)
          .select()
          .single();

      return StartupProfileModel.fromJson(response);
    } catch (e) {
      // Fallback for tests or offline execution
      final newProfile = StartupProfileModel.fromEntity(
        profile.copyWith(
          id: profile.id.isEmpty
              ? 'st_${DateTime.now().millisecondsSinceEpoch}'
              : profile.id,
          userId: _currentUserId ?? 'user_default',
        ),
      );
      _fallbackProfile = newProfile;
      return _fallbackProfile;
    }
  }

  @override
  Future<StartupProfileModel> getStartupProfile(String id) async {
    try {
      final currentUid = _currentUserId;

      PostgrestFilterBuilder query = _client.from('startup_profiles').select();

      final response = currentUid != null && currentUid.isNotEmpty
          ? await query.eq('user_id', currentUid).maybeSingle()
          : await query.eq('id', id).maybeSingle();

      if (response != null) {
        return StartupProfileModel.fromJson(response);
      }
      return _fallbackProfile;
    } catch (e) {
      return _fallbackProfile;
    }
  }

  @override
  Future<StartupProfileModel> updateStartupProfile(
    StartupProfileModel profile,
  ) async {
    try {
      final currentUid = _currentUserId;
      final data = profile.toSupabaseJson();

      Map<String, dynamic>? response;
      if (currentUid != null && currentUid.isNotEmpty) {
        response = await _client
            .from('startup_profiles')
            .update(data)
            .eq('user_id', currentUid)
            .select()
            .single();
      } else if (profile.id.isNotEmpty) {
        response = await _client
            .from('startup_profiles')
            .update(data)
            .eq('id', profile.id)
            .select()
            .single();
      }

      if (response != null) {
        return StartupProfileModel.fromJson(response);
      }
      _fallbackProfile = profile;
      return _fallbackProfile;
    } catch (e) {
      _fallbackProfile = profile;
      return _fallbackProfile;
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
    required String startupId,
    required String category,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    try {
      final newDocData = {
        'startup_id': startupId,
        'category': category,
        'file_name': fileName,
        'file_type': fileType,
        'file_size_bytes': fileSizeBytes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('startup_documents')
          .insert(newDocData)
          .select()
          .single();

      return DocumentModel.fromJson(response);
    } catch (e) {
      final newDoc = DocumentModel(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        fileName: fileName,
        fileType: fileType,
        category: category,
        fileSizeBytes: fileSizeBytes,
        downloadUrl: 'https://ethioventure.com/docs/$fileName',
        uploadedAt: DateTime.now(),
        isVerified: false,
      );

      final updatedDocs = List<DocumentModel>.from(
        _fallbackProfile.documents.cast<DocumentModel>(),
      )..add(newDoc);

      _fallbackProfile = StartupProfileModel.fromEntity(
        _fallbackProfile.copyWith(documents: updatedDocs),
      );

      return newDoc;
    }
  }

  @override
  Future<void> deleteDocument({
    required String startupId,
    required String documentId,
  }) async {
    try {
      await _client.from('startup_documents').delete().eq('id', documentId);
    } catch (_) {
      final updatedDocs = _fallbackProfile.documents
          .where((doc) => doc.id != documentId)
          .toList();

      _fallbackProfile = StartupProfileModel.fromEntity(
        _fallbackProfile.copyWith(documents: updatedDocs),
      );
    }
  }
}
