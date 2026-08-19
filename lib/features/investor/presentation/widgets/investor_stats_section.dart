import 'package:ethioventure/features/investor/presentation/widgets/investor_metric.dart';
import 'package:ethioventure/features/investor/presentation/widgets/investor_stats_card.dart';
import 'package:flutter/material.dart';


class InvestorStatsSection extends StatelessWidget {
  final List<InvestorMetric> metrics;

  const InvestorStatsSection({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(metrics.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InvestorStatCard(metric: metrics[i]),
        );
      }),
    );
  }
}