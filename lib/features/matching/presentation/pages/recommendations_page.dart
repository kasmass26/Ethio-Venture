import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/recommendations_cubit.dart';
import '../cubit/recommendations_state.dart';
import '../widgets/investor_preference_dialog.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsPage extends StatefulWidget {
  final String userId;

  const RecommendationsPage({super.key, this.userId = 'investor_101'});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsCubit>().fetchRecommendations(widget.userId);
    });
  }

  void _openPreferenceDialog() {
    final cubit = context.read<RecommendationsCubit>();
    showDialog(
      context: context,
      builder: (ctx) => InvestorPreferenceDialog(
        currentPreferences: cubit.currentPreferences,
        onSavePreferences: (updatedPrefs) {
          cubit.updatePreferences(widget.userId, updatedPrefs);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Adjust AI Preferences',
            onPressed: _openPreferenceDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AI Matching Header Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    isDark ? const Color(0xFF2D6A4F) : const Color(0xFF52796F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Smart Investment Matching',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Personalized startup deals ranked by your strategy',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _openPreferenceDialog,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Edit Criteria'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Recommendations List View
            Expanded(
              child: BlocBuilder<RecommendationsCubit, RecommendationsState>(
                builder: (context, state) {
                  if (state is RecommendationsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is RecommendationsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<RecommendationsCubit>()
                                  .fetchRecommendations(widget.userId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is RecommendationsLoaded) {
                    final recommendations = state.recommendations;

                    if (recommendations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sentiment_dissatisfied,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No matching recommendations found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try broadening your investor preference parameters.',
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _openPreferenceDialog,
                              child: const Text('Tune Preferences'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<RecommendationsCubit>()
                            .fetchRecommendations(widget.userId);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final item = recommendations[index];
                          return RecommendationCard(
                            recommendation: item,
                            onPitchDeckTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening Pitch Deck for ${item.startup.name}...',
                                  ),
                                ),
                              );
                            },
                            onMessageTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Starting message with ${item.startup.founderName} (${item.startup.name})...',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
