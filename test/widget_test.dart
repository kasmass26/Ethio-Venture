import 'package:ethioventure/features/auth/data/models/user_model.dart';
import 'package:ethioventure/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supabase user mapping', () {
    test('reads name from Supabase user metadata', () {
      const json = {
        'id': 'user-123',
        'email': 'ada@example.com',
        'user_metadata': {
          'full_name': 'Ada Lovelace',
          'role': 'investor',
        },
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'ada@example.com');
      expect(user.name, 'Ada Lovelace');
      expect(user.role, UserRole.investor);
    });
  });
}
