import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../../startup_profile/domain/entities/startup_profile_entity.dart';

abstract interface class StartupAiAdvisorRemoteDataSource {
  Future<AiChatMessage> generateAdvisorResponse({
    required String prompt,
    required String roleMode,
    StartupProfileEntity? startupContext,
    List<AiChatMessage> conversationHistory = const [],
  });
}

class StartupAiAdvisorRemoteDataSourceImpl implements StartupAiAdvisorRemoteDataSource {
  const StartupAiAdvisorRemoteDataSourceImpl();

  @override
  Future<AiChatMessage> generateAdvisorResponse({
    required String prompt,
    required String roleMode,
    StartupProfileEntity? startupContext,
    List<AiChatMessage> conversationHistory = const [],
  }) async {
    final apiKey = dotenv.isInitialized
        ? (dotenv.env['GEMINI_API_KEY']?.trim() ?? '')
        : '';
    final isFounder = roleMode.toLowerCase() != 'investor';

    // If API key is available and valid, call Google Gemini 1.5 Flash
    if (apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY') {
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.4,
          ),
        );

        final systemInstruction = _buildSystemPrompt(
          isFounder: isFounder,
          startup: startupContext,
        );

        // Build history
        final historyContext = conversationHistory.take(6).map((m) {
          final sender = m.isUser ? 'User' : 'Advisor';
          return '$sender: ${m.content}';
        }).join('\n');

        final fullPrompt = '''
$systemInstruction

${historyContext.isNotEmpty ? 'Previous Conversation:\n$historyContext\n' : ''}
Current User Prompt:
"$prompt"

Respond strictly with valid JSON following this format:
{
  "content": "Your rich, formatted markdown answer here. Use ## Headings, bold text, bullet points, and clear explanations.",
  "keyTakeaways": ["Key takeaway 1", "Key takeaway 2", "Key takeaway 3"],
  "actionItems": ["Actionable next step 1", "Actionable next step 2", "Actionable next step 3"],
  "suggestedFollowUps": ["Smart follow up question 1?", "Smart follow up question 2?", "Smart follow up question 3?"]
}
''';

        final response = await model.generateContent([Content.text(fullPrompt)]);
        final text = response.text;

