import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/components/animations.dart';
import 'package:memuki/presentation/theme/app_theme.dart';
import 'package:memuki/presentation/theme/motion.dart';
import 'package:memuki/presentation/theme/page_transitions.dart';

/// Pumps [child] in Memuki's theme, with reduced motion when [reduced].
Future<void> _pump(WidgetTester tester, Widget child, {bool reduced = false}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: app!,
        ),
        home: Scaffold(body: Center(child: child)),
      ),
    );

/// The opacity of the nearest [FadeTransition] above the text [label].
double _opacity(WidgetTester tester, String label) => tester
    .widget<FadeTransition>(
      find
          .ancestor(of: find.text(label), matching: find.byType(FadeTransition))
          .first,
    )
    .opacity
    .value;

double _scale(WidgetTester tester) => tester
    .widget<ScaleTransition>(
      find.descendant(
        of: find.byType(Pop),
        matching: find.byType(ScaleTransition),
      ),
    )
    .scale
    .value;

void main() {
  group('Entrance', () {
    Widget list() => const Column(
      children: [
        Entrance(child: Text('first')),
        Entrance(index: 3, child: Text('fourth')),
      ],
    );

    testWidgets('fades items in, one after another', (tester) async {
      await _pump(tester, list());
      expect(_opacity(tester, 'first'), 0);

      await tester.pump(const Duration(milliseconds: 100));
      expect(
        _opacity(tester, 'first'),
        greaterThan(_opacity(tester, 'fourth')),
      );

      await tester.pumpAndSettle();
      expect(_opacity(tester, 'first'), 1);
      expect(_opacity(tester, 'fourth'), 1);
    });

    testWidgets('shows items at once with reduced motion', (tester) async {
      await _pump(tester, list(), reduced: true);
      expect(_opacity(tester, 'fourth'), 1);
    });
  });

  group('Pop', () {
    Widget pop(bool active) =>
        Pop(active: active, child: const SizedBox(width: 20, height: 20));

    testWidgets('bounces when it turns on', (tester) async {
      await _pump(tester, pop(false));
      expect(_scale(tester), 1);

      await _pump(tester, pop(true));
      await tester.pump(const Duration(milliseconds: 20));
      expect(_scale(tester), lessThan(1));

      await tester.pumpAndSettle();
      expect(_scale(tester), 1);
    });

    testWidgets('stays still with reduced motion', (tester) async {
      await _pump(tester, pop(false), reduced: true);
      await _pump(tester, pop(true), reduced: true);
      await tester.pump(const Duration(milliseconds: 20));
      expect(_scale(tester), 1);
    });
  });

  testWidgets('SwitchTransition fades in when its value changes', (
    tester,
  ) async {
    await _pump(tester, const SwitchTransition(value: 0, child: Text('page')));
    expect(_opacity(tester, 'page'), 1);

    await _pump(tester, const SwitchTransition(value: 1, child: Text('page')));
    await tester.pump(const Duration(milliseconds: 20));
    expect(_opacity(tester, 'page'), lessThan(1));

    await tester.pumpAndSettle();
    expect(_opacity(tester, 'page'), 1);
  });

  group('SlidingIndicator', () {
    Widget group(int selected) => SlidingIndicator(
      count: 2,
      selected: selected,
      indicator: const ColoredBox(color: Color(0xFF000000)),
      builder: (context, anchor) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 2; i++)
            anchor(i, const SizedBox(width: 50, height: 20)),
        ],
      ),
    );
    Rect indicator(WidgetTester tester) =>
        tester.getRect(find.byType(AnimatedPositioned));

    testWidgets('jumps with reduced motion', (tester) async {
      await _pump(tester, group(0), reduced: true);
      await tester.pump();
      final from = indicator(tester);

      await _pump(tester, group(1), reduced: true);
      await tester.pump();
      await tester.pump();
      expect(indicator(tester), from.shift(const Offset(50, 0)));
    });

    testWidgets('follows its item when the layout changes', (tester) async {
      await _pump(tester, SizedBox(width: 300, child: group(1)));
      await tester.pump();
      final before = indicator(tester);

      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: SizedBox(width: 300, child: group(1)),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(indicator(tester).size, before.size);
    });
  });

  group('page transitions', () {
    Future<void> open(WidgetTester tester, {bool reduced = false}) async {
      await _pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const Text('next'))),
            child: const Text('open'),
          ),
        ),
        reduced: reduced,
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
    }

    testWidgets('a page slides and fades in', (tester) async {
      await open(tester);
      expect(_opacity(tester, 'next'), inExclusiveRange(0, 1));
      expect(
        find.ancestor(
          of: find.text('next'),
          matching: find.byType(SlideTransition),
        ),
        findsWidgets,
      );

      await tester.pumpAndSettle();
      expect(_opacity(tester, 'next'), 1);
    });

    testWidgets('a page only fades with reduced motion', (tester) async {
      await open(tester, reduced: true);
      expect(_opacity(tester, 'next'), inExclusiveRange(0, 1));
      expect(
        find.ancestor(
          of: find.text('next'),
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );
    });

    test('takes the standard duration', () {
      expect(
        const MemukiPageTransitionsBuilder().transitionDuration,
        Motion.standard,
      );
    });
  });
}
