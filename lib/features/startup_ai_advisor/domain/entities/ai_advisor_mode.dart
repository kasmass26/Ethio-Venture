import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum AdvisorRole { founder, investor }

class PromptPreset {
  const PromptPreset({
    required this.title,
    required this.prompt,
    required this.icon,
    required this.category,
  });

  final String title;
  final String prompt;
  final IconData icon;
  final String category;
}

class AdvisorModeConfig {
  const AdvisorModeConfig({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.primaryColor,
    required this.softColor,
    required this.accentColor,
    required this.welcomeGreeting,
    required this.welcomeDescription,
    required this.categories,
    required this.presets,
  });

  final AdvisorRole role;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final Color primaryColor;
  final Color softColor;
  final Color accentColor;
  final String welcomeGreeting;
  final String welcomeDescription;
  final List<String> categories;
  final List<PromptPreset> presets;

  static const AdvisorModeConfig founderConfig = AdvisorModeConfig(
    role: AdvisorRole.founder,
    title: 'Founder Co-Pilot',
    subtitle: 'Fundraising, Valuation & Growth Advisor',
    badgeLabel: 'FOUNDER MODE',
    primaryColor: AppColors.primaryDark,
    softColor: AppColors.primarySoft,
    accentColor: AppColors.primary,
    welcomeGreeting: 'Welcome to your Startup Co-Pilot',
    welcomeDescription:
        'Ask anything about your pitch deck, valuation, unit economics, regulatory landscape, or winning investors in Ethiopia and Africa.',
    categories: [
      'All',
      'Pitch & Deck',
      'Valuation & Equity',
      'Unit Economics',
      'Ethiopian Market',
      'Growth & GTM',
    ],
    presets: [
      PromptPreset(
        title: 'Pitch Deck & Story',
        prompt:
            'How can I refine my 30-second elevator pitch and pitch deck structure to captivate angel investors?',
        icon: Icons.slideshow_rounded,
        category: 'Pitch & Deck',
      ),
      PromptPreset(
        title: 'Valuation & Equity Ask',
        prompt:
            'How should I calculate my pre-money valuation and determine how much equity to give away for a pre-seed round in East Africa?',
        icon: Icons.monetization_on_rounded,
        category: 'Valuation & Equity',
      ),
      PromptPreset(
        title: 'Unit Economics & Runway',
        prompt:
            'Walk me through calculating CAC, LTV, payback period, and managing our 18-month burn rate.',
        icon: Icons.query_stats_rounded,
        category: 'Unit Economics',
      ),
      PromptPreset(
        title: 'Ethiopian Regulations & NBE',
        prompt:
            'What regulatory guidelines, National Bank directives, or sandbox frameworks apply to tech startups in Ethiopia?',
        icon: Icons.account_balance_rounded,
        category: 'Ethiopian Market',
      ),
      PromptPreset(
        title: 'Zero-Dollar Growth Playbook',
        prompt:
            'Suggest a high-impact, 90-day organic customer acquisition and distribution strategy for our market.',
        icon: Icons.rocket_launch_rounded,
        category: 'Growth & GTM',
      ),
      PromptPreset(
        title: 'VC Objections & Answers',
        prompt:
            'What are the toughest objections venture capitalists will throw at my business model, and how should I answer?',
        icon: Icons.question_answer_rounded,
        category: 'Pitch & Deck',
      ),
    ],
  );

  static const AdvisorModeConfig investorConfig = AdvisorModeConfig(
    role: AdvisorRole.investor,
    title: 'Deal & DD Analyst',
    subtitle: 'Due Diligence, Red Flags & Investment Memos',
    badgeLabel: 'INVESTOR INTELLIGENCE',
    primaryColor: AppColors.violet,
    softColor: AppColors.violetTint,
    accentColor: AppColors.secondary,
    welcomeGreeting: 'Venture Capital Due Diligence Co-Pilot',
    welcomeDescription:
        'Screen startup fundamentals, evaluate valuation sanity, uncover red flags, draft investment memos, and benchmark against African venture metrics.',
    categories: [
      'All',
      'Due Diligence',
      'Red Flags & Risks',
      'Investment Memo',
      'Valuation Check',
      'Founder Questions',
    ],
    presets: [
      PromptPreset(
        title: 'Due Diligence Checklist',
        prompt:
            'Generate a thorough 12-point due diligence checklist tailored to this startup sector, team, and funding stage.',
        icon: Icons.fact_check_rounded,
        category: 'Due Diligence',
      ),
      PromptPreset(
        title: 'Red Flag & Risk Screen',
        prompt:
            'What are potential red flags, defensibility flaws, cap table traps, or market risks with this startup?',
        icon: Icons.warning_amber_rounded,
        category: 'Red Flags & Risks',
      ),
      PromptPreset(
        title: 'Draft Investment Memo',
        prompt:
            'Draft a concise VC investment memo structure with Executive Summary, Bull Case, Bear Case, Moat, and Return Potential.',
        icon: Icons.description_rounded,
        category: 'Investment Memo',
      ),
      PromptPreset(
        title: 'Founder Interview Questions',
        prompt:
            'What 7 sharp, probing questions should I ask the founder during our next partner meeting to test execution capability?',
        icon: Icons.contact_support_rounded,
        category: 'Founder Questions',
      ),
      PromptPreset(
        title: 'Valuation & Benchmarks',
        prompt:
            'Evaluate whether this startup valuation and funding ask are reasonable compared to contemporary African seed benchmarks.',
        icon: Icons.balance_rounded,
        category: 'Valuation Check',
      ),
      PromptPreset(
        title: 'Market Sizing & Moat',
        prompt:
            'Stress-test the TAM/SAM/SOM claims. Does this startup have a real defensible moat against local and international giants?',
        icon: Icons.shield_rounded,
        category: 'Due Diligence',
      ),
    ],
  );

  static AdvisorModeConfig fromRole(String role) {
    if (role.toLowerCase() == 'investor') {
      return investorConfig;
    }
    return founderConfig;
  }
}
