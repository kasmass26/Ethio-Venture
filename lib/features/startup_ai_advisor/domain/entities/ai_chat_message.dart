import 'package:flutter/foundation.dart';

@immutable
class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.roleMode,
    this.startupName,
    this.suggestedFollowUps = const [],
    this.keyTakeaways = const [],
    this.actionItems = const [],
  });

  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  /// 'founder' or 'investor'
  final String roleMode;

  /// Optional startup name attached to this message/context
  final String? startupName;

  /// Clickable follow-up prompt suggestions
  final List<String> suggestedFollowUps;

  /// Highlights / takeaways identified by the AI
  final List<String> keyTakeaways;

  /// Recommended concrete next steps
  final List<String> actionItems;

  AiChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? roleMode,
    String? startupName,
    List<String>? suggestedFollowUps,
    List<String>? keyTakeaways,
    List<String>? actionItems,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      roleMode: roleMode ?? this.roleMode,
      startupName: startupName ?? this.startupName,
      suggestedFollowUps: suggestedFollowUps ?? this.suggestedFollowUps,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      actionItems: actionItems ?? this.actionItems,
    );
  }
}
