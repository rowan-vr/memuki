import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';
import 'package:memuki/domain/content/mark_kinds.dart';
import 'package:memuki/l10n/generated/app_localizations.dart';
import 'package:memuki/presentation/content/field_editor.dart';
import 'package:memuki/presentation/content/marked_text_controller.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

late MarkedTextController _c;

String get _source => writeContent(_c.nodes);

Future<void> _pump(
  WidgetTester tester,
  String source, {
  MarkKinds? kinds,
}) async {
  _c = MarkedTextController(parseContent(source).nodes);
  addTearDown(_c.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FieldEditor(controller: _c, kinds: kinds),
        ),
      ),
    ),
  );
  await tester.tap(find.byType(TextField).first);
  await tester.pump();
}

/// Composes [reading] at [at] the way a Japanese input method does, then
/// converts it to [result].
Future<void> _compose(
  WidgetTester tester,
  int at,
  String reading,
  String result,
) async {
  final before = _c.text;
  for (var i = 1; i <= reading.length; i++) {
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: before.replaceRange(at, at, reading.substring(0, i)),
        selection: TextSelection.collapsed(offset: at + i),
        composing: TextRange(start: at, end: at + i),
      ),
    );
    await tester.pump();
  }
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: before.replaceRange(at, at, result),
      selection: TextSelection.collapsed(offset: at + result.length),
    ),
  );
  await tester.pump();
}

Future<void> _type(WidgetTester tester, String text, int cursor) async {
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    ),
  );
  await tester.pump();
}

Future<void> _select(WidgetTester tester, int start, int end) async {
  _c.selection = TextSelection(baseOffset: start, extentOffset: end);
  await tester.pump();
}

