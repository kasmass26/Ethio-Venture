import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConstants has investor profile route defined', () {
    expect(AppConstants.routeInvestorProfile, '/investor-profile');
  });
}
