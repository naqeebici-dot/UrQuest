// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ur_quest/main.dart';

void main() {
  testWidgets('renderiza el dashboard principal', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UrQuestApp()));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ATRIBUTOS'), findsOneWidget);
    expect(find.text('HUD'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
