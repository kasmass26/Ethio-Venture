import 'package:ethioventure/core/constants/app_styles.dart';
import 'package:ethioventure/features/founder/presentation/pages/founder_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'investor_card.dart';

class RecommendedInvestorsSection extends StatelessWidget {
  final List<Investor> investors;
  final ValueChanged<Investor>? onViewProfile;

  const RecommendedInvestorsSection({
    super.key,
    required this.investors,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: Text('Recommended Investors', style: AppTextStyles.sectionTitle),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            'Based on your industry and Seed stage.',
            style: AppTextStyles.subtitle,
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: investors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final investor = investors[index];
              return InvestorCard(
                investor: investor,
                onViewProfile: () => onViewProfile?.call(investor),
              );
            },
          ),
        ),
      ],
    );
  }
}