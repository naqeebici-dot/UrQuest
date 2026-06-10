import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ur_quest/screens/achievements_screen.dart';
import 'package:ur_quest/theme/app_theme.dart';

void main() {
  testWidgets('AchievementsScreen muestra tabs y abre detalle de hito', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const AchievementsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('[ HITOS ]'), findsOneWidget);
    expect(find.text('[ TÍTULOS ]'), findsOneWidget);
    expect(find.text('[ MARCAS ]'), findsOneWidget);
    expect(find.text('PULMONES DE ACERO'), findsOneWidget);

    await tester.tap(find.text('PULMONES DE ACERO'));
    await tester.pumpAndSettle();

    expect(find.text('DESBLOQUEADO · 12/05/2026'), findsOneWidget);
    expect(find.textContaining('Resististe la llamada de la nicotina'), findsOneWidget);
  });
}