Future<void> _shortcut(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool alt = false,
  LogicalKeyboardKey modifier = LogicalKeyboardKey.controlLeft,
}) async {
  await tester.sendKeyDownEvent(modifier);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(key);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

Finder _tool(String label) => find.byTooltip(label);

void main() {
  group('typing', () {
    testWidgets('a conversion inside or at the end of a mark stays in it', (
      tester,
    ) async {
      await _pump(tester, '今日は{em | いい}です');
      await _compose(tester, 4, 'とても', '迚も');
      expect(_source, '今日は{em | い迚もい}です');
      await _compose(tester, 7, 'ね', '値');
      expect(_source, '今日は{em | い迚もい値}です');
    });

    testWidgets('text typed after a ruby stays outside it', (tester) async {
      await _pump(tester, '{ruby てんき | 天気}');
      await _compose(tester, 2, 'が', 'が');
      expect(_source, '{ruby てんき | 天気}が');
    });

    testWidgets('a comment is one character, deleted whole', (tester) async {
      await _pump(tester, 'a{# note}b');
      expect(find.text('# note'), findsOneWidget);
      await _type(tester, 'ab', 1);
      expect(_source, 'ab');
    });
  });

  group('marks', () {
    testWidgets('the toolbar toggles marks and lights up for them', (
      tester,
    ) async {
      await _pump(tester, '今日はいい天気');
      await _select(tester, 3, 5);
      await tester.tap(_tool('Emphasis'));
      await tester.pumpAndSettle();
      expect(_source, '今日は{em | いい}天気');

      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Emphasis').first),
        isSemantics(isSelected: true),
      );
      semantics.dispose();

      await tester.tap(_tool('Emphasis'));
      await tester.pumpAndSettle();
      expect(_source, '今日はいい天気');
    });

    testWidgets('shortcuts toggle marks', (tester) async {
      await _pump(tester, 'H2O x2');
      await _select(tester, 1, 2);
      await _shortcut(tester, LogicalKeyboardKey.equal);
      await _select(tester, 5, 6);
      await _shortcut(tester, LogicalKeyboardKey.equal, shift: true);
      await _select(tester, 0, 1);
      await _shortcut(tester, LogicalKeyboardKey.keyB);
      expect(_source, '{em | H}{sub | 2}O x{sup | 2}');
    });

    testWidgets('Apple platforms use the command key', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _pump(tester, 'ab');
      await _select(tester, 0, 1);
      await _shortcut(
        tester,
        LogicalKeyboardKey.keyB,
        modifier: LogicalKeyboardKey.metaLeft,
      );
      expect(_source, '{em | a}b');
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a new ruby asks for its reading', (
      tester,
    ) async {
      await _pump(tester, '天気');
      await _select(tester, 0, 2);
      await _shortcut(tester, LogicalKeyboardKey.keyR, alt: true);
      expect(find.text('Reading'), findsOneWidget);
      expect(_source, '{ruby "" | 天気}');

      await tester.enterText(find.byType(TextField).last, 'てんき');
      await tester.pump();
      expect(_source, '{ruby てんき | 天気}');

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(_source, '天気');
      expect(find.text('Reading'), findsNothing);
    });

    testWidgets('the reading opens under its mark, even far down a long '
        'field', (tester) async {
      await _pump(tester, '${'あ' * 300}{ruby もも | 桃}${'い' * 100}');
      final at = _c.text.indexOf('桃');
      await _select(tester, at + 1, at + 1);
      await tester.pump();
      final field = tester.getRect(find.byType(TextField).first);
      final reading = tester.getRect(find.text('Reading'));
      final RenderEditable editable = tester
          .state<EditableTextState>(find.byType(EditableText).first)
          .renderEditable;
      final box = editable
          .getBoxesForSelection(
            TextSelection(baseOffset: at, extentOffset: at + 1),
          )
          .single;
      final under = editable.localToGlobal(Offset(box.left, box.bottom));
      expect(reading.top, greaterThan(under.dy));
      expect(reading.top, lessThan(under.dy + 48));
      expect(reading.bottom, lessThan(field.bottom));
    });

    testWidgets('the reading follows the cursor and hands focus back', (
      tester,
    ) async {
      await _pump(tester, '{ruby てん | 天}とか{ruby ち | 地}');
      await _select(tester, 1, 1);
      await tester.pump();
      expect(find.text('てん'), findsOneWidget);
      await _select(tester, 4, 4);
      await tester.pump();
      expect(find.text('てん'), findsNothing);
      expect(find.text('ち'), findsOneWidget);

      final editor = find.byType(TextField).first;
      final reading = find.byType(TextField).last;
      await tester.tap(reading);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(tester.widget<TextField>(editor).focusNode!.hasFocus, isTrue);

      await tester.tap(reading);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(tester.widget<TextField>(editor).focusNode!.hasFocus, isTrue);

      await _select(tester, 2, 2);
      await tester.pump();
      expect(find.text('Reading'), findsNothing);
    });

    testWidgets('a reading wider than its base text spreads the base text', (
      tester,
    ) async {
      await _pump(tester, '{ruby むかしむかし | 昔}{ruby き | 木}{ruby "" | 森}');
      final editable = tester
          .state<EditableTextState>(find.byType(EditableText).first)
          .renderEditable;
      double width(int at) => editable
          .getBoxesForSelection(
            TextSelection(baseOffset: at, extentOffset: at + 1),
          )
          .single
          .toRect()
          .width;
      expect(width(0), greaterThan(width(1) * 2));
      expect(width(1), width(2));
    });

    testWidgets('a language mark asks for its tag', (tester) async {
      await _pump(tester, '你好');
      await _select(tester, 0, 2);
      await _shortcut(tester, LogicalKeyboardKey.keyL, alt: true);
      await tester.enterText(find.byType(TextField).last, 'zh-Hans');
      await tester.pump();
      expect(_source, '{lang zh-Hans | 你好}');
    });

    testWidgets('marks of other kinds offer their arguments by name', (
      tester,
    ) async {
      final kinds = MarkKinds([
        const MarkKind(
          'pitch',
          description: 'Pitch accent.',
          example: '{pitch 0 | はし}',
          scopes: {MarkScope.field},
          args: [MarkArgument('drop', 'Where the pitch drops.')],
        ),
      ]);
      await _pump(tester, '{pitch 0 | はし}', kinds: kinds);
      await _select(tester, 1, 1);
      expect(find.text('drop'), findsOneWidget);
      expect(find.byTooltip('pitch'), findsOneWidget);
    });

    testWidgets('the selection menu offers the marks', (tester) async {
      // The desktop menu lists every item, with no overflow.
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _pump(tester, 'abc');
      await _select(tester, 0, 2);
      final state = tester.state<EditableTextState>(
        find.byType(EditableText).first,
      );
      state.showToolbar();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Superscript'));
      await tester.pumpAndSettle();
      expect(_source, '{sup | ab}c');
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('undo', () {
    testWidgets('takes back marks and typing, and redoes them', (tester) async {
      await _pump(tester, 'ab');
      await _select(tester, 0, 1);
      await _shortcut(tester, LogicalKeyboardKey.keyB);
      await _type(tester, 'abX', 3);
      await _type(tester, 'abXY', 4);
      expect(_source, '{em | a}bXY');

      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(_source, '{em | a}b');
      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(_source, 'ab');
      await _shortcut(tester, LogicalKeyboardKey.keyZ, shift: true);
      expect(_source, '{em | a}b');
      await _shortcut(tester, LogicalKeyboardKey.keyY);
      expect(_source, '{em | a}bXY');
    });

    testWidgets('brings back a mark whose text was deleted', (tester) async {
      await _pump(tester, 'a{em | b}c');
      await _type(tester, 'ac', 1);
      expect(_source, 'ac');
      await tester.tap(_tool('Undo'));
      await tester.pumpAndSettle();
      expect(_source, 'a{em | b}c');
      await tester.tap(_tool('Redo'));
      await tester.pumpAndSettle();
      expect(_source, 'ac');
    });

    testWidgets('a space ends a step', (tester) async {
      await _pump(tester, '');
      await _type(tester, 'a', 1);
      await _type(tester, 'ab', 2);
      await _type(tester, 'ab ', 3);
      await _type(tester, 'ab c', 4);
      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(_source, 'ab');
    });

    testWidgets('typing a reading is one step', (tester) async {
      await _pump(tester, '{ruby x | 天}');
      await _select(tester, 1, 1);
      final reading = find.byType(TextField).last;
      await tester.enterText(reading, 'て');
      await tester.enterText(reading, 'てん');
      expect(_source, '{ruby てん | 天}');
      _c.undo();
      expect(_source, '{ruby x | 天}');
    });
  });

  testWidgets('content can be replaced', (tester) async {
    await _pump(tester, 'a');
    _c.nodes = parseContent('{em | b}').nodes;
    await tester.pump();
    expect(_source, '{em | b}');
    expect(_c.canUndo, isTrue);
  });
}
