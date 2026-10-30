import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/components/buttons.dart';
import 'package:memuki/presentation/components/icons.dart';
import 'package:memuki/presentation/components/indicators.dart';
import 'package:memuki/presentation/components/panel.dart';
import 'package:memuki/presentation/components/pressable.dart';
import 'package:memuki/presentation/components/rows.dart';
import 'package:memuki/presentation/components/segmented_choice.dart';
import 'package:memuki/presentation/theme/app_theme.dart';
import 'package:memuki/presentation/theme/memuki_colors.dart';
import 'package:memuki/presentation/theme/memuki_layout.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Appearance appearance = const Appearance(),
}) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.build(appearance),
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  ),
);

MemukiColors _colors(WidgetTester tester) =>
    tester.element(find.byType(Scaffold)).colors;

/// The decoration of the nearest [AnimatedContainer] above [finder].
BoxDecoration _decorationAbove(WidgetTester tester, Finder finder) =>
    tester
            .widget<AnimatedContainer>(
              find
                  .ancestor(
                    of: finder,
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

void main() {
  group('Pressable', () {
    Widget probe(VoidCallback? onPressed, void Function(PressState) seen) =>
        Pressable(
          onPressed: onPressed,
          semanticLabel: 'Probe',
          builder: (context, state) {
            seen(state);
            return const SizedBox(width: 80, height: 40);
          },
        );

    testWidgets('reports presses while held and taps on release', (
      tester,
    ) async {
      var taps = 0;
      late PressState state;
      await _pump(tester, probe(() => taps++, (s) => state = s));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(state.pressed, isTrue);

      await gesture.up();
      await tester.pump();
      expect(state.pressed, isFalse);
      expect(taps, 1);
    });

    testWidgets('a cancelled press does not tap', (tester) async {
      var taps = 0;
      late PressState state;
      await _pump(tester, probe(() => taps++, (s) => state = s));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(0, 300));
      await gesture.up();
      await tester.pump();
      expect(state.pressed, isFalse);
      expect(taps, 0);
    });

    testWidgets('shows hover with a mouse', (tester) async {
      late PressState state;
      await _pump(tester, probe(() {}, (s) => state = s));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(state.hovered, isTrue);
    });

    testWidgets('activates with the keyboard and shows a focus ring', (
      tester,
    ) async {
      var taps = 0;
      late PressState state;
      await _pump(tester, probe(() => taps++, (s) => state = s));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(state.focused, isTrue);
      final ring = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(Pressable),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((ring.decoration as BoxDecoration).border, isNotNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 2);
    });

    testWidgets('is a disabled button without onPressed', (tester) async {
      late PressState state;
      await _pump(tester, probe(null, (s) => state = s));
      await tester.tap(find.byType(Pressable));
      await tester.pump();

      expect(state.enabled, isFalse);
      expect(state.pressed, isFalse);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Probe')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
    });
  });

  group('Button', () {
    testWidgets('shows its label and icon and reports taps', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        Button(
          label: 'Start studying',
          icon: MemukiIcons.study,
          onPressed: () => taps++,
        ),
      );
      expect(find.byIcon(MemukiIcons.study), findsOneWidget);

      await tester.tap(find.text('Start studying'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('primary is filled with the accent; secondary is outlined', (
      tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: [
            Button(label: 'Primary', onPressed: () {}),
            Button(
              label: 'Secondary',
              kind: ButtonKind.secondary,
              onPressed: () {},
            ),
          ],
        ),
      );
      final colors = _colors(tester);
      final primary = _decorationAbove(tester, find.text('Primary'));
      final secondary = _decorationAbove(tester, find.text('Secondary'));
      expect(primary.color, colors.accent.base);
      expect(primary.border, isNull);
      expect(secondary.color, colors.surface);
      expect(secondary.border, isNotNull);
    });

    testWidgets('darkens while pressed', (tester) async {
      await _pump(tester, Button(label: 'Go', onPressed: () {}));
      final colors = _colors(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      await tester.pumpAndSettle();
      expect(
        _decorationAbove(tester, find.text('Go')).color,
        isNot(colors.accent.base),
      );
      await gesture.up();
    });

    testWidgets('fades when disabled', (tester) async {
      await _pump(tester, const Button(label: 'Go', onPressed: null));
      final opacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Go'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('expands to the available width', (tester) async {
      await _pump(tester, Button(label: 'Go', expand: true, onPressed: () {}));
      expect(tester.getSize(find.byType(Button)).width, 360);
    });
  });

  testWidgets('QuietButton tints on hover and reports taps', (tester) async {
    var taps = 0;
    await _pump(tester, QuietButton(label: 'See all', onPressed: () => taps++));
    final colors = _colors(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('See all')));
    await tester.pumpAndSettle();
    expect(
      _decorationAbove(tester, find.text('See all')).color,
      colors.accent.soft,
    );

    await tester.tap(find.text('See all'));
    expect(taps, 1);
  });

  testWidgets('GradeButton reads its grade and interval together', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      Builder(
        builder: (context) => GradeButton(
          label: 'Good',
          interval: '1 day',
          tone: context.colors.good,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.bySemanticsLabel('Good, 1 day'), findsOneWidget);

    await tester.tap(find.text('Good'));
    expect(taps, 1);
  });

  group('ListRow', () {
    testWidgets('a tappable row shows a chevron and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        ListRow(title: 'N2 Kanji', subtitle: '18 due', onTap: () => taps++),
      );
      expect(find.text('18 due'), findsOneWidget);
      expect(find.byIcon(MemukiIcons.forward), findsOneWidget);

      await tester.tap(find.text('N2 Kanji'));
      expect(taps, 1);
    });

    testWidgets('a plain row has no chevron', (tester) async {
      await _pump(tester, const ListRow(title: 'N2 Kanji'));
      expect(find.byIcon(MemukiIcons.forward), findsNothing);
      expect(find.byType(Pressable), findsNothing);
    });

    testWidgets('its own trailing replaces the chevron', (tester) async {
      await _pump(
        tester,
        ListRow(
          title: 'N2 Kanji',
          leading: const Swatch(color: Colors.green),
          trailing: const Text('42'),
          onTap: () {},
        ),
      );
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(MemukiIcons.forward), findsNothing);
      expect(find.byType(Swatch), findsOneWidget);
    });

    testWidgets('RowGroup separates rows with hairlines', (tester) async {
      await _pump(
        tester,
        const RowGroup(
          children: [
            ListRow(title: 'A'),
            ListRow(title: 'B'),
            ListRow(title: 'C'),
          ],
        ),
      );
      final hairlines = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 1,
      );
      expect(hairlines, findsNWidgets(2));
    });
  });

  testWidgets('SegmentedChoice selects an option', (tester) async {
    var selected = 'light';
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SegmentedChoice(
          choices: const [
            Choice('light', 'Light', icon: MemukiIcons.lightTheme),
            Choice('dark', 'Dark', icon: MemukiIcons.darkTheme),
          ],
          selected: selected,
          onSelected: (v) => setState(() => selected = v),
        ),
      ),
    );
    expect(find.byIcon(MemukiIcons.darkTheme), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(selected, 'dark');
    expect(
      tester.getSemantics(find.text('Dark')),
      isSemantics(hasSelectedState: true, isSelected: true, isButton: true),
    );
  });

  group('indicators', () {
    testWidgets('a Tag is neutral unless it has a tone', (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (context) => Column(
            children: [
              const Tag(label: 'nouns'),
              Tag(label: 'leech', tone: context.colors.again),
            ],
          ),
        ),
      );
      final colors = _colors(tester);
      BoxDecoration of(String label) =>
          tester
                  .widget<Container>(
                    find
                        .ancestor(
                          of: find.text(label),
                          matching: find.byType(Container),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(of('nouns').color, colors.surfaceSunken);
      expect(of('leech').color, colors.again.soft);
    });

    testWidgets('ProgressLine clamps and announces its value', (tester) async {
      await _pump(tester, const ProgressLine(value: 1.5, label: 'Done'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AnimatedFractionallySizedBox>(
              find.byType(AnimatedFractionallySizedBox),
            )
            .widthFactor,
        1,
      );
      expect(
        tester.getSemantics(find.byType(ProgressLine)),
        isSemantics(label: 'Done', value: '100%'),
      );
    });
  });

  group('Panel', () {
    testWidgets('SectionHeader is a heading with an optional action', (
      tester,
    ) async {
      await _pump(
        tester,
        SectionHeader(
          title: 'Recent decks',
          action: QuietButton(label: 'See all', onPressed: () {}),
        ),
      );
      expect(
        tester.getSemantics(find.text('Recent decks')),
        isSemantics(isHeader: true),
      );
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('compact density tightens vertical padding', (tester) async {
      double paddingTop() =>
          (tester
                      .widget<Container>(
                        find
                            .ancestor(
                              of: find.text('x'),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .padding!
                  as EdgeInsets)
              .top;

      await _pump(tester, const Panel(child: Text('x')));
      final comfortable = paddingTop();

      await _pump(
        tester,
        const Panel(child: Text('x')),
        appearance: const Appearance(density: Density.compact),
      );
      await tester.pumpAndSettle();
      expect(paddingTop(), comfortable * 0.75);
    });

    test('paper shadows are darker in dark mode', () {
      final light = paperShadow(
        MemukiColors.of(ColorMode.light, MemukiAccent.blue),
      );
      final dark = paperShadow(
        MemukiColors.of(ColorMode.dark, MemukiAccent.blue),
      );
      expect(dark.first.color.a, greaterThan(light.first.color.a));
    });
  });
}
