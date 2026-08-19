import 'package:flutter/material.dart';

enum ActivityKind { document, meeting, milestone }

/// One row in the "Recent Activity" feed.
class ActivityItem {
  final String actorName;
  final String action;
  final String timeAgo;
  final ActivityKind kind;

  const ActivityItem({
    required this.actorName,
    required this.action,
    required this.timeAgo,
    required this.kind,
  });

  IconData get icon {
    switch (kind) {
      case ActivityKind.document:
        return Icons.description_outlined;
      case ActivityKind.meeting:
        return Icons.calendar_today_outlined;
      case ActivityKind.milestone:
        return Icons.check_circle_outline_rounded;
    }
  }
}