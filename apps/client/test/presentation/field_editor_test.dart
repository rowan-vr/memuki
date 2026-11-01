import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';
import 'package:memuki/domain/content/mark_kinds.dart';
import 'package:memuki/domain/content/marked_text.dart';
import 'package:memuki/l10n/generated/app_localizations.dart';
import 'package:memuki/presentation/content/block_editing.dart';
import 'package:memuki/presentation/content/field_controller.dart';
import 'package:memuki/presentation/content/field_editor.dart';
import 'package:memuki/presentation/content/inline_editor.dart';
import 'package:memuki/presentation/content/mark_editing.dart';
import 'package:memuki/presentation/content/marked_text_controller.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

late FieldController _field;
late WidgetTester _tester;

/// The controller of the focused text editor, or else the first.
MarkedTextController get _c {
  final editors = [
    for (final e in _tester.widgetList<EditableText>(
      find.descendant(
        of: find.byType(InlineEditor),
        matching: find.byType(EditableText),
      ),
    ))
      e,
  ];
  final text = editors.where((e) => e.controller is MarkedTextController);
  final focused = text.where((e) => e.focusNode.hasFocus).firstOrNull;
  return (focused ?? text.first).controller as MarkedTextController;
}

String get _source => writeContent(_field.nodes);

/// The text field holding [text].
Finder _editing(String text) =>
    find.byWidgetPredicate((w) => w is TextField && w.controller?.text == text);

