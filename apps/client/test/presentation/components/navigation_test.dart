import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/components/icons.dart';
import 'package:memuki/presentation/components/navigation.dart';
import 'package:memuki/presentation/components/pressable.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

const _destinations = [
  NavDestination(icon: MemukiIcons.home, label: 'Home'),
  NavDestination(icon: MemukiIcons.decks, label: 'Decks'),
];

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: child),
  ),
);

/// The fill of the destination labelled [label]: the first
/// [AnimatedContainer] in its [Pressable].
Color? _fill(WidgetTester tester, String label) {
  final container = tester.widget<AnimatedContainer>(
    find
        .descendant(
          of: find.ancestor(
            of: find.text(label),
            matching: find.byType(Pressable),
          ),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
  return (container.decoration! as BoxDecoration).color;
}

/// Where the sliding highlight is.
Rect _indicator(WidgetTester tester) =>
    tester.getRect(find.byType(AnimatedPositioned));

/// Where the destination labelled [label] is.
Rect _destination(WidgetTester tester, String label) => tester.getRect(
  find.ancestor(of: find.text(label), matching: find.byType(Pressable)),
);

void main() {
  for (final (name, build)
      in <(String, Widget Function(int, ValueChanged<int>))>[
        (
          'NavBar',
          (selected, onSelected) => Align(
            alignment: Alignment.bottomCenter,
            child: NavBar(
              destinations: _destinations,
              selectedIndex: selected,
              onSelected: onSelected,
            ),
          ),
        ),
        (
          'NavRail',
          (selected, onSelected) => Row(
            children: [
              NavRail(
                destinations: _destinations,
                selectedIndex: selected,
                onSelected: onSelected,
              ),
            ],
          ),
        ),
        (
          'extended NavRail',
          (selected, onSelected) => Row(
            children: [
              NavRail(
                destinations: _destinations,
                selectedIndex: selected,
                onSelected: onSelected,
                extended: true,
                title: 'Memuki',
              ),
            ],
          ),
        ),
      ]) {
    group(name, () {
      testWidgets('reports the tapped destination', (tester) async {
        int? tapped;
        await _pump(tester, build(0, (i) => tapped = i));

        await tester.tap(find.text('Decks'));
        expect(tapped, 1);
      });

      testWidgets('marks the selected destination', (tester) async {
        await _pump(tester, build(1, (_) {}));

        expect(
          tester.getSemantics(find.text('Decks')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasSelectedState: true,
            isSelected: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Decks',
          ),
        );
        await tester.pump();
        expect(
          _destination(tester, 'Decks').contains(_indicator(tester).center),
          isTrue,
        );
      });

      testWidgets('slides the highlight to a newly selected destination', (
        tester,
      ) async {
        await _pump(tester, build(0, (_) {}));
        await tester.pump();
        final from = _indicator(tester).center;

        await _pump(tester, build(1, (_) {}));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        final midway = _indicator(tester).center;

        await tester.pumpAndSettle();
        final to = _indicator(tester).center;
        expect(_destination(tester, 'Decks').contains(to), isTrue);
        expect(midway, isNot(from));
        expect(midway, isNot(to));
      });

      testWidgets('tints a destination on hover', (tester) async {
        await _pump(tester, build(1, (_) {}));
        final colors = tester.element(find.text('Home')).colors;
        expect(_fill(tester, 'Home'), isNull);

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(mouse.removePointer);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(tester.getCenter(find.text('Home')));
        await tester.pump();
        expect(_fill(tester, 'Home'), colors.surfaceSunken);
      });
    });
  }

  testWidgets('the extended rail shows its title', (tester) async {
    await _pump(
      tester,
      Row(
        children: [
          NavRail(
            destinations: _destinations,
            selectedIndex: 0,
            onSelected: (_) {},
            extended: true,
            title: 'Memuki',
          ),
        ],
      ),
    );
    expect(find.text('Memuki'), findsOneWidget);
  });
}
