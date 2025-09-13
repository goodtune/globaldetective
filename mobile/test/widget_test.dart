// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:global_detective/main.dart';
import 'package:global_detective/core/services/platform_service.dart';

void main() {
  setUpAll(() async {
    // Initialize platform service before tests
    await PlatformService.instance.initialize();
  });

  testWidgets('Global Detective app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GlobalDetectiveApp());

    // Wait for splash screen to complete
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the app loads and shows the main menu
    expect(find.text('Welcome, Detective!'), findsOneWidget);
  });
}
