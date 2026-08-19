import 'package:ethioventure/features/investor/presentation/widgets/startup_recommendation.dart';
import 'package:ethioventure/features/investor/presentation/widgets/startup_recommendation_card.dart';
import 'package:flutter/material.dart';

import 'section_header.dart';


class RecommendedStartupsSection extends StatelessWidget {
  final List<StartupRecommendation> startups;
  final VoidCallback? onViewAll;
  final ValueChanged<StartupRecommendation>? onViewProfile;

  const RecommendedStartupsSection({
    super.key,
    required this.startups,
    this.onViewAll,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommended for You',
          actionLabel: 'View All',
          showArrow: true,
          onActionTap: onViewAll,
        ),
        SizedBox(
          height: 328,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: startups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final startup = startups[index];
              return SizedBox(
                width: 268,
                child: StartupRecommendationCard(
                  startup: startup,
                  onViewProfile: () => onViewProfile?.call(startup),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}