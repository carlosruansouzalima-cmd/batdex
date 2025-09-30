// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  testWidgets('BatDex app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(BatDexApp());

    // Verify that the app title is displayed
    expect(find.text('BatDex'), findsOneWidget);

    // Verify that we have a list of bats
    expect(find.byType(ListView), findsOneWidget);

    // Check if at least one bat from the batdex is displayed
    expect(find.byType(ListTile), findsWidgets);
  });
}
