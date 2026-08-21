import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethioventure/core/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renders with custom size and properties', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(
            size: 64,
            isCircular: true,
            showShadow: true,
            showBorder: true,
          ),
        ),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
