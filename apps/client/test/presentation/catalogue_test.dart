import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/catalogue/catalogue_screen.dart';
import 'package:memuki/presentation/theme/app_theme.dart';
import 'package:memuki/presentation/theme/memuki_colors.dart';
import 'package:memuki/presentation/theme/memuki_layout.dart';

import '../helpers/pump_app.dart';

/// A context inside the catalogue's theme, from the toolbar.
BuildContext _content(WidgetTester tester) => tester.element(find.text('Mode'));

Future<void> _wide(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('the Developer tab opens the catalogue', (tester) async {
    await tester.pumpApp();

    await tester.tap(find.text('Developer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Component catalogue'));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogueScreen), findsOneWidget);
    expect(find.text('Surfaces and text'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogueScreen), findsNothing);
    expect(find.text('Component catalogue'), findsOneWidget);
  });

  testWidgets('every section renders, at the largest text scale', (
    tester,
  ) async {
    await _wide(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CatalogueScreen()),
    );
    await tester.tap(find.text('2.0×'));
    await tester.pumpAndSettle();

    for (final section in CatalogueSection.values) {
      await tester.tap(find.text(section.title).first);
      await tester.pumpAndSettle();
      expect(find.text(section.title), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    }
    expect(find.text('猫'), findsOneWidget);
  });

  testWidgets('narrow windows list the sections in a row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CatalogueScreen()),
    );
    await tester.ensureVisible(find.text('Panels'));
    await tester.tap(find.text('Panels'));
    await tester.pumpAndSettle();
    expect(find.text('SectionHeader'), findsOneWidget);
  });

  testWidgets('the catalogue switches every appearance setting', (
    tester,
  ) async {
    await _wide(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CatalogueScreen()),
    );
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    expect(_content(tester).colors.mode, ColorMode.light);

    Future<void> pick(String label) async {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
    }

    await pick('sepia');
    expect(_content(tester).colors.mode, ColorMode.sepia);

    await tester.tap(find.bySemanticsLabel('green'));
    await tester.pumpAndSettle();
    expect(
      _content(tester).colors.accent.base,
      MemukiColors.of(ColorMode.sepia, MemukiAccent.green).accent.base,
    );

    for (final style in CardStyle.values) {
      await pick(style.name);
      expect(_content(tester).layout.cardStyle, style);
      expect(find.text('猫'), findsOneWidget);
    }

    await pick('compact');
    expect(_content(tester).layout.density, Density.compact);
    expect(_content(tester).layout.dense(16), 12);

    await pick('dark');
    await pick('2.0×');
    expect(_content(tester).colors.mode, ColorMode.dark);
    expect(
      MediaQuery.textScalerOf(_content(tester)),
      const TextScaler.linear(2),
    );
  });

  testWidgets('the catalogue starts in the app\'s dark mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const CatalogueScreen()),
    );
    expect(_content(tester).colors.mode, ColorMode.dark);
  });
}
