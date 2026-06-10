import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ur_quest/screens/user_profile_screen.dart';
import 'package:ur_quest/theme/app_theme.dart';
void main() {
  testWidgets('UserProfileScreen muestra estado del jugador y vitrina', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const UserProfileScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('TESTHUNTER'), findsOneWidget);
    expect(find.text('A-RANK'), findsWidgets);
    expect(find.text('ARQUITECTO ARCANO'), findsOneWidget);
    expect(find.text('[ CAZADOR DEL AMANECER ]'), findsOneWidget);
    expect(find.text('[ VITRINA DE TROFEOS ]'), findsOneWidget);
    expect(find.text('AURA TOTAL ACUMULADA'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('AURA RESERVA'), findsOneWidget);
    expect(find.text('[ CAMBIAR TÍTULO ]'), findsOneWidget);
    expect(find.text('GESTIONAR'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);

    final changeTitleFinder = find.text('[ CAMBIAR TÍTULO ]');
    await tester.ensureVisible(changeTitleFinder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(changeTitleFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('[ SELECTOR DE TÍTULO ]'), findsOneWidget);

    await tester.tap(find.text('MONJE DEL FIREWALL'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('[ MONJE DEL FIREWALL ]'), findsOneWidget);

    final trophyFinder = find.byIcon(Icons.wb_sunny_outlined).first;
    await tester.ensureVisible(trophyFinder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(trophyFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('FORJADOR DEL ALBA'), findsOneWidget);
    expect(find.text('DESBLOQUEADO · 20/05/2026'), findsOneWidget);
  });
}
