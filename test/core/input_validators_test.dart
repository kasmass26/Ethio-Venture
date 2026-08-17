import 'package:ethioventure/core/utils/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidators.email', () {
    test('accepts a valid address', () {
      expect(InputValidators.email('founder@ethioventure.app'), isNull);
    });

    test('rejects a blank or malformed address', () {
      expect(InputValidators.email(null), isNotNull);
      expect(InputValidators.email('not-an-email'), isNotNull);
    });
  });

  group('InputValidators.password', () {
    test('requires a password of at least eight characters', () {
      expect(InputValidators.password('short'), isNotNull);
      expect(InputValidators.password('securePass1'), isNull);
    });

    test('requires matching password confirmation', () {
      expect(InputValidators.confirmPassword('first', 'second'), isNotNull);
      expect(InputValidators.confirmPassword('same-pass', 'same-pass'), isNull);
    });
  });

  group('InputValidators.positiveAmount', () {
    test('accepts positive formatted amounts only', () {
      expect(InputValidators.positiveAmount('10,000'), isNull);
      expect(InputValidators.positiveAmount('0'), isNotNull);
      expect(InputValidators.positiveAmount('unknown'), isNotNull);
    });
  });
}
