import 'package:ethioventure/core/di/injection_container.dart' as di;
import 'package:ethioventure/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'EthioVentureApp renders Startup Profile dashboard with Pitch Deck section',
      (WidgetTester tester) async {
    await di.init();

    await tester.pumpWidget(const EthioVentureApp());
    await tester.pumpAndSettle();

    // Verify Startup Profile Header
    expect(find.text('Startup Profile Dashboard'), findsOneWidget);
    expect(find.text('Chapa Financial Technologies'), findsOneWidget);
    expect(find.text('Financial & Funding Overview'), findsOneWidget);

    // Verify Pitch Deck & Documents section (Issue 6)
    expect(find.text('Pitch Deck & Documents'), findsOneWidget);
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Chapa_Pitch_Deck_2025_v2.pdf'), findsOneWidget);
  });
}
