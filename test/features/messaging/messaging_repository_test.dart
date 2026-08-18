import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/core/error/failures.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:ethioventure/features/messaging/data/models/conversation_model.dart';
import 'package:ethioventure/features/messaging/data/models/message_model.dart';
import 'package:ethioventure/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:ethioventure/features/messaging/domain/entities/message_entity.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/send_message_usecase.dart';

void main() {
  late MessagingRemoteDataSource remoteDataSource;
  late MessagingRepositoryImpl repository;
  late GetConversationsUseCase getConversationsUseCase;
  late GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  late GetMessagesUseCase getMessagesUseCase;
  late SendMessageUseCase sendMessageUseCase;

  setUp(() {
    // Uses the in-memory fallback mode of the data source for standalone testing
    remoteDataSource = MessagingRemoteDataSourceImpl();
    repository = MessagingRepositoryImpl(remoteDataSource: remoteDataSource);
    getConversationsUseCase = GetConversationsUseCase(repository);
    getOrCreateConversationUseCase = GetOrCreateConversationUseCase(repository);
    getMessagesUseCase = GetMessagesUseCase(repository);
    sendMessageUseCase = SendMessageUseCase(repository);
  });

  group('Phase 11: Direct Messaging & Communication Tests', () {
    // 1. Conversation Data Model Test
    test('1. ConversationModel serializes to/from JSON matching schema with profile joins', () {
      final json = {
        'id': 'conv_123',
        'startup_id': 'stp_001',
        'investor_id': 'inv_001',
        'created_at': '2026-08-17T10:00:00.000Z',
        'startup_profiles': {
          'user_id': 'usr_fnd_001',
          'business_name': 'AgriTrust Ethiopia',
          'logo_url': 'https://example.com/logo.png',
        },
        'investor_profiles': {
          'user_id': 'usr_inv_001',
          'organization_name': 'Sheba Capital',
          'investor_type': 'Venture Capital',
        },
      };

      final model = ConversationModel.fromJson(json);

      expect(model.id, equals('conv_123'));
      expect(model.startupId, equals('stp_001'));
      expect(model.investorId, equals('inv_001'));
      expect(model.startupName, equals('AgriTrust Ethiopia'));
      expect(model.investorName, equals('Sheba Capital'));
      expect(model.startupUserId, equals('usr_fnd_001'));
      expect(model.investorUserId, equals('usr_inv_001'));
      expect(model.isParticipant('usr_fnd_001'), isTrue);
      expect(model.isParticipant('usr_inv_001'), isTrue);
      expect(model.isParticipant('unknown_user'), isFalse);
    });

    // 2. Message Data Model Test
    test('2. MessageModel serializes correctly with sent_at and read_at timestamps', () {
      final json = {
        'id': 'msg_123',
        'conversation_id': 'conv_123',
        'sender_id': 'usr_fnd_001',
        'sender_name': 'Abebe Bikila',
        'content': 'Hello, we are excited to present our deck.',
        'sent_at': '2026-08-17T10:05:00.000Z',
        'read_at': '2026-08-17T10:06:00.000Z',
      };

      final model = MessageModel.fromJson(json);

      expect(model.id, equals('msg_123'));
      expect(model.conversationId, equals('conv_123'));
      expect(model.senderId, equals('usr_fnd_001'));
      expect(model.content, equals('Hello, we are excited to present our deck.'));
      expect(model.isRead, isTrue);
      expect(model.sentAt, equals(DateTime.parse('2026-08-17T10:05:00.000Z')));
    });

    // 3. Starting a conversation
    test('3. Startup and investor can start a new conversation', () async {
      final result = await getOrCreateConversationUseCase(
        const GetOrCreateConversationParams(
          startupId: 'stp_new_999',
          investorId: 'inv_new_999',
          currentUserId: 'usr_new_999',
        ),
      );

      expect(result.isSuccess, isTrue);
      final conversation = result.dataOrNull!;
      expect(conversation.startupId, equals('stp_new_999'));
      expect(conversation.investorId, equals('inv_new_999'));
    });

    // 4. Duplicate prevention
    test('4. Returns existing conversation instead of creating duplicates for same pair', () async {
      // First call
      final first = await getOrCreateConversationUseCase(
        const GetOrCreateConversationParams(
          startupId: 'stp_unique_1',
          investorId: 'inv_unique_1',
        ),
      );

      // Second call for same pair
      final second = await getOrCreateConversationUseCase(
        const GetOrCreateConversationParams(
          startupId: 'stp_unique_1',
          investorId: 'inv_unique_1',
        ),
      );

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      expect(first.dataOrNull!.id, equals(second.dataOrNull!.id));
    });

    // 5. Retrieving conversation list
    test('5. Retrieves conversations belonging to the user', () async {
      final result = await getConversationsUseCase(
        const GetConversationsParams(userId: 'usr_inv_001'),
      );

      expect(result.isSuccess, isTrue);
      final list = result.dataOrNull!;
      expect(list, isNotEmpty);
      for (final conv in list) {
        expect(conv.isParticipant('usr_inv_001'), isTrue);
      }
    });

    // 6. Retrieving message history
    test('6. Retrieves message history in chronological order', () async {
      final result = await getMessagesUseCase(
        const GetMessagesParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          currentUserId: 'usr_inv_001',
        ),
      );

      expect(result.isSuccess, isTrue);
      final messages = result.dataOrNull!;
      expect(messages.length, greaterThanOrEqualTo(2));
      for (int i = 0; i < messages.length - 1; i++) {
        expect(
          messages[i].sentAt.isBefore(messages[i + 1].sentAt) ||
              messages[i].sentAt.isAtSameMomentAs(messages[i + 1].sentAt),
          isTrue,
        );
      }
    });

    // 7. Sending a message
    test('7. Authorized user can send messages into conversation', () async {
      final result = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          content: 'Looking forward to our due diligence meeting tomorrow.',
          senderName: 'Dawit Abebe',
        ),
      );

      expect(result.isSuccess, isTrue);
      final sent = result.dataOrNull!;
      expect(sent.content, equals('Looking forward to our due diligence meeting tomorrow.'));
      expect(sent.senderId, equals('usr_inv_001'));
      expect(sent.sentAt, isNotNull);
    });

    // 8. Message timestamps
    test('8. Sent message contains accurate valid timestamp', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_fnd_001',
          content: 'Acknowledged!',
        ),
      );
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(result.isSuccess, isTrue);
      final msg = result.dataOrNull!;
      expect(msg.sentAt.isAfter(before), isTrue);
      expect(msg.sentAt.isBefore(after), isTrue);
    });

    // 9. Empty and whitespace message validation
    test('9. Empty or whitespace-only messages are rejected with ValidationFailure', () async {
      final emptyResult = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          content: '',
        ),
      );

      final whitespaceResult = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          content: '     \n  \t  ',
        ),
      );

      expect(emptyResult.isFailure, isTrue);
      expect(emptyResult.failureOrNull, isA<ValidationFailure>());
      expect(whitespaceResult.isFailure, isTrue);
      expect(whitespaceResult.failureOrNull, isA<ValidationFailure>());
    });

    // 10. Startup Authorization
    test('10. Startup founder is authorized to view and message within their conversation', () async {
      final fetchRes = await getMessagesUseCase(
        const GetMessagesParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          currentUserId: 'usr_fnd_001',
        ),
      );
      expect(fetchRes.isSuccess, isTrue);

      final sendRes = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_fnd_001',
          content: 'Sending pitch deck.',
        ),
      );
      expect(sendRes.isSuccess, isTrue);
    });

    // 11. Investor Authorization
    test('11. Investor is authorized to view and message within their conversation', () async {
      final fetchRes = await getMessagesUseCase(
        const GetMessagesParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          currentUserId: 'usr_inv_001',
        ),
      );
      expect(fetchRes.isSuccess, isTrue);

      final sendRes = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          content: 'Pitch deck received, thank you.',
        ),
      );
      expect(sendRes.isSuccess, isTrue);
    });

    // 12. Unauthorized user cannot retrieve conversation messages
    test('12. Unauthorized non-participant user CANNOT retrieve conversation messages', () async {
      final unauthorizedResult = await getMessagesUseCase(
        const GetMessagesParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          currentUserId: 'unauthorized_attacker_id',
        ),
      );

      expect(unauthorizedResult.isFailure, isTrue);
      expect(unauthorizedResult.failureOrNull, isA<AuthFailure>());
      expect(
        unauthorizedResult.failureOrNull?.message,
        contains('Access denied'),
      );
    });

    // 13. Unauthorized user cannot send messages into a conversation
    test('13. Unauthorized user CANNOT send messages to conversations they do not belong to', () async {
      final unauthorizedSend = await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'unauthorized_attacker_id',
          content: 'Malicious unauthorized message',
        ),
      );

      expect(unauthorizedSend.isFailure, isTrue);
      expect(unauthorizedSend.failureOrNull, isA<AuthFailure>());
    });

    // 14. Real-time stream receives new messages
    test('14. StreamMessagesUseCase emits updated message history when new message is sent', () async {
      final stream = repository.streamMessages(
        conversationId: 'c0000001-0000-0000-0000-000000000001',
      );

      expectLater(
        stream,
        emitsThrough(
          predicate<List<MessageEntity>>((list) =>
              list.any((m) => m.content == 'Realtime broadcast stream check!')),
        ),
      );

      await sendMessageUseCase(
        const SendMessageParams(
          conversationId: 'c0000001-0000-0000-0000-000000000001',
          senderId: 'usr_inv_001',
          content: 'Realtime broadcast stream check!',
        ),
      );
    });
  });
}
