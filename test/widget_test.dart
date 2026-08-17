import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:ethioventure/core/error/exceptions.dart';

void main() {
  group('Auth login contract', () {
    final dataSource = AuthRemoteDataSourceImpl();

    test('returns a ServerException for invalid credentials', () async {
      expect(
        () => dataSource.login(
          email: 'wrong@email.com',
          password: 'wrongpass',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('returns a user for a valid credential', () async {
      final user = await dataSource.login(
        email: 'admin@ethioventure.com',
        password: 'Admin@123',
      );

      expect(user.email, 'admin@ethioventure.com');
    });
  });
}
