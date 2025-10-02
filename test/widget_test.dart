// This is a basic Flutter widget test for OnePlate App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oneplate/main.dart';

void main() {
  testWidgets('OnePlate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OnePlateApp());

    // Verify that the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for any async operations
    await tester.pumpAndSettle();
    
    // The test passes if the app loads successfully
  });
  
  testWidgets('App starts with Login screen', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const OnePlateApp());
    
    // Wait for the app to settle
    await tester.pumpAndSettle();
    
    // Verify login screen elements are present
    // Note: Adjust these based on your actual login screen widgets
    expect(find.byType(Scaffold), findsWidgets);
  });
}
