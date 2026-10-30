import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/catalogue/concepts/chunky_review.dart';
import 'package:memuki/presentation/catalogue/concepts/concepts_screen.dart';
import 'package:memuki/presentation/catalogue/concepts/mascot_review.dart';
import 'package:memuki/presentation/catalogue/concepts/paper_review.dart';
import 'package:memuki/presentation/catalogue/concepts/stationery_review.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('the Developer tab opens the visual concepts', (tester) async {
    await tester.pumpApp();

    await tester.tap(find.text('Developer').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visual concepts'));
    await tester.pumpAndSettle();

    expect(find.byType(StationeryReview), findsOneWidget);
  });

  testWidgets('each concept renders in light and dark', (tester) async {
    tester.view.physicalSize = const Size(700, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const ConceptsScreen()),
    );

    for (final (name, type) in [
      ('stationery', StationeryReview),
      ('paper', PaperReview),
      ('chunky', ChunkyReview),
      ('mascot', MascotReview),
    ]) {
      await tester.tap(find.text(name));
      for (final brightness in ['dark', 'light']) {
        await tester.tap(find.text(brightness));
        await tester.pumpAndSettle();
        expect(find.byType(type), findsOneWidget);
      }
    }
  });

  testWidgets('a chunky button sinks while pressed and reports taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            child: ChunkyButton(
              outline: Colors.black,
              color: Colors.amber,
              onPressed: () => taps++,
              child: const Text('Good'),
            ),
          ),
        ),
      ),
    );
    final before = tester.getTopLeft(find.text('Good'));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Good')),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Good')), isNot(before));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Good')), before);
    expect(taps, 1);
  });

  testWidgets('a stamp fills with ink while pressed and reports taps', (
    tester,
  ) async {
    var taps = 0;
    const ink = Color(0xFF22355F);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 120,
            child: StampButton(
              ink: ink,
              paper: Colors.white,
              label: 'Good',
              interval: '3d',
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );
    Color? fill() =>
        (tester
                    .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                    .decoration!
                as BoxDecoration)
            .color;
    expect(fill(), Colors.white);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Good')),
    );
    await tester.pumpAndSettle();
    expect(fill(), ink);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(fill(), Colors.white);
    expect(taps, 1);
  });
}
