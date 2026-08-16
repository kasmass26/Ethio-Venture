import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'recommendations_page.dart';
import 'startup_search_page.dart';

class MatchingMainPage extends StatelessWidget {
  const MatchingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ethio Venture Matching',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.search_rounded), text: 'Search & Filter'),
              Tab(
                icon: Icon(Icons.auto_awesome_rounded),
                text: 'AI Recommendations',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [StartupSearchPage(), RecommendationsPage()],
        ),
      ),
    );
  }
}
