import 'package:ethioventure/features/messaging/data/models/conversation_model.dart';
import 'package:ethioventure/features/messaging/data/models/message_model.dart';

class MessagingMockData {
  MessagingMockData._();

  static List<ConversationModel> get initialConversations => [
        ConversationModel(
          id: 'conv_001',
          participantIds: ['inv_001', 'fnd_001'],
          participantNames: {
            'inv_001': 'Dawit Abebe (Sheba Capital)',
            'fnd_001': 'Kaleb Worku (AgriTrust Founder)',
          },
          participantRoles: {
            'inv_001': 'investor',
            'fnd_001': 'founder',
          },
          startupId: 'stp_001',
          startupName: 'AgriTrust Ethiopia',
          lastMessage: MessageModel(
            id: 'msg_003',
            conversationId: 'conv_001',
            senderId: 'fnd_001',
            senderName: 'Kaleb Worku',
            receiverId: 'inv_001',
            content: 'Thank you Dawit! I just attached our updated Q3 cohort metrics and coffee cooperative contracts.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
            isRead: false,
          ),
          unreadCounts: {'inv_001': 1, 'fnd_001': 0},
          updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ConversationModel(
          id: 'conv_002',
          participantIds: ['inv_001', 'fnd_002'],
          participantNames: {
            'inv_001': 'Dawit Abebe (Sheba Capital)',
            'fnd_002': 'Selamawit Bekele (EthioPay CEO)',
          },
          participantRoles: {
            'inv_001': 'investor',
            'fnd_002': 'founder',
          },
          startupId: 'stp_002',
          startupName: 'EthioPay Gateway',
          lastMessage: MessageModel(
            id: 'msg_005',
            conversationId: 'conv_002',
            senderId: 'inv_001',
            senderName: 'Dawit Abebe',
            receiverId: 'fnd_002',
            content: 'Great traction on the Telebirr integration. When are you opening the next funding tranche?',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: true,
          ),
          unreadCounts: {'inv_001': 0, 'fnd_002': 0},
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ConversationModel(
          id: 'conv_003',
          participantIds: ['inv_002', 'fnd_004'],
          participantNames: {
            'inv_002': 'Sara Mengistu (Green Horn VC)',
            'fnd_004': 'Yohannes Girma (SunPower Founder)',
          },
          participantRoles: {
            'inv_002': 'investor',
            'fnd_004': 'founder',
          },
          startupId: 'stp_004',
          startupName: 'SunPower Horn',
          lastMessage: MessageModel(
            id: 'msg_008',
            conversationId: 'conv_003',
            senderId: 'fnd_004',
            senderName: 'Yohannes Girma',
            receiverId: 'inv_002',
            content: 'Hello Sara, our solar pump pilot in Hawassa achieved 40% crop yield enhancement.',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            isRead: true,
          ),
          unreadCounts: {'inv_002': 0, 'fnd_004': 0},
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

  static List<MessageModel> get initialMessages => [
        MessageModel(
          id: 'msg_001',
          conversationId: 'conv_001',
          senderId: 'inv_001',
          senderName: 'Dawit Abebe',
          receiverId: 'fnd_001',
          content: 'Hello Kaleb, I saw your AgriTrust profile on the Ethio Venture matching feed. Very impressed with your farmer retention numbers.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        MessageModel(
          id: 'msg_002',
          conversationId: 'conv_001',
          senderId: 'fnd_001',
          senderName: 'Kaleb Worku',
          receiverId: 'inv_001',
          content: 'Hi Dawit! Delighted to connect. We are currently raising our \$180K Seed round to scale into Sidama and Oromia regions.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
          isRead: true,
        ),
        MessageModel(
          id: 'msg_003',
          conversationId: 'conv_001',
          senderId: 'fnd_001',
          senderName: 'Kaleb Worku',
          receiverId: 'inv_001',
          content: 'Thank you Dawit! I just attached our updated Q3 cohort metrics and coffee cooperative contracts.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: false,
        ),
      ];
}
