import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/widgets/dashboard_surface_card.dart';
import 'package:ethioventure/features/investor/presentation/widgets/startup_recommendation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StartupRecommendationCard extends StatelessWidget {
  final StartupRecommendation startup;
  final VoidCallback? onViewProfile;

  const StartupRecommendationCard({
    super.key,
    required this.startup,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Logo(url: startup.logoUrl, name: startup.name),
              const Spacer(),
              _MatchBadge(score: startup.matchScore),
            ],
          ),
          const SizedBox(height: 14),
          Text(startup.name, style: AppTextStyles.startupName),
          const SizedBox(height: 6),
          Text(
            startup.tagline,
            style: AppTextStyles.startupTagline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: startup.tags.map((t) => _TagChip(label: t)).toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? url;
  final String name;
  const _Logo({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(12),
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: url == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            )
          : null,
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final int score;
  const _MatchBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 3),
          Text('$score', style: AppTextStyles.matchScore),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.tag),
    );
  }
}