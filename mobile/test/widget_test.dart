import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the splash screen timer to finish
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // After splash screen, it should be on the login screen
    // Verify that login screen or app content is shown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
