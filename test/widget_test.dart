import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/core/di/injection_container.dart';
import 'package:ethioventure/main.dart';

void main() {
  setUp(() async {
    sl.reset();
    await initServiceLocator();
  });

  testWidgets('EthioVentureApp smoke test and Investor Dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(const EthioVentureApp());
    await tester.pump();

    // Verify app bar title
    expect(find.text('Investor Dashboard'), findsOneWidget);

    // Pump to settle async matching calculations
    await tester.pumpAndSettle();

    // Verify recommendations section is rendered
    expect(find.textContaining('Recommended Startups'), findsOneWidget);
    expect(find.textContaining('% MATCH'), findsWidgets);
  });
}
