import 'package:ethioventure/core/error/exceptions.dart';
import 'package:ethioventure/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:ethioventure/features/verification/domain/entities/verification_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

void main() {
  late SupabaseClient client;
  late VerificationRemoteDataSourceImpl dataSource;

  setUp(() {
    client = SupabaseClient('http://localhost:54321', 'test-anon-key');
    dataSource = VerificationRemoteDataSourceImpl(client);
  });

  tearDown(() {
    client.dispose();
  });

  test('fetching requests rejects an unauthenticated user', () async {
    await expectLater(
      dataSource.getCurrentUserRequests(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'User not authenticated',
        ),
      ),
    );
  });

  test('starting a request rejects an unauthenticated user', () async {
    await expectLater(
      dataSource.startVerificationRequest(VerificationType.identity),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'User not authenticated',
        ),
      ),
    );
  });

  test('public badge lookup attempts a real query (network error on test client)', () async {
    // getPublicApprovedBadges does not require the caller to be authenticated —
    // it queries by profileId. On a test client pointing at localhost the
    // Supabase call will fail with a ServerException (network/PostgREST error).
    await expectLater(
      dataSource.getPublicApprovedBadges('profile-1'),
      throwsA(isA<ServerException>()),
    );
  });
}
