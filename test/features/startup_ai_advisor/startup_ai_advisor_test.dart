import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/features/startup_ai_advisor/domain/entities/ai_advisor_mode.dart';
import 'package:ethioventure/features/startup_ai_advisor/domain/entities/ai_chat_message.dart';
import 'package:ethioventure/features/startup_ai_advisor/data/datasources/startup_ai_advisor_remote_data_source.dart';
import 'package:ethioventure/features/startup_profile/domain/entities/startup_profile_entity.dart';

void main() {
  group('StartupAiAdvisor Domain & Data Tests', () {
    const dataSource = StartupAiAdvisorRemoteDataSourceImpl();

    final testStartup = StartupProfileEntity(
      id: 'startup-123',
      userId: 'founder-456',
      startupName: 'EthioFin Tech',
      description: 'Digital payments and micro-lending infrastructure.',
      industry: 'FinTech',
      fundingStage: 'Pre-Seed',
      fundingAmountNeeded: 150000,
      location: 'Addis Ababa',
      teamInformation: '3 Co-founders with banking & engineering background.',
      contactInformation: 'contact@ethiofin.et',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Mode configs provide correct role definitions and presets', () {
      final founderConfig = AdvisorModeConfig.fromRole('founder');
      expect(founderConfig.role, AdvisorRole.founder);
      expect(founderConfig.title, 'Founder Co-Pilot');
      expect(founderConfig.presets.isNotEmpty, true);

      final investorConfig = AdvisorModeConfig.fromRole('investor');
      expect(investorConfig.role, AdvisorRole.investor);
      expect(investorConfig.title, 'Deal & DD Analyst');
      expect(investorConfig.presets.isNotEmpty, true);
    });

    test('Founder query returns tailored co-pilot advice with action items and takeaways', () async {
      final response = await dataSource.generateAdvisorResponse(
        prompt: 'How can I calculate our pre-seed valuation and equity ask?',
        roleMode: 'founder',
        startupContext: testStartup,
      );

      expect(response.isUser, false);
      expect(response.roleMode, 'founder');
      expect(response.startupName, 'EthioFin Tech');
      expect(response.content.contains('Valuation'), true);
      expect(response.keyTakeaways.isNotEmpty, true);
      expect(response.actionItems.isNotEmpty, true);
      expect(response.suggestedFollowUps.isNotEmpty, true);
    });

    test('Investor query returns tailored due diligence checklist and red flag analysis', () async {
      final response = await dataSource.generateAdvisorResponse(
        prompt: 'Provide a due diligence checklist and red flag analysis for this startup.',
        roleMode: 'investor',
        startupContext: testStartup,
      );

      expect(response.isUser, false);
      expect(response.roleMode, 'investor');
      expect(response.startupName, 'EthioFin Tech');
      expect(response.content.contains('Due Diligence') || response.content.contains('Checklist'), true);
      expect(response.keyTakeaways.isNotEmpty, true);
      expect(response.actionItems.isNotEmpty, true);
      expect(response.suggestedFollowUps.isNotEmpty, true);
    });

    test('AiChatMessage copyWith works accurately', () {
      final original = AiChatMessage(
        id: 'msg-1',
        content: 'Hello',
        isUser: true,
        timestamp: DateTime(2026, 1, 1),
        roleMode: 'founder',
      );

      final modified = original.copyWith(content: 'Updated content');
      expect(modified.content, 'Updated content');
      expect(modified.isUser, true);
      expect(modified.id, 'msg-1');
    });
  });
}
