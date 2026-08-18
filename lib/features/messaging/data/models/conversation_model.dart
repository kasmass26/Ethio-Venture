import 'package:ethioventure/features/messaging/data/models/message_model.dart';
import 'package:ethioventure/features/messaging/domain/entities/conversation_entity.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.startupId,
    required super.investorId,
    required super.createdAt,
    super.startupUserId,
    super.startupName,
    super.startupLogoUrl,
    super.investorUserId,
    super.investorName,
    super.investorType,
    super.lastMessage,
    super.unreadCounts = const {},
    super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    // Extract startup profile joined info
    String? sUserId;
    String? sName;
    String? sLogo;
    if (json['startup_profiles'] is Map) {
      final sProfile = json['startup_profiles'] as Map<String, dynamic>;
      sUserId = sProfile['user_id'] as String?;
      sName = sProfile['business_name'] as String?;
      sLogo = sProfile['logo_url'] as String?;
    } else {
      sName = json['startup_name'] as String?;
    }

    // Extract investor profile joined info
    String? iUserId;
    String? iName;
    String? iType;
    if (json['investor_profiles'] is Map) {
      final iProfile = json['investor_profiles'] as Map<String, dynamic>;
      iUserId = iProfile['user_id'] as String?;
      iName = iProfile['organization_name'] as String?;
      iType = iProfile['investor_type'] as String?;
    } else {
      iName = json['investor_name'] as String?;
    }

    // Extract latest message
    MessageModel? lastMsg;
    if (json['last_message'] is Map) {
      lastMsg = MessageModel.fromJson(json['last_message'] as Map<String, dynamic>);
    } else if (json['messages'] is List && (json['messages'] as List).isNotEmpty) {
      lastMsg = MessageModel.fromJson((json['messages'] as List).last as Map<String, dynamic>);
    }

    return ConversationModel(
      id: json['id'] as String? ?? '',
      startupId: json['startup_id'] as String? ?? '',
      investorId: json['investor_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startupUserId: sUserId,
      startupName: sName,
      startupLogoUrl: sLogo,
      investorUserId: iUserId,
      investorName: iName,
      investorType: iType,
      lastMessage: lastMsg,
      unreadCounts: (json['unread_counts'] is Map)
          ? (json['unread_counts'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : {},
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startup_id': startupId,
      'investor_id': investorId,
      'created_at': createdAt.toIso8601String(),
      if (startupName != null) 'startup_name': startupName,
      if (investorName != null) 'investor_name': investorName,
      if (lastMessage != null)
        'last_message': lastMessage is MessageModel
            ? (lastMessage as MessageModel).toJson()
            : MessageModel.fromEntity(lastMessage!).toJson(),
      'unread_counts': unreadCounts,
    };
  }

  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      startupId: entity.startupId,
      investorId: entity.investorId,
      createdAt: entity.createdAt,
      startupUserId: entity.startupUserId,
      startupName: entity.startupName,
      startupLogoUrl: entity.startupLogoUrl,
      investorUserId: entity.investorUserId,
      investorName: entity.investorName,
      investorType: entity.investorType,
      lastMessage: entity.lastMessage,
      unreadCounts: entity.unreadCounts,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  ConversationModel copyWith({
    String? id,
    String? startupId,
    String? investorId,
    DateTime? createdAt,
    String? startupUserId,
    String? startupName,
    String? startupLogoUrl,
    String? investorUserId,
    String? investorName,
    String? investorType,
    MessageEntity? lastMessage,
    Map<String, int>? unreadCounts,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      investorId: investorId ?? this.investorId,
      createdAt: createdAt ?? this.createdAt,
      startupUserId: startupUserId ?? this.startupUserId,
      startupName: startupName ?? this.startupName,
      startupLogoUrl: startupLogoUrl ?? this.startupLogoUrl,
      investorUserId: investorUserId ?? this.investorUserId,
      investorName: investorName ?? this.investorName,
      investorType: investorType ?? this.investorType,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
