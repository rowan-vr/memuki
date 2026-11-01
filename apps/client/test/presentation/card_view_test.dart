import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/card_renderer.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/presentation/content/card_view.dart';
import 'package:memuki/presentation/content/content_view.dart';
import 'package:memuki/presentation/theme/app_theme.dart';
import 'package:memuki/presentation/theme/memuki_colors.dart';
import 'package:memuki/presentation/theme/memuki_layout.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Appearance appearance = const Appearance(),
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(appearance),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

/// The text span of the first [Text] showing [text].
TextSpan _span(WidgetTester tester, String text) {
  final rich = tester.widget<RichText>(
    find
        .byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains(text),
        )
        .last,
  );
  TextSpan? found;
  rich.text.visitChildren((span) {
    if (span is TextSpan && span.text == text) {
      found = span;
      return false;
    }
    return true;
  });
  return found!;
}

void main() {
  group('ContentView', () {
    testWidgets('styles marks by kind', (tester) async {
      await _pump(
        tester,
        ContentView(
          parseContent('a{em | b}{lang zh-Hans | c}{pitch 0 | d}{# e}').nodes,
        ),
      );
      final context = tester.element(find.byType(ContentView));
      expect(_span(tester, 'a').style!.fontWeight, isNot(FontWeight.w700));
      expect(_span(tester, 'b').style!.fontWeight, FontWeight.w700);
      expect(_span(tester, 'b').style!.color, context.colors.accent.onSoft);
      expect(
        _span(tester, 'c').style!.locale,
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      );
      // A kind without an entry shows its content; comments show nothing.
      expect(find.textContaining('d', findRichText: true), findsWidgets);
      expect(find.textContaining('e', findRichText: true), findsNothing);
    });

    testWidgets('stacks a reading over its base text, on the line', (
      tester,
    ) async {
      await _pump(
        tester,
        ContentView(parseContent('今日は{ruby てんき | 天気}です').nodes),
      );
      final base = tester.getRect(find.text('天気'));
      final reading = tester.getRect(find.text('てんき'));
      expect(reading.bottom, lessThanOrEqualTo(base.top + 0.01));
      expect(reading.center.dx, closeTo(base.center.dx, 0.5));
      // The base text sits on the line's baseline, so in line with its
      // neighbours.
      final line = tester.getRect(find.byType(ContentView));
      expect(base.bottom, closeTo(line.bottom, 1));
      final style = tester.widget<Text>(find.text('てんき')).style!;
      expect(style.fontSize, context(tester).type.body.fontSize! * 0.5);
    });

    testWidgets('a reading wider than its base text widens the group', (
      tester,
    ) async {
      await _pump(tester, ContentView(parseContent('{ruby たまわる | 賜}').nodes));
      final base = tester.getRect(find.text('賜'));
      final reading = tester.getRect(find.text('たまわる'));
      expect(reading.width, greaterThan(base.width));
      expect(reading.center.dx, closeTo(base.center.dx, 0.5));
    });

    testWidgets('moves subscripts down and superscripts up, smaller', (
      tester,
    ) async {
      await _pump(
        tester,
        ContentView(parseContent('H{sub | 2}x{sup | 3}').nodes),
      );
      final size = context(tester).type.body.fontSize!;
      expect(_span(tester, '2').style!.fontSize, size * 0.7);
      expect(_span(tester, '3').style!.fontSize, size * 0.7);
      final sub = tester.getRect(
        find.textContaining('2', findRichText: true).last,
      );
      final sup = tester.getRect(
        find.textContaining('3', findRichText: true).last,
      );
      expect(sub.center.dy, greaterThan(sup.center.dy));
    });

    testWidgets('text in a group is scaled once, with its line', (
      tester,
    ) async {
      Future<double> readingHeight(double scale) async {
        await _pump(
          tester,
          ContentView(parseContent('{ruby てんき | 天気}').nodes),
          scale: scale,
        );
        // Measured on screen, after the group is scaled.
        return tester.getRect(find.text('てんき')).height;
      }

      final one = await readingHeight(1);
      final two = await readingHeight(2);
      expect(two / one, closeTo(2, 0.05));
    });
  });

  group('CardView', () {
    final card = renderCard(
      parseContent('''
{front | {field Word role=prompt}}
{back |
  {field Reading role=reading}
  {field Meaning role=answer}
  {field Example role=example}
  {field Note}
}''').nodes,
      {
        for (final (name, value) in [
          ('Word', '{ruby ねこ | 猫}'),
          ('Reading', 'neko'),
          ('Meaning', 'cat'),
          ('Example', 'ex'),
          ('Note', 'note'),
        ])
          name: parseContent(value).nodes,
      },
    );

    testWidgets('shows the back only when revealed', (tester) async {
      await _pump(tester, CardView(card: card));
      expect(find.text('猫'), findsOneWidget);
      expect(find.textContaining('cat', findRichText: true), findsNothing);
      await _pump(tester, CardView(card: card, revealed: true));
      expect(find.text('猫'), findsOneWidget);
      expect(find.textContaining('cat', findRichText: true), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('styles each field by its role', (tester) async {
      await _pump(tester, CardView(card: card, revealed: true));
      final c = context(tester);
      expect(_span(tester, '猫').style!.fontSize, 44);
      expect(_span(tester, 'neko').style!.fontSize, 18);
      expect(_span(tester, 'neko').style!.color, c.colors.textMuted);
      expect(_span(tester, 'cat').style!.fontSize, c.type.title.fontSize);
      expect(_span(tester, 'ex').style!.color, c.colors.textMuted);
      expect(_span(tester, 'note').style!.fontSize, c.type.body.fontSize);
    });

    testWidgets('draws in every card style, light and dark', (tester) async {
      for (final mode in [ColorMode.light, ColorMode.dark]) {
        for (final style in CardStyle.values) {
          final reason = '${mode.name} ${style.name}';
          await _pump(
            tester,
            CardView(card: card, revealed: true),
            appearance: Appearance(mode: mode, cardStyle: style),
            scale: 2,
          );
          expect(find.text('猫'), findsOneWidget, reason: reason);
          expect(tester.takeException(), isNull, reason: reason);
        }
      }
    });
  });
}

BuildContext context(WidgetTester tester) =>
    tester.element(find.byType(Scaffold));
