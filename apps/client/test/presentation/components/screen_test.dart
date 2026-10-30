import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/presentation/components/icons.dart';
import 'package:memuki/presentation/components/screen.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, Widget home) =>
    tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: home));

void main() {
  testWidgets('a first page shows its title as a header, without back', (
    tester,
  ) async {
    await _pump(tester, const Screen(title: 'Decks', body: Text('body')));

    expect(find.text('body'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Decks')),
      matchesSemantics(label: 'Decks', isHeader: true),
    );
    expect(find.byType(IconAction), findsNothing);
  });

  testWidgets('a pushed page goes back from its header', (tester) async {
    await _pump(
      tester,
      Builder(
        builder: (context) => Screen(
          title: 'Developer',
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Screen(title: 'Catalogue', body: SizedBox()),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Catalogue'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Catalogue'), findsNothing);
    expect(find.text('Developer'), findsOneWidget);
  });

  testWidgets('shows actions at the end of the header', (tester) async {
    var added = 0;
    await _pump(
      tester,
      Screen(
        title: 'Decks',
        actions: [
          IconAction(
            icon: MemukiIcons.add,
            semanticLabel: 'Add deck',
            onPressed: () => added++,
          ),
        ],
        body: const SizedBox(),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Add deck'));
    expect(added, 1);
  });

  group('IconAction', () {
    BoxDecoration decoration(WidgetTester tester) =>
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: find.byType(IconAction),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;

    testWidgets('tints on hover and while pressed', (tester) async {
      await _pump(
        tester,
        Center(
          child: IconAction(
            icon: MemukiIcons.add,
            semanticLabel: 'Add',
            onPressed: () {},
          ),
        ),
      );
      final colors = tester.element(find.byType(IconAction)).colors;
      expect(decoration(tester).color, isNull);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(IconAction)));
      await tester.pump();
      expect(decoration(tester).color, colors.surfaceSunken);

      await mouse.down(tester.getCenter(find.byType(IconAction)));
      await tester.pump();
      expect(decoration(tester).color, colors.border);
      await mouse.up();
    });

    testWidgets('fades its icon when disabled', (tester) async {
      await _pump(
        tester,
        const Center(
          child: IconAction(
            icon: MemukiIcons.add,
            semanticLabel: 'Add',
            onPressed: null,
          ),
        ),
      );
      final colors = tester.element(find.byType(IconAction)).colors;
      expect(tester.widget<Icon>(find.byType(Icon)).color, colors.textFaint);
    });
  });
}