        if (text != null && text.trim().isNotEmpty) {
          final jsonMap = _parseJsonResponse(text);
          if (jsonMap != null) {
            return AiChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: jsonMap['content']?.toString() ?? text,
              isUser: false,
              timestamp: DateTime.now(),
              roleMode: roleMode,
              startupName: startupContext?.startupName,
              suggestedFollowUps: (jsonMap['suggestedFollowUps'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  _defaultFollowUps(isFounder),
              keyTakeaways: (jsonMap['keyTakeaways'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              actionItems: (jsonMap['actionItems'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
            );
          }
        }
      } catch (_) {
        // Fall back gracefully to internal tailored domain engine if Gemini fails or rate limits
      }
    }

    // High-quality contextual fallback engine
    return _generateContextualFallback(
      prompt: prompt,
      isFounder: isFounder,
      startup: startupContext,
      roleMode: roleMode,
    );
  }

  String _buildSystemPrompt({
    required bool isFounder,
    StartupProfileEntity? startup,
  }) {
    final startupInfo = startup != null
        ? '''
Active Startup Context:
- Name: ${startup.startupName}
- Industry: ${startup.industry}
- Funding Stage: ${startup.fundingStage}
- Capital Target: \$${startup.fundingAmountNeeded.toStringAsFixed(0)} USD
- Location: ${startup.location}
- Description: ${startup.description}
- Team: ${startup.teamInformation}
'''
        : 'Active Startup Context: General query or startup not yet specified.';

    if (isFounder) {
      return '''
You are the senior startup mentor, venture builder, and VC co-pilot on EthioVenture, Ethiopia's premier startup platform.
Your user is a STARTUP FOUNDER.
Your goal is to help them win investors, perfect their pitch, optimize unit economics, navigate Ethiopian market realities (NBE directives, mobile money, FX rules, talent), and scale sustainably.
Tone: Encouraging, razor-sharp, strategic, and practical.
Avoid vague platitudes; give numbers, formulas, examples, and step-by-step tactics.
$startupInfo
''';
    } else {
      return '''
You are the senior Venture Capital Investment Director and Due Diligence Analyst on EthioVenture.
Your user is an INVESTOR (Angel, Syndicate Member, or VC Fund Manager).
Your goal is to help them evaluate startups with healthy skepticism, uncover hidden red flags, verify valuation & cap table terms, stress-test TAM/moat, benchmark unit economics in Africa, and draft investment memos.
Tone: Objective, analytical, rigorous, and metric-driven.
$startupInfo
''';
    }
  }

  Map<String, dynamic>? _parseJsonResponse(String text) {
    try {
      final trimmed = text.trim();
      var clean = trimmed;
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      } else if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }
      clean = clean.trim();
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  AiChatMessage _generateContextualFallback({
    required String prompt,
    required bool isFounder,
    required StartupProfileEntity? startup,
    required String roleMode,
  }) {
    final lower = prompt.toLowerCase();
    final name = startup?.startupName ?? 'Your Startup';
    final industry = startup?.industry ?? 'Technology';
    final stage = startup?.fundingStage ?? 'Early Stage';
    final askAmount = startup != null
        ? '\$${startup.fundingAmountNeeded.toStringAsFixed(0)}'
        : 'your funding target';

    String content = '';
    List<String> keyTakeaways = [];
    List<String> actionItems = [];
    List<String> suggestedFollowUps = [];

    if (isFounder) {
      // FOUNDER MODE TAILORED LOGIC
      if (lower.contains('pitch') || lower.contains('deck') || lower.contains('elevator')) {
        content = '''
## 🎯 High-Impact Pitch Strategy for $name

To win institutional investors and angel syndicates in Ethiopia and East Africa, structure your pitch around **The 5 Uncompromising Pillars**:

1. **The Urgent Pain Point (First 20 Seconds)**:
   Clearly frame the customer friction in $industry. Frame it in tangible terms: hours wasted, revenue lost, or manual operational friction.

2. **The Proprietary Solution**:
   Explain how $name solves this with 10x better speed, cost, or accessibility. Emphasize why competitors cannot easily clone this.

3. **Demonstrated Traction & Velocity**:
   Investors care about growth trajectory. Highlight user growth, retention rate, pilot partnerships, or GMV.

4. **Unit Economics & Business Model**:
   State your revenue streams clearly. How much does a customer pay, and how frequently?

5. **The Ask & 18-Month Milestones**:
   You are raising $askAmount at the $stage stage. Explicitly detail how this capital gets you to key de-risking milestones (e.g. 5x active users, breakeven, or Series A readiness).
''';
        keyTakeaways = [
          'Lead with quantifiable customer pain within the first 20 seconds.',
          'Emphasize local execution moat and defensibility.',
          'Tie the $askAmount ask directly to measurable 18-month milestones.',
        ];
        actionItems = [
          'Draft a 60-second elevator pitch using the "Problem-Solution-Traction" formula.',
          'Condense your pitch deck to 10-12 slides maximum.',
          'Practice handling the top 3 investor pushbacks on customer acquisition.',
        ];
        suggestedFollowUps = [
          'What are the 10 essential slides every VC expects to see?',
          'How do I answer "What if Safaricom or Telebirr builds this?"',
          'How can I demonstrate traction with early pilot users?',
        ];
      } else if (lower.contains('valuat') || lower.contains('equity') || lower.contains('price')) {
        content = '''
## 💰 Valuation & Equity Framework ($stage Stage)

Pricing an early-stage venture in $industry requires balancing founder motivation with investor return multiples:

### 1. Regional Benchmarks in East Africa
- **Pre-Seed**: Typical valuations range from **\$500k to \$1.5M pre-money**, with dilution typically between **10% – 18%**.
- **Seed Round**: Typically **\$1.5M to \$4.5M pre-money**, targeting **15% – 20%** dilution.
- If raising **$askAmount**, avoid diluting more than **15% - 20%** in a single round to prevent cap table fatigue by Series A.

### 2. The Berkus / Scorecard Valuation Method
For pre-revenue or early-revenue startups, investors value:
- **Founding Team Execution Capability** (30%)
- **Product Working Prototype & IP** (25%)
- **Strategic Partnerships & Distribution** (20%)
- **Addressable Market Size (TAM)** (25%)

### 3. SAFE vs Priced Round Recommendation
Use a **Post-Money SAFE (Simple Agreement for Future Equity)** with a Valuation Cap and 20% Discount. This avoids lengthy negotiations over exact equity percentages until your next priced institutional round.
''';
        keyTakeaways = [
          'Aim to keep total dilution in this round under 15% – 20%.',
          'Use a SAFE with a Valuation Cap to minimize legal complexity.',
          'Valuation is determined by traction velocity and team credibility, not just revenue.',
        ];
        actionItems = [
          'Calculate your 18-month cash runway needs before fixing the valuation cap.',
          'Prepare a clean Cap Table showing post-round ownership percentages.',
          'Benchmark your valuation against similar African deals on Disrupt Africa / Partech.',
        ];
        suggestedFollowUps = [
          'How do SAFE notes work for Ethiopian founders?',
          'What is a fair Employee Stock Option Pool (ESOP) size?',
          'How do I calculate pre-money vs post-money valuation?',
        ];
      } else if (lower.contains('unit') || lower.contains('cac') || lower.contains('ltv') || lower.contains('runway')) {
        content = '''
## 📊 Unit Economics & Runway Blueprint

Sustainable unit economics are the #1 thing modern VCs look for when evaluating $industry startups:

### 1. Key Metrics to Track
- **CAC (Customer Acquisition Cost)**: Total Sales & Marketing Spend ÷ Number of New Customers Acquired.
- **LTV (Lifetime Value)**: (Average Order Value × Purchase Frequency × Gross Margin) ÷ Customer Churn Rate.
- **Golden Rule**: **LTV / CAC ≥ 3.0x** (Every \$1 spent on acquisition should return at least \$3 in gross profit over lifetime).
- **CAC Payback Period**: Target **under 9 to 12 months** for healthy cash velocity.

### 2. Runway & Burn Management
- **Net Burn Rate**: Monthly Cash Outflows minus Monthly Cash Inflows.
- **Runway in Months**: Total Cash Balance ÷ Net Monthly Burn.
- **Target**: Maintain at least **14 to 18 months of runway** when closing your round. Never start fundraising with under 6 months of cash remaining.
''';
        keyTakeaways = [
          'Target an LTV / CAC ratio of at least 3.0x.',
          'Keep your CAC payback period under 12 months.',
          'Always budget for at least 15 months of runway post-funding.',
        ];
        actionItems = [
          'Segment CAC by marketing channel to identify the most cost-effective acquisition route.',
          'Build a 24-month financial model with realistic headcount and server costs.',
          'Track monthly gross revenue churn vs net revenue retention.',
        ];
        suggestedFollowUps = [
          'How can I lower our customer acquisition cost in Addis Ababa?',
          'What unit economics do fintech investors expect in Africa?',
          'How do I model hiring plans without burning through our runway?',
        ];
      } else {
        // General founder advice
        content = '''
## 🚀 Strategic Founder Guidance for $name

Here is an executive breakdown tailored for your journey in **$industry** at the **$stage** stage:

### 1. Core Focus: Product-Market Fit (PMF)
Before scaling paid marketing, verify your retention curve. If 40%+ of your pilot users say they would be "very disappointed" if $name disappeared, you have strong initial PMF.

### 2. Local Market Distribution
In Ethiopia and East Africa, distribution is often harder than product development. Partner with established distribution channels, trade associations, or payment aggregators (e.g. Telebirr, CBE Birr) to scale with low capital intensity.

### 3. Investor Readiness
When pitching investors on EthioVenture:
- Be transparent about regulatory dependencies and operational bottlenecks.
- Show a clear path to profitability or unit-level positive contribution margin.
- Highlight team resilience and domain expertise in $industry.
''';
        keyTakeaways = [
          'Focus relentlessly on customer retention before pouring money into acquisition.',
          'Leverage local payment and distribution partnerships to accelerate adoption.',
          'Maintain a proactive pipeline of at least 15-20 interested angel investors.',
        ];
        actionItems = [
          'Conduct 10 in-depth customer interviews this week to test your core value proposition.',
          'Refine your one-page Executive Pitch Summary on your EthioVenture profile.',
          'Map your key competitors and specify your distinct moat.',
        ];
        suggestedFollowUps = [
          'How do I find and connect with angel investors on EthioVenture?',
          'What regulatory considerations should $name know about in Ethiopia?',
          'How can I improve my 30-second elevator pitch?',
        ];
      }
    } else {
      // INVESTOR MODE TAILORED LOGIC
      if (lower.contains('diligence') || lower.contains('checklist') || lower.contains('dd')) {
        content = '''
## 🔍 12-Point Due Diligence Checklist for $name

When conducting due diligence on an early-stage startup in **$industry** ($stage stage), apply this systematic diligence framework:

### I. Market & Competitive Defensibility (Weight: 25%)
1. **TAM Reality Check**: Is the realistic addressable market in Ethiopia/East Africa large enough to support a \$10M+ ARR exit?
2. **Moat Assessment**: Does the startup have proprietary data, high switching costs, or network effects that prevent replication?
3. **Competitive Landscape**: Who are the informal/incumbent players, and why haven't they dominated this niche?

### II. Team & Governance (Weight: 30%)
4. **Founder-Market Fit**: Do the founders have operational domain expertise or technical depth in $industry?
5. **Equity Distribution**: Do active founders hold at least 70%+ of equity pre-round? Are inactive advisors over-allocated?
6. **Integrity & References**: Background checks, previous venture outcomes, and cross-founder relationship stability.

### III. Financial & Operational Traction (Weight: 25%)
7. **Quality of Revenue**: Are transactions recurring or one-off pilot contracts? What is the churn rate?
8. **Unit Economics**: Is the gross margin healthy (60%+ for pure software, 25%+ for tech-enabled logistics)?
9. **Burn Multiplier**: How efficiently does the team convert net cash burn into ARR growth?

### IV. Regulatory & Legal Hygiene (Weight: 20%)
10. **Regulatory Compliance**: Clear standing with National Bank of Ethiopia, Ministry of Innovation & Technology, and tax authorities.
11. **IP Assignment**: Are all codebases, patents, and trademarks irrevocably assigned to the corporate entity?
12. **Cap Table Structure**: No predatory convertible notes, hidden warrants, or uncapped valuation debts.
''';
        keyTakeaways = [
          'Verify that active founders retain sufficient equity to stay incentivized for 7-10 years.',
          'Scrutinize recurring user retention vs vanity registration numbers.',
          'Ensure all intellectual property and core assets are formally owned by the company.',
        ];
        actionItems = [
          'Request the data room: cap table, customer contracts, and 12-month bank statements.',
          'Conduct 2 blind reference calls with former colleagues or customers of the founders.',
          'Verify legal entity status and tax clearance certificates.',
        ];
        suggestedFollowUps = [
          'What are the primary red flags in early-stage African tech investments?',
          'How should I structure the term sheet liquidation preference and board seats?',
          'Draft an investment memo for $name.',
        ];
      } else if (lower.contains('red flag') || lower.contains('risk') || lower.contains('flaw')) {
        content = '''
## 🚩 Risk Assessment & Red Flag Screening for $name

Carefully probe the following vulnerability vectors in **$industry**:

### 1. The "Cap Table Trap"
- **Red Flag**: If non-operational founders, university incubators, or passive advisors hold more than 20% of equity pre-seed, future VCs will likely pass due to incentive misalignment.
- **Mitigation**: Require a cap table reorganization or vesting reset before funding.

### 2. Vanity Metrics vs Repeat Retention
- **Red Flag**: Celebrating registered accounts or app downloads while 30-day cohort retention is under 15%.
- **Investigation**: Insist on reviewing monthly cohort retention curves and organic repeat transaction frequency.

### 3. FX and Regulatory Bottlenecks in Ethiopia
- **Red Flag**: Over-dependence on foreign software subscriptions, hardware imports, or international repatriation without clear foreign currency strategy.
- **Investigation**: Check how the startup utilizes local payment rails (Telebirr, CBE Birr) and complies with NBE capital directives.

### 4. Over-optimistic TAM / Unit Economics
- **Red Flag**: Assuming 100% of the Ethiopian market will adopt digital services without accounting for offline agent networks or high smartphone data costs.
''';
        keyTakeaways = [
          'Inspect cohort retention curves rather than top-line registered user growth.',
          'Ensure the cap table leaves room for 2-3 future institutional funding rounds.',
          'Stress-test local currency exposure and operational FX requirements.',
        ];
        actionItems = [
          'Ask for monthly retention cohort tables (M1, M3, M6, M12).',
          'Review founder employment agreements for non-compete and IP assignment clauses.',
          'Quantify foreign currency requirements in their 24-month financial forecast.',
        ];
        suggestedFollowUps = [
          'What due diligence questions should I ask the founder?',
          'Evaluate valuation benchmarks for $industry in East Africa.',
          'Generate a term sheet checklist for this deal.',
        ];
      } else if (lower.contains('memo') || lower.contains('thesis') || lower.contains('summary')) {
        content = '''
## 📝 Investment Memo Outline: $name

### I. Executive Summary
- **Company**: $name
- **Sector**: $industry | **Stage**: $stage
- **Capital Raise**: $askAmount
- **Investment Thesis**: Strong early-mover advantage in addressing high-friction $industry inefficiencies in Ethiopia with a scalable tech platform.

### II. Market Opportunity & Sizing
- **Macro Tailwinds**: Increasing digital adoption, national payment infrastructure modernization, and expanding internet penetration.
- **TAM / SAM**: Multi-billion birr market currently dominated by fragmented, manual legacy processes.

### III. The Bull Case (Why This Wins 10x)
- Founder execution velocity and proprietary distribution relationships.
- High switching costs once integrated into customer workflows.
- Scalable beyond Ethiopia into regional COMESA and East African markets.

### IV. The Bear Case & Downside Risks
- Slower than anticipated enterprise/consumer digital transition.
- Regulatory changes or delay in licensing.
- Cash burn if customer acquisition costs escalate.

### V. Proposed Investment Terms
- **Instrument**: SAFE with Valuation Cap or Priced Preferred Equity.
- **Information Rights**: Quarterly financial statements and monthly KPI dashboards.
- **Board Observer / Advisory Role**: Recommended for strategic guidance.
''';
        keyTakeaways = [
          'Strong investment thesis supported by macro digital modernization in Ethiopia.',
          'Key risk lies in customer adoption cycle and distribution scale.',
          'Secure quarterly information rights and protective minority provisions.',
        ];
        actionItems = [
          'Review the startup\'s historical revenue run-rate and gross margins.',
          'Confirm syndicate allocation size and co-investor participation.',
          'Issue preliminary term sheet with standard 30-day exclusivity.',
        ];
        suggestedFollowUps = [
          'What questions should I ask during partner meeting diligence?',
          'What are standard investor rights in African early-stage deals?',
          'Run a red flag screen for $name.',
        ];
      } else {
        // General investor intelligence
        content = '''
## 💼 Deal Intelligence & Screening for $name

Here is an institutional evaluation framework for **$name** ($industry, $stage stage):

### 1. Investment Fit & Sector Dynamics
$industry in Ethiopia presents significant upside due to high barriers to entry and strong secular growth. Evaluate whether $name is a tech company or a tech-enabled service business—this dictates the appropriate valuation multiple (software typically commands 5x-10x ARR, while services trade at 1x-3x).

### 2. Defensibility & Execution Moat
In frontier markets, technology alone is rarely the moat. The true moat is **distribution access, regulatory integration, and customer lock-in**. Examine how tightly $name is integrated into local financial or supply chain pipelines.

### 3. Valuation & Capital Efficiency
With a target raise of **$askAmount**, assess whether this provides at least **18 months of operational runway** to reach clear Series A or profitability milestones.
''';
        keyTakeaways = [
          'Distinguish between high-margin software scalability and operationally intensive models.',
          'Look for distribution partnerships and regulatory moats as the primary defense.',
          'Verify that $askAmount provides adequate runway to de-risk key milestones.',
        ];
        actionItems = [
          'Check founder background and previous venture history on EthioVenture.',
          'Assess the realism of customer lifetime value relative to churn rate.',
          'Prepare your partner questions focusing on unit economics and scaling bottlenecks.',
        ];
        suggestedFollowUps = [
          'Generate a 12-point due diligence checklist for $name.',
          'What are potential red flags in this business model?',
          'Draft an investment memo outline for this deal.',
        ];
      }
    }

    return AiChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      roleMode: roleMode,
      startupName: startup?.startupName,
      suggestedFollowUps: suggestedFollowUps,
      keyTakeaways: keyTakeaways,
      actionItems: actionItems,
    );
  }

  List<String> _defaultFollowUps(bool isFounder) {
    if (isFounder) {
      return [
        'How can I improve my 30-second elevator pitch?',
        'How do I calculate pre-money valuation for pre-seed?',
        'What metrics do angel investors look for in Africa?',
      ];
    }
    return [
      'Generate a 12-point due diligence checklist.',
      'What are potential red flags in this business model?',
      'Draft an investment memo outline for this deal.',
    ];
  }
}