Future<void> _pump(
  WidgetTester tester,
  String source, {
  MarkKinds? kinds,
  Map<String, MarkEditing>? editing,
  Set<String>? allowedMarks,
}) async {
  _tester = tester;
  _field = FieldController(parseContent(source).nodes);
  addTearDown(_field.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: FieldEditor(
              controller: _field,
              kinds: kinds,
              editing: editing,
              allowedMarks: allowedMarks,
            ),
          ),
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

    testWidgets('a new ruby asks for its reading', (tester) async {
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
      _field.undo();
      expect(_source, '{ruby x | 天}');
    });
  });

  testWidgets('content can be replaced', (tester) async {
    await _pump(tester, 'a');
    _field.nodes = parseContent('{em | b}').nodes;
    await tester.pump();
    expect(_source, '{em | b}');
    expect(_c.text, 'b');
    expect(_field.canUndo, isTrue);
  });

  group('kinds of mark', () {
    final kinds = MarkKinds([
      const MarkKind(
        'pitch',
        description: 'Where the pitch drops.',
        example: '{pitch 0}',
        scopes: {MarkScope.field},
        args: [MarkArgument('drop', 'The mora before the drop.')],
        content: MarkContent.forbidden,
      ),
      const MarkKind(
        'gloss',
        description: 'A meaning shown above the text.',
        example: '{gloss cross | わたる}',
        scopes: {MarkScope.field},
        args: [MarkArgument('meaning', 'What it means.')],
      ),
    ]);
    final editing = {
      'pitch': MarkEditing(
        label: (_) => 'Pitch',
        glyph: 'P',
        shortcut: const MarkShortcut(LogicalKeyboardKey.keyP, alt: true),
        argumentEditors: {
          'drop': (context, argument) => TextButton(
            focusNode: argument.focusNode,
            onPressed: () {
              argument.onChanged('2');
              argument.onDone();
            },
            child: Text('Drop at 2, now ${argument.value}'),
          ),
        },
      ),
      'gloss': MarkEditing(
        label: (_) => 'Gloss',
        style: (_, _, _) => const TextStyle(fontStyle: FontStyle.italic),
        extendsAtEnd: false,
        annotation: (mark) => mark.args.firstOrNull,
      ),
    };

    testWidgets('come from the registry: label, shortcut, annotation, and '
        'how typing joins them', (tester) async {
      await _pump(tester, 'わたる', kinds: kinds, editing: editing);
      expect(_tool('Pitch'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);

      await _select(tester, 0, 3);
      await tester.tap(_tool('Gloss'));
      await tester.pumpAndSettle();
      expect(find.text('meaning'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'to cross over');
      await tester.pump();
      expect(_source, '{gloss "to cross over" | わたる}');
      expect(_c.annotationOf(_c.ranges.single), 'to cross over');

      final RenderEditable editable = tester
          .state<EditableTextState>(find.byType(EditableText).first)
          .renderEditable;
      final box = editable
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 3),
          )
          .first;
      expect(box.toRect().width, greaterThan(60));

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await _type(tester, 'わたるよ', 4);
      expect(_source, '{gloss "to cross over" | わたる}よ');
    });

    testWidgets('a kind without content goes in at the cursor, and its '
        'arguments use their own editor', (tester) async {
      await _pump(tester, 'はしを', kinds: kinds, editing: editing);
      await _select(tester, 2, 2);
      await _shortcut(tester, LogicalKeyboardKey.keyP, alt: true);
      expect(_source, 'はし{pitch ""}を');
      expect(_c.selection, const TextSelection.collapsed(offset: 3));

      await tester.tap(find.text('Drop at 2, now '));
      await tester.pumpAndSettle();
      expect(_source, 'はし{pitch 2}を');
      expect(find.text('pitch 2'), findsOneWidget);

      // The arguments open again beside the atom, from either side.
      await _select(tester, 2, 2);
      await tester.pump();
      expect(find.text('Drop at 2, now 2'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(_source, 'はしを');
      _field.undo();
      expect(_source, 'はし{pitch 2}を');
    });
  });

  group('atoms', () {
    test('the one beside the cursor is found, before it first', () {
      final c = MarkedTextController(parseContent('{x}{y}a').nodes);
      addTearDown(c.dispose);
      bool any(MarkRange _) => true;
      c.selection = const TextSelection.collapsed(offset: 1);
      expect(c.atomAtSelection(any)?.key, 'x');
      c.selection = const TextSelection.collapsed(offset: 0);
      expect(c.atomAtSelection(any)?.key, 'x');
      c.selection = const TextSelection(baseOffset: 1, extentOffset: 2);
      expect(c.atomAtSelection(any)?.key, 'y');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 2);
      expect(c.atomAtSelection(any), isNull);
      c.selection = const TextSelection.collapsed(offset: 3);
      expect(c.atomAtSelection(any), isNull);
      c.selection = const TextSelection.collapsed(offset: -1);
      expect(c.atomAtSelection(any), isNull);
    });

    test('one put in replaces the selection, and joins the mark it is in, '
        'as one step of undo', () {
      final c = MarkedTextController(parseContent('{em | abc}').nodes);
      addTearDown(c.dispose);
      c.selection = const TextSelection(baseOffset: 1, extentOffset: 2);
      c.insert(const ContentNode.mark('x'));
      expect(writeContent(c.nodes), '{em | a{x}c}');
      c.undo();
      expect(writeContent(c.nodes), '{em | abc}');
      c.selection = const TextSelection.collapsed(offset: -1);
      c.insert(const ContentNode.mark('x'));
      expect(writeContent(c.nodes), '{em | abc}');
    });
  });

  testWidgets('offers only marks within text on the toolbar', (tester) async {
    await _pump(tester, 'a');
    for (final key in ['sense', 'tag', 'list', 'item', 'example', 'forms']) {
      expect(_tool(key), findsNothing, reason: key);
    }
    expect(_tool('Emphasis'), findsOneWidget);
    for (final label in ['Sense', 'List', 'Example']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Tags belong in a sense, which puts them in.
    expect(find.text('Tag'), findsNothing);
  });

  testWidgets('offers only the marks the field allows', (tester) async {
    await _pump(tester, '{ruby x | a}', allowedMarks: {'em', 'list'});
    expect(_tool('Emphasis'), findsOneWidget);
    expect(_tool('Ruby'), findsNothing);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Sense'), findsNothing);
    // Marks it does not allow stay.
    expect(_source, '{ruby x | a}');
  });

  group('blocks', () {
    const entry =
        'note\n{sense | {tag pos n | noun} {list | {item | scenery}}}\nend';

    testWidgets('stand between text, with their text edited in place', (
      tester,
    ) async {
      await _pump(tester, entry);
      expect(_editing('note'), findsOneWidget);
      expect(_editing('scenery'), findsOneWidget);
      expect(_editing('end'), findsOneWidget);
      expect(find.text('noun'), findsOneWidget);

      await tester.enterText(_editing('scenery'), 'view');
      await tester.pump();
      expect(
        _source,
        'note\n{sense | {tag pos n | noun}{list | {item | view}}}\nend',
      );

      // Marks within text work there too.
      await _select(tester, 0, 4);
      await tester.tap(_tool('Emphasis'));
      await tester.pump();
      expect(_source, contains('{item | {em | view}}'));
    });

    testWidgets('a list adds and removes items', (tester) async {
      await _pump(tester, '{list | {item | a}}');
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      expect(_source, '{list | {item | a}{item |}}');
      // The new item is focused, to type in.
      expect(_c.text, '');
      tester.testTextInput.enterText('b');
      await tester.pump();
      expect(_source, '{list | {item | a}{item | b}}');

      await tester.tap(find.byTooltip('Remove item').first);
      await tester.pumpAndSettle();
      expect(_source, '{list | {item | b}}');
    });

    testWidgets('Enter in an item starts the next one after it', (
      tester,
    ) async {
      await _pump(tester, '{list | {item | a}{item | c}}');
      await tester.showKeyboard(_editing('a'));
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(_source, '{list | {item | a}{item |}{item | c}}');
      tester.testTextInput.enterText('b');
      await tester.pump();
      expect(_source, '{list | {item | a}{item | b}{item | c}}');
    });

    testWidgets('an example has its sentence and its translation', (
      tester,
    ) async {
      await _pump(tester, '{example | 景色がいい。{translation | Nice view.}}');
      await tester.enterText(_editing('Nice view.'), 'The view is nice.');
      await tester.pump();
      expect(_source, '{example | 景色がいい。{translation | The view is nice.}}');
    });

    testWidgets('the toolbox puts one in at the cursor, splitting the text', (
      tester,
    ) async {
      await _pump(tester, 'abcd');
      await _select(tester, 2, 2);
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      expect(_source, 'ab\n{list | {item |}}\ncd');
      // Its first item is focused, to type in.
      tester.testTextInput.enterText('x');
      await tester.pump();
      expect(_source, 'ab\n{list | {item | x}}\ncd');
    });

    testWidgets('dragged from the toolbox, drop between the parts', (
      tester,
    ) async {
      await _pump(tester, 'abcd');
      // On touch screens, after a long press.
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Example')),
      );
      await tester.pump(kLongPressTimeout);
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      // Before the text, and after it.
      final zones = find.byType(DragTarget<ToolboxDrag>);
      expect(zones, findsNWidgets(2));
      await gesture.moveTo(tester.getCenter(zones.last));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_source, 'abcd\n{example | {translation |}}');
      expect(find.byType(DragTarget<ToolboxDrag>), findsNothing);
    });

    testWidgets('a sense adds tags from its own button', (tester) async {
      await _pump(tester, '{sense | {list | {item | a}}}');
      // It stands in for the tags while there are none.
      await tester.tap(find.text('Add tag'));
      await tester.pumpAndSettle();
      expect(_source, '{sense | {tag pos "" |}{list | {item | a}}}');

      // A new tag opens to fill in.
      await tester.enterText(find.widgetWithText(TextField, 'Label'), 'noun');
      await tester.pump();
      expect(_source, '{sense | {tag pos "" | noun}{list | {item | a}}}');
      await tester.tap(find.byTooltip('Done'));
      await tester.pumpAndSettle();
      expect(find.text('noun'), findsOneWidget);
      expect(find.text('Add tag'), findsOneWidget);
    });

    testWidgets('the first part of a block can be removed', (tester) async {
      await _pump(tester, '{sense | {example | a}{list | {item | b}}}');
      await tester.tap(find.byTooltip('Remove').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_source, '{sense | {list | {item | b}}}');
    });

    testWidgets("a sense's list cannot be removed", (tester) async {
      await _pump(tester, '{sense | {list | {item | a}}}');
      // Only the sense's own button can be pressed.
      final remove = find.byTooltip('Remove');
      expect(remove, findsOneWidget);
      await tester.tap(remove);
      await tester.pumpAndSettle();
      expect(_source, '');
    });

    testWidgets('are removed, joining the text around them', (tester) async {
      await _pump(tester, entry);
      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();
      expect(_source, 'note\nend');
      expect(_editing('note\nend'), findsOneWidget);
    });

    testWidgets('undo takes back typing in them and putting them in', (
      tester,
    ) async {
      await _pump(tester, 'ab');
      await _select(tester, 2, 2);
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      tester.testTextInput.enterText('x');
      await tester.pump();
      tester.testTextInput.enterText('xy');
      await tester.pump();
      expect(_source, 'ab\n{list | {item | xy}}');

      await tester.tap(_tool('Undo'));
      await tester.pumpAndSettle();
      expect(_source, 'ab\n{list | {item |}}');
      await tester.tap(_tool('Undo'));
      await tester.pumpAndSettle();
      expect(_source, 'ab');
      expect(find.text('Add item'), findsNothing);

      await tester.tap(_tool('Redo'));
      await tester.pumpAndSettle();
      expect(_source, 'ab\n{list | {item |}}');
    });

    testWidgets('kinds without an editor are edited as source', (tester) async {
      await _pump(tester, '{forms | {form 景色 reading=けしき}}');
      await tester.tap(find.text('景色【けしき】'));
      await tester.pumpAndSettle();
      expect(find.text('Source'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Source'),
        '{forms | {form 景色}}',
      );
      await tester.pump();
      expect(_source, '{forms | {form 景色}}');

      // Source that is not one mark waits.
      await tester.enterText(find.widgetWithText(TextField, 'Source'), '{x');
      await tester.pump();
      expect(_source, '{forms | {form 景色}}');
    });

    testWidgets('are text without a registry of blocks', (tester) async {
      _tester = tester;
      _field = FieldController(parseContent('{list | {item | a}}').nodes);
      addTearDown(_field.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FieldEditor(controller: _field, blocks: const {}),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Add item'), findsNothing);
      expect(find.text('Sense'), findsNothing);
      expect(_c.text, 'a');
    });
  });
}
