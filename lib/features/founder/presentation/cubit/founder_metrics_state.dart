import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../pages/founder_dashboard_page.dart';

abstract class FounderMetricsState extends Equatable {
  const FounderMetricsState();

  @override
  List<Object?> get props => [];
}

class FounderMetricsInitial extends FounderMetricsState {
  const FounderMetricsInitial();
}

class FounderMetricsLoading extends FounderMetricsState {
  const FounderMetricsLoading();
}

class FounderMetricsLoaded extends FounderMetricsState {
  final List<DashboardMetric> metrics;
  final List<IconData> icons;

  const FounderMetricsLoaded({
    required this.metrics,
    required this.icons,
  });

  @override
  List<Object?> get props => [metrics, icons];
}

class FounderMetricsError extends FounderMetricsState {
  final String message;

  const FounderMetricsError(this.message);

  @override
  List<Object?> get props => [message];
}
