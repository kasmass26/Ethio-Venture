import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethioventure/core/theme/app_colors.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/pitch_analysis_entity.dart';
import '../cubit/pitch_analysis_cubit.dart';
import '../cubit/pitch_analysis_state.dart';

class PitchAnalysisDialog extends StatefulWidget {
  const PitchAnalysisDialog({
    super.key,
    required this.document,
    this.startupSector,
    this.startupStage,
  });

  final DocumentEntity document;
  final String? startupSector;
  final String? startupStage;

  static void show(
    BuildContext context, {
    required DocumentEntity document,
    String? startupSector,
    String? startupStage,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PitchAnalysisDialog(
        document: document,
        startupSector: startupSector,
        startupStage: startupStage,
      ),
    );
  }

  @override
  State<PitchAnalysisDialog> createState() => _PitchAnalysisDialogState();
}

class _PitchAnalysisDialogState extends State<PitchAnalysisDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch previous analysis or run new analysis
    context.read<PitchAnalysisCubit>().fetchAnalysis(documentId: widget.document.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.coral;
  }

  Color _getPriorityColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return AppColors.coral;
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.violet],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Pitch Deck Evaluation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        widget.document.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.slate),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Body Content with Cubit States
          Expanded(
            child: BlocBuilder<PitchAnalysisCubit, PitchAnalysisState>(
              builder: (context, state) {
                if (state is PitchAnalysisLoading) {
                  return _buildLoadingState(state.message);
                }

                if (state is PitchAnalysisNotFound) {
                  return _buildNotAnalyzedYetState(context);
                }

                if (state is PitchAnalysisError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is PitchAnalysisLoaded) {
                  return _buildLoadedReport(context, state.analysis);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gemini AI is reviewing business model, market opportunity, and slides against venture capital benchmarks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.slate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAnalyzedYetState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.secondarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Pitch Analysis Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get instant AI feedback, score rubric, key strengths, red flags, and slide-by-slide recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.slate),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PitchAnalysisCubit>().analyzePitchDeck(
                      document: widget.document,
                      startupSector: widget.startupSector,
                      startupStage: widget.startupStage,
                    );
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Analyze Pitch Deck with AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.coral),
            const SizedBox(height: 16),
            const Text(
              'Analysis Could Not Be Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.slate),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PitchAnalysisCubit>().analyzePitchDeck(
                      document: widget.document,
                      startupSector: widget.startupSector,
                      startupStage: widget.startupStage,
                    );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedReport(BuildContext context, PitchAnalysisEntity analysis) {
    final scoreColor = _getScoreColor(analysis.overallScore);

    return Column(
      children: [
        // Hero Score Header Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondarySoft,
                AppColors.primarySoft.withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Circular Score
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: analysis.overallScore / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${analysis.overallScore}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        analysis.readinessTier.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      analysis.executiveSummary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.slate,
          indicatorColor: AppColors.primaryDark,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Suggestions'),
            Tab(text: 'Pros & Cons'),
            Tab(text: 'Ethiopia Fit'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoriesTab(analysis),
              _buildSuggestionsTab(analysis),
              _buildProsConsTab(analysis),
              _buildEthiopiaFitTab(analysis),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evaluated: ${_formatDate(analysis.analyzedAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.slate),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<PitchAnalysisCubit>().analyzePitchDeck(
                        document: widget.document,
                        startupSector: widget.startupSector,
                        startupStage: widget.startupStage,
                      );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Re-evaluate Deck'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(PitchAnalysisEntity analysis) {
    if (analysis.categoryScores.isEmpty) {
      return const Center(child: Text('No category breakdown available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.categoryScores.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = analysis.categoryScores[index];
        final catColor = _getScoreColor(cat.score);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.fog),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cat.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${cat.score} / 100',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: catColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: cat.score / 100,
                  backgroundColor: AppColors.fog,
                  valueColor: AlwaysStoppedAnimation<Color>(catColor),
                  minHeight: 6,
                ),
              ),
              if (cat.feedback.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  cat.feedback,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsTab(PitchAnalysisEntity analysis) {
    if (analysis.recommendations.isEmpty) {
      return const Center(child: Text('No recommendations provided.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.recommendations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final rec = analysis.recommendations[index];
        final impactColor = _getPriorityColor(rec.impactLevel);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.fog),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: impactColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${rec.impactLevel.toUpperCase()} PRIORITY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: impactColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (rec.targetSlide != null && rec.targetSlide!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rec.targetSlide!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    rec.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rec.suggestion,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProsConsTab(PitchAnalysisEntity analysis) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🌟 Key Strengths for Investors',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 10),
        ...analysis.strengths.map((str) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successSoft.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      str,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),
        const Text(
          '⚠️ Critical Gaps & Red Flags',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 10),
        ...analysis.weaknesses.map((weak) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSoft.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.coral, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      weak,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEthiopiaFitTab(PitchAnalysisEntity analysis) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySoft.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🇪🇹', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    'Ethiopian Market Readiness',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                analysis.ethiopianMarketFit ??
                    'This startup exhibits relevant potential for the Ethiopian tech ecosystem. Consider ensuring clear integrations with local digital payment rails (Telebirr, Chapa) and adherence to local business registration frameworks.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
