import 'package:ethioventure/core/constants/app_constants.dart';
import 'package:ethioventure/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Ethio Venture app starts successfully', (tester) async {
    await tester.pumpWidget(
      const EthioVentureApp(
        environment: 'test',
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}

