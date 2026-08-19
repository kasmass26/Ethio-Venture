import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConstants has investor profile route and app name defined', () {
    expect(AppConstants.appName, 'Ethio Venture');
    expect(AppConstants.routeInvestorProfile, '/investor-profile');
  });
}
