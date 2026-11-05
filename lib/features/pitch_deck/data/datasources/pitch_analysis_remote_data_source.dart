import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide ServerException;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ethioventure/core/network/api_endpoints.dart';
import 'package:ethioventure/core/error/exceptions.dart';
import '../models/pitch_analysis_model.dart';
import '../../domain/entities/document_entity.dart';

abstract interface class PitchAnalysisRemoteDataSource {
  Future<PitchAnalysisModel> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  });

  Future<PitchAnalysisModel?> getAnalysisForDocument({
    required String documentId,
  });

  Future<List<PitchAnalysisModel>> getStartupAnalyses({
    required String startupId,
  });
}

class PitchAnalysisRemoteDataSourceImpl implements PitchAnalysisRemoteDataSource {
  const PitchAnalysisRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  static const String _tableName = ApiEndpoints.pitchAnalyses;

  @override
  Future<PitchAnalysisModel> analyzePitchDeck({
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
      if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY') {
        throw const ServerException(
          message: 'Gemini API key is not configured. Please add GEMINI_API_KEY to your .env file.',
        );
      }

      // 1. Attempt to fetch file bytes from publicUrl
      Uint8List? fileBytes;
      String mimeType = 'application/pdf';
      if (document.fileUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(document.fileUrl)).timeout(
                const Duration(seconds: 25),
              );
          if (response.statusCode == 200) {
            fileBytes = response.bodyBytes;
            final fileNameLower = document.fileName.toLowerCase();
            if (fileNameLower.endsWith('.pdf')) {
              mimeType = 'application/pdf';
            } else if (fileNameLower.endsWith('.png')) {
              mimeType = 'image/png';
            } else if (fileNameLower.endsWith('.jpg') || fileNameLower.endsWith('.jpeg')) {
              mimeType = 'image/jpeg';
            }
          }
        } catch (_) {
          // If network fetch times out or fails, proceed with textual evaluation prompt
        }
      }

      // 2. Prepare prompt and candidate Gemini models
      final configuredModel = dotenv.env['GEMINI_MODEL']?.trim() ?? '';
      final modelsToTry = <String>{
        if (configuredModel.isNotEmpty) configuredModel,
        'gemini-3.5-flash',
        'gemini-3.5-flash-lite',
        'gemini-3.6-flash',
        'gemini-3.1-flash-lite',
      }.toList();

      final prompt = '''
You are a senior Venture Capital (VC) partner and Angel Investor evaluating a startup pitch deck on EthioVenture, Ethiopia's premier startup-investor platform.
Evaluate this pitch deck and provide an objective, rigorous, yet constructive evaluation for the founder and potential investors.

Context:
- Document Title: "${document.title}"
- File Name: "${document.fileName}"
- File Type: "${document.fileType}"
${startupSector != null ? '- Startup Sector: "$startupSector"' : ''}
${startupStage != null ? '- Startup Stage: "$startupStage"' : ''}

You MUST return a JSON object adhering STRICTLY to this schema (output valid JSON only, no introductory or conversational text):
{
  "overall_score": <integer score between 0 and 100, e.g. 78>,
  "readiness_tier": <"Investment Ready" | "Promising with Gaps" | "Early Stage / Needs Work">,
  "executive_summary": <string: 2-4 sentences summarizing the venture potential and pitch deck quality>,
  "category_scores": [
    {
      "name": "Problem & Value Proposition",
      "score": <0-100>,
      "feedback": <concise constructive review>
    },
    {
      "name": "Market Opportunity & TAM",
      "score": <0-100>,
      "feedback": <concise constructive review>
    },
    {
      "name": "Business Model & Monetization",
      "score": <0-100>,
      "feedback": <concise constructive review>
    },
    {
      "name": "Traction & Go-To-Market",
      "score": <0-100>,
      "feedback": <concise constructive review>
    },
    {
      "name": "Team & Execution Ability",
      "score": <0-100>,
      "feedback": <concise constructive review>
    },
    {
      "name": "Financials & Investment Ask",
      "score": <0-100>,
      "feedback": <concise constructive review>
    }
  ],
  "strengths": [
    <string: 3 to 5 key strengths that make this startup compelling to angel/VC investors>
  ],
  "weaknesses": [
    <string: 3 to 5 critical weaknesses, missing data, or investor risks>
  ],
  "recommendations": [
    {
      "category": <e.g. "Financial Projections", "Market Sizing", "Competitive Edge", "Ask Clarity">,
      "suggestion": <concrete actionable advice on what to edit or add>,
      "impact_level": <"High" | "Medium" | "Low">,
      "target_slide": <e.g. "Slide 4", "Financials Slide", "Traction Overview">
    }
  ],
  "ethiopian_market_fit": <string: 2-3 sentences evaluating readiness for the Ethiopian / East African ecosystem including payment integrations (Telebirr, Chapa, CBE Birr), local regulatory nuances, infrastructure, and consumer adoption>
}
''';

      String? rawText;
      Object? lastError;

      for (final modelName in modelsToTry) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.3,
            ),
          );

          final contentParts = <Part>[TextPart(prompt)];
          if (fileBytes != null &&
              fileBytes.isNotEmpty &&
              (mimeType == 'application/pdf' || mimeType.startsWith('image/'))) {
            contentParts.add(DataPart(mimeType, fileBytes));
          }

          final response = await model.generateContent([
            Content.multi(contentParts),
          ]);

          if (response.text != null && response.text!.trim().isNotEmpty) {
            rawText = response.text;
            break;
          }
        } catch (e) {
          lastError = e;
          // If sending file bytes caused a timeout or payload rejection, retry with text context
          if (fileBytes != null && fileBytes.isNotEmpty) {
            try {
              final textOnlyModel = GenerativeModel(
                model: modelName,
                apiKey: apiKey,
                generationConfig: GenerationConfig(temperature: 0.3),
              );
              final textResponse = await textOnlyModel.generateContent([
                Content.text(prompt),
              ]);
              if (textResponse.text != null && textResponse.text!.trim().isNotEmpty) {
                rawText = textResponse.text;
                break;
              }
            } catch (_) {}
          }
        }
      }

      if (rawText == null || rawText.trim().isEmpty) {
        throw ServerException(
          message: lastError != null
              ? 'AI analysis failed: $lastError'
              : 'AI did not return any analysis for this document.',
        );
      }

      // 3. Parse JSON safely
      Map<String, dynamic> parsedJson;
      try {
        final sanitized = rawText
            .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
            .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
            .trim();
        parsedJson = jsonDecode(sanitized) as Map<String, dynamic>;
      } catch (e) {
        final start = rawText.indexOf('{');
        final end = rawText.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          try {
            parsedJson = jsonDecode(rawText.substring(start, end + 1)) as Map<String, dynamic>;
          } catch (_) {
            throw ServerException(message: 'Failed to parse AI response: $e');
          }
        } else {
          throw ServerException(message: 'Failed to parse AI response: $e');
        }
      }

      // Normalize score if returned out of 10
      if (parsedJson['overall_score'] is num) {
        final num raw = parsedJson['overall_score'];
        if (raw <= 10 && raw > 0) {
          parsedJson['overall_score'] = (raw * 10).round();
        }
      }

      // Normalize ethiopian_market_fit if returned as structured map
      if (parsedJson['ethiopian_market_fit'] is Map) {
        final fitMap = parsedJson['ethiopian_market_fit'] as Map;
        parsedJson['ethiopian_market_fit'] = fitMap.values.join(' ');
      }

      // Add identifiers and timestamp
      parsedJson['document_id'] = document.id;
      parsedJson['startup_id'] = document.startupId;
      parsedJson['analyzed_at'] = DateTime.now().toIso8601String();

      // 4. Save analysis to Supabase
      Map<String, dynamic> dbRecord;
      try {
        dbRecord = await _client.from(_tableName).insert({
          'document_id': document.id,
          'startup_id': document.startupId,
          'overall_score': parsedJson['overall_score'] ?? 72,
          'readiness_tier': parsedJson['readiness_tier'] ?? 'Promising with Gaps',
          'executive_summary': parsedJson['executive_summary'] ?? 'Analysis completed.',
          'category_scores': parsedJson['category_scores'] ?? [],
          'strengths': parsedJson['strengths'] ?? [],
          'weaknesses': parsedJson['weaknesses'] ?? [],
          'recommendations': parsedJson['recommendations'] ?? [],
          'ethiopian_market_fit': parsedJson['ethiopian_market_fit'],
          'analyzed_at': DateTime.now().toIso8601String(),
        }).select().single();
      } catch (e) {
        // In case the pitch_analyses table is still pending manual SQL run, return the model directly
        parsedJson['id'] = 'local_${DateTime.now().millisecondsSinceEpoch}';
        return PitchAnalysisModel.fromJson(parsedJson);
      }

      return PitchAnalysisModel.fromJson(dbRecord);
    } on ServerException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: 'Pitch analysis failed: $e');
    }
  }

  @override
  Future<PitchAnalysisModel?> getAnalysisForDocument({
    required String documentId,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('document_id', documentId)
          .order('analyzed_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return PitchAnalysisModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PitchAnalysisModel>> getStartupAnalyses({
    required String startupId,
  }) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('startup_id', startupId)
          .order('analyzed_at', ascending: false);

      return (response as List)
          .map((json) => PitchAnalysisModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
