import 'package:ethioventure/features/messaging/data/models/conversation_model.dart';
import 'package:ethioventure/features/messaging/data/models/message_model.dart';

class MessagingMockData {
  MessagingMockData._();

  static List<ConversationModel> get initialConversations => [
        ConversationModel(
          id: 'c0000001-0000-0000-0000-000000000001',
          startupId: 'stp_001',
          investorId: 'inv_001',
          startupUserId: 'usr_fnd_001',
          startupName: 'AgriTrust Ethiopia',
          investorUserId: 'usr_inv_001',
          investorName: 'Dawit Abebe (Sheba Capital)',
          investorType: 'Venture Capital',
          lastMessage: MessageModel(
            id: 'm0000001-0000-0000-0000-000000000003',
            conversationId: 'c0000001-0000-0000-0000-000000000001',
            senderId: 'usr_fnd_001',
            senderName: 'Kaleb Worku',
            content: 'Thank you Dawit! I just shared our updated Q3 coffee cooperative contracts and traction metrics.',
            sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
          ),
          unreadCounts: {'usr_inv_001': 1, 'usr_fnd_001': 0},
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ConversationModel(
          id: 'c0000002-0000-0000-0000-000000000002',
          startupId: 'stp_002',
          investorId: 'inv_001',
          startupUserId: 'usr_fnd_002',
          startupName: 'EthioPay Gateway',
          investorUserId: 'usr_inv_001',
          investorName: 'Dawit Abebe (Sheba Capital)',
          investorType: 'Venture Capital',
          lastMessage: MessageModel(
            id: 'm0000002-0000-0000-0000-000000000005',
            conversationId: 'c0000002-0000-0000-0000-000000000002',
            senderId: 'usr_inv_001',
            senderName: 'Dawit Abebe',
            content: 'Great traction on the Telebirr integration. When are you opening the next funding tranche?',
            sentAt: DateTime.now().subtract(const Duration(hours: 3)),
            readAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          unreadCounts: {'usr_inv_001': 0, 'usr_fnd_002': 0},
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

  static List<MessageModel> get initialMessages => [
        MessageModel(
          id: 'm0000001-0000-0000-0000-000000000001',
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          senderName: 'Dawit Abebe',
          content: 'Hello Kaleb, I saw your AgriTrust profile on the Ethio Venture matching feed. Very impressed with your farmer retention numbers.',
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
        MessageModel(
          id: 'm0000001-0000-0000-0000-000000000002',
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_fnd_001',
          senderName: 'Kaleb Worku',
          content: 'Hi Dawit! Delighted to connect. We are currently raising our \$180K Seed round to scale into Sidama and Oromia regions.',
          sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          readAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        MessageModel(
          id: 'm0000001-0000-0000-0000-000000000003',
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_fnd_001',
          senderName: 'Kaleb Worku',
          content: 'Thank you Dawit! I just shared our updated Q3 coffee cooperative contracts and traction metrics.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ];
}
