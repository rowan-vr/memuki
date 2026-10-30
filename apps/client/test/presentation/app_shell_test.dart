import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/components/navigation.dart';
import 'package:memuki/presentation/decks/decks_screen.dart';
import 'package:memuki/presentation/home/home_screen.dart';
import 'package:memuki/presentation/settings/settings_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  group('AppShell layout', () {
    testWidgets('compact window uses a bottom navigation bar', (tester) async {
      await tester.pumpApp(size: const Size(400, 800));

      expect(find.byType(NavBar), findsOneWidget);
      expect(find.byType(NavRail), findsNothing);
    });

    testWidgets('medium window uses a collapsed navigation rail', (
      tester,
    ) async {
      await tester.pumpApp(size: const Size(700, 800));

      final rail = tester.widget<NavRail>(find.byType(NavRail));
      expect(rail.extended, isFalse);
      expect(find.byType(NavBar), findsNothing);
    });

    testWidgets('expanded window uses an extended navigation rail', (
      tester,
    ) async {
      await tester.pumpApp(size: const Size(1280, 800));

      final rail = tester.widget<NavRail>(find.byType(NavRail));
      expect(rail.extended, isTrue);
      expect(find.text('Memuki'), findsOneWidget);
    });

    testWidgets('layout adapts when the window is resized', (tester) async {
      await tester.pumpApp(size: const Size(1280, 800));
      expect(find.byType(NavRail), findsOneWidget);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(find.byType(NavBar), findsOneWidget);
      expect(find.byType(NavRail), findsNothing);
    });
  });

  testWidgets('navigates between top-level destinations', (tester) async {
    await tester.pumpApp();
    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.text('Decks'));
    await tester.pumpAndSettle();
    expect(find.byType(DecksScreen), findsOneWidget);

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
