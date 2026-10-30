import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memuki/domain/content/mark_kinds.dart';
import 'package:memuki/presentation/components/panel.dart';
import 'package:memuki/presentation/developer/content_playground_screen.dart';
import 'package:memuki/presentation/developer/content_warnings.dart';
import 'package:memuki/presentation/developer/developer_screen.dart';

import '../helpers/pump_app.dart';

Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
}) async {
  await tester.pumpApp(size: size);
  await tester.tap(find.text('Developer').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Content format'));
  await tester.pumpAndSettle();
  expect(find.byType(ContentPlaygroundScreen), findsOneWidget);
}

Future<void> _type(WidgetTester tester, String source) async {
  await tester.enterText(find.byType(TextField).first, source);
  await tester.pumpAndSettle();
}

/// The text of the output under [label].
String _output(WidgetTester tester, String label) {
  final column = find.ancestor(
    of: find.text(label),
    matching: find.byType(Column),
  );
  final text = tester.widget<SelectableText>(
    find.descendant(of: column.first, matching: find.byType(SelectableText)),
  );
  return text.data!;
}

/// The line of the kind [key], which opens and closes it.
Finder _row(String key) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(key));

/// The title of the warning on the banner, or 'None' when there is none.
String _warning(WidgetTester tester) {
  final banner = find.byType(WarningBanner);
  if (banner.evaluate().isEmpty) return 'None';
  return tester
      .widget<Text>(
        find.descendant(of: banner, matching: find.byType(Text)).first,
      )
      .data!;
}

Future<void> _scope(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the developer page opens the playground', (tester) async {
    await _open(tester);
    expect(
      find.text('Mark kinds (${MarkKinds.builtIn.all.length})'),
      findsOneWidget,
    );

    GoRouter.of(tester.element(find.byType(ContentPlaygroundScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(DeveloperScreen), findsOneWidget);
  });

  testWidgets('shows the plain text and canonical source', (tester) async {
    await _open(tester);
    await _type(tester, '{ruby てんき|  天気 }が{em|いい}');

    expect(_output(tester, 'Plain text'), '天気がいい');
    expect(_output(tester, 'Canonical source'), '{ruby てんき | 天気}が{em | いい}');
    expect(_warning(tester), 'None');
  });

  testWidgets('lists problems with their line and column', (tester) async {
    await _open(tester);
    await _type(tester, 'a\nb}{em}');

    expect(_warning(tester), 'Stray close');
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Line 2, column 2'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Previous warning'));
    await tester.pumpAndSettle();
    expect(_warning(tester), 'Stray close');

    await tester.tap(find.bySemanticsLabel('Next warning'));
    await tester.pumpAndSettle();
    expect(_warning(tester), 'Missing content');
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('{em}'), findsOneWidget);

    // One fewer warning leaves the banner on the last.
    await _type(tester, 'a\nb}');
    expect(_warning(tester), 'Stray close');
    expect(find.text('1/2'), findsNothing);
  });

  testWidgets('says when the content is empty', (tester) async {
    await _open(tester);
    await _type(tester, '');

    expect(_output(tester, 'Plain text'), '(empty)');
    expect(find.text('(empty)'), findsWidgets);
  });

  testWidgets('fields and templates start with a sample and keep their own '
      'source', (tester) async {
    await _open(tester);
    expect(_warning(tester), 'None');
    await _type(tester, '{em | a}');

    await _scope(tester, 'Template');
    expect(_warning(tester), 'None');
    expect(find.text('Word · prompt'), findsOneWidget);

    await _scope(tester, 'Field');
    expect(_output(tester, 'Plain text'), 'a');
  });

  testWidgets('problems show on a banner', (tester) async {
    await _open(tester);
    await _type(tester, '{field Word}');
    expect(_warning(tester), 'Not allowed here');
    await _type(tester, 'fine');
    expect(_warning(tester), 'None');
  });

  testWidgets('previews a template', (tester) async {
    await _open(tester);
    await _scope(tester, 'Template');
    await _type(
      tester,
      '{front | {field Word role=prompt}}\n{back | {# hidden}x}\n{requires Word}',
    );
    expect(_warning(tester), 'None');
    expect(find.text('Word · prompt'), findsOneWidget);
    expect(find.text('Requires Word'), findsOneWidget);
    final preview = find
        .ancestor(of: find.text('front'), matching: find.byType(Panel))
        .first;
    expect(
      find.descendant(
        of: preview,
        matching: find.textContaining('hidden', findRichText: true),
      ),
      findsNothing,
    );
  });

  testWidgets('names what a template issue is about', (tester) async {
    await _open(tester);
    await _scope(tester, 'Template');
    await _type(tester, 'hi\n{front | x}');
    expect(_warning(tester), 'Outside the sides');
    expect(find.text('hi'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Next warning'));
    await tester.pumpAndSettle();
    expect(_warning(tester), 'No "back"');
  });

  testWidgets('previews every built-in example', (tester) async {
    await _open(tester);
    for (final kind in MarkKinds.builtIn.all) {
      await _scope(
        tester,
        kind.scopes.first == MarkScope.template ? 'Template' : 'Field',
      );
      await _type(tester, kind.example);
      // Examples show one mark, not a whole template.
      expect(
        _warning(tester),
        anyOf('None', 'Outside the sides', 'No "front"', 'No "back"'),
        reason: kind.key,
      );
    }
    await _type(tester, '{pitch 0 | はし}{lang | x}{if | y}');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a kind opens to its details, and Try uses its example', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Try'), findsNothing);

    await tester.tap(_row('ruby'));
    await tester.pumpAndSettle();
    expect(find.textContaining('reading', findRichText: true), findsWidgets);
    await tester.tap(find.text('Try'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      MarkKinds.builtIn['ruby']!.example,
    );

    await tester.tap(_row('ruby'));
    await tester.pumpAndSettle();
    expect(find.text('Try'), findsNothing);
  });

  testWidgets('the filter narrows the kinds', (tester) async {
    Future<void> filter(String query) async {
      await tester.enterText(find.byType(TextField).last, query);
      await tester.pumpAndSettle();
    }

    await _open(tester);
    await filter('value goes');
    expect(find.byKey(const ValueKey('field')), findsOneWidget);
    expect(find.byKey(const ValueKey('ruby')), findsNothing);
    await tester.tap(_row('field'));
    await tester.pumpAndSettle();
    expect(find.textContaining('role=', findRichText: true), findsWidgets);

    await filter('REQUIRES');
    await tester.tap(_row('requires'));
    await tester.pumpAndSettle();
    expect(find.textContaining('name …', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('top level', findRichText: true),
      findsOneWidget,
    );

    await filter('nothing like this');
    expect(find.text('No kinds match.'), findsOneWidget);
  });

  testWidgets('narrow windows stack the kinds under the playground', (
    tester,
  ) async {
    await _open(tester, size: const Size(400, 800));
    await tester.scrollUntilVisible(
      find.textContaining('Mark kinds'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Mark kinds'), findsOneWidget);
  });
}
