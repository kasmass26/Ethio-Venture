import 'package:ethioventure/features/founder/presentation/pages/founder_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'metric_card.dart';

class MetricsSection extends StatelessWidget {
  final List<DashboardMetric> metrics;
  final List<IconData> icons;

  const MetricsSection({super.key, required this.metrics, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(metrics.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MetricCard(icon: icons[i], metric: metrics[i]),
        );
      }),
    );
  }
}