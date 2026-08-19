import 'package:flutter/material.dart';

/// Tone of the delta line under a stat (green/gray/red in the UI).
enum DeltaTone { positive, neutral, warning }

/// A single top-row stat card (Active Deals, Startups Tracked, Unread Messages).
class InvestorMetric {
  final String label;
  final String value;
  final String deltaText;
  final DeltaTone tone;
  final IconData icon;

  const InvestorMetric({
    required this.label,
    required this.value,
    required this.deltaText,
    required this.tone,
    required this.icon,
  });
}