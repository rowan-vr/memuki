import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/template_layout.dart';
import 'package:memuki/l10n/generated/app_localizations.dart';
import 'package:memuki/presentation/components/icons.dart';
import 'package:memuki/presentation/components/menu.dart';
import 'package:memuki/presentation/content/field_editor.dart';
import 'package:memuki/presentation/content/template_editor.dart';
import 'package:memuki/presentation/theme/app_theme.dart';

const _fields = ['Word', 'Reading', 'Meaning', 'Example'];

const _vocabulary = '''
{front |
  {field Word role=prompt}
}
{back |
  {field Reading role=reading}
  {field Meaning role=answer}
  {if Example | {field Example role=example}}
}
{requires Word}''';

/// The source of the last layout the editor reported.
String? _reported;

Future<void> _pump(
  WidgetTester tester,
  String source, {
  List<String> fields = _fields,
}) async {
  _reported = null;
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: TemplateEditor(
            layout: TemplateLayout.read(parseContent(source).nodes)!,
            fields: fields,
            onChanged: (layout) => _reported = layout.write(),
          ),
        ),
      ),
    ),
  );
}

/// The picker whose semantic label starts with [label], [index] in order.
Finder _picker(String label, [int index = 0]) => find
    .byWidgetPredicate((w) => w is MenuChip && w.semanticLabel == label)
    .at(index);

/// Opens [picker] and picks [choice] from its menu.
Future<void> _pick(WidgetTester tester, Finder picker, String choice) async {
  final before = find.text(choice).evaluate().toSet();
  await tester.tap(picker);
  await tester.pumpAndSettle();
  final item = find
      .text(choice)
      .evaluate()
      .firstWhere((e) => !before.contains(e));
  await tester.tap(find.byElementPredicate((e) => e == item));
  await tester.pumpAndSettle();
}

/// Adds a line of [kind] from the add menu, [index] in order.
Future<void> _add(WidgetTester tester, String kind, [int index = 0]) async {
  await _pick(
    tester,
    find.bySemanticsLabel(RegExp(r'^Add( line)?$')).at(index),
    kind,
  );
}

/// Opens the menu of the line [index] in order and picks [action].
Future<void> _act(WidgetTester tester, int index, String action) async {
  await _pick(tester, find.byIcon(MemukiIcons.more).at(index), action);
}

void main() {
  testWidgets('shows each line as what it is', (tester) async {
    await _pump(tester, _vocabulary);
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(_picker('Field'), findsOneWidget);
    expect(find.text('Word'), findsWidgets);
    expect(find.text('Prompt'), findsOneWidget);
    expect(find.text('Answer'), findsOneWidget);
    expect(find.text('as'), findsNWidgets(4));
    expect(find.text('If'), findsOneWidget);
    expect(find.text('is filled'), findsOneWidget);
    expect(_reported, isNull);
  });

  testWidgets('picks a field and a role', (tester) async {
    await _pump(tester, _vocabulary);
    await _pick(tester, _picker('Field'), 'Meaning');
    expect(_reported, contains('{field Meaning role=prompt}'));
    await _pick(tester, _picker('Role'), 'No role');
    expect(_reported, contains('{front |\n  {field Meaning}\n}'));
    await _pick(tester, _picker('Role'), 'Example');
    expect(_reported, contains('{field Meaning role=example}'));
  });

  testWidgets('a menu closes when tapped outside or with Escape', (
    tester,
  ) async {
    await _pump(tester, _vocabulary);
    await tester.tap(_picker('Role'));
    await tester.pumpAndSettle();
    expect(find.text('No role'), findsOneWidget);
    await tester.tapAt(const Offset(880, 2380));
    await tester.pumpAndSettle();
    expect(find.text('No role'), findsNothing);
  });

  testWidgets('keeps fields and roles it does not know', (tester) async {
    await _pump(tester, '{front | {field Gone role=hint}}{back | }');
    expect(find.text('Gone (not in this note type)'), findsOneWidget);
    expect(find.text('hint'), findsOneWidget);
    await _pick(tester, _picker('Role'), 'Answer');
    expect(_reported, contains('{field Gone role=answer}'));
  });

  testWidgets('adds, moves, and removes lines', (tester) async {
    await _pump(tester, '{front | }{back | }');
    expect(find.text('Nothing here yet.'), findsNWidgets(2));
    await _add(tester, 'Field');
    expect(_reported, startsWith('{front |\n  {field Word}\n}'));

    await _add(tester, 'Condition');
    expect(_reported, contains('  {if Word |\n  }\n'));

    await _act(tester, 1, 'Move up');
    expect(
      _reported,
      startsWith('{front |\n  {if Word |\n  }\n  {field Word}'),
    );

    await _act(tester, 0, 'Move down');
    expect(_reported, startsWith('{front |\n  {field Word}\n  {if Word'));

    await _act(tester, 0, 'Remove');
    expect(_reported, startsWith('{front |\n  {if Word |\n  }\n}'));
  });

  testWidgets('the line menu cannot move a line past the ends', (tester) async {
    await _pump(tester, _vocabulary);
    await tester.tap(find.byIcon(MemukiIcons.more).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move up'));
    await tester.tap(find.text('Move down'));
    await tester.pumpAndSettle();
    expect(_reported, isNull);
  });

  testWidgets('menus stay on screen at the right edge', (tester) async {
    await _pump(tester, _vocabulary);
    await tester.tap(find.byIcon(MemukiIcons.more).first);
    await tester.pumpAndSettle();
    final menu = tester.getRect(find.text('Move down'));
    expect(menu.right, lessThanOrEqualTo(900));
  });

  testWidgets('the add menu says what each kind of line is', (tester) async {
    await _pump(tester, _vocabulary);
    await tester.tap(find.bySemanticsLabel('Add line').first);
    await tester.pumpAndSettle();
    expect(find.text('Shows a field, styled by its role.'), findsOneWidget);
    expect(find.text('The same text on every card.'), findsOneWidget);
    expect(
      find.text('Lines shown only when a field is filled.'),
      findsOneWidget,
    );
  });

  testWidgets('a condition offers no further conditions', (tester) async {
    await _pump(tester, _vocabulary);
    await tester.tap(find.bySemanticsLabel('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Condition'), findsNothing);
  });

  testWidgets('lines are reordered by dragging', (tester) async {
    await _pump(tester, _vocabulary);
    final handle = find.byIcon(MemukiIcons.drag);
    // The reading, dragged below the meaning.
    final gesture = await tester.startGesture(tester.getCenter(handle.at(1)));
    await tester.pump(kLongPressTimeout);
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 8));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      _reported,
      contains(
        '  {field Meaning role=answer}\n  {field Reading role=reading}\n',
      ),
    );
  });

  testWidgets('a condition holds lines and picks its field', (tester) async {
    await _pump(tester, _vocabulary);
    await _pick(tester, _picker('Only when filled'), 'Meaning');
    expect(_reported, contains('{if Meaning | {field Example role=example}}'));
    await _add(tester, 'Text', 1);
    expect(find.byType(FieldEditor), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'note');
    await tester.pumpAndSettle();
    expect(
      _reported,
      contains(
        '  {if Meaning |\n'
        '    {field Example role=example}\n'
        '    note\n'
        '  }\n',
      ),
    );
  });

  testWidgets('text lines use the field editor', (tester) async {
    await _pump(tester, '{front | Meaning: {em | of}}{back | }');
    expect(find.byType(FieldEditor), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Word');
    await tester.pumpAndSettle();
    expect(_reported, startsWith('{front |\n  Word\n}'));
  });

  testWidgets('lines that fit no other kind are edited as source', (
    tester,
  ) async {
    await _pump(tester, '{front | The word {field Word}}{back | }');
    expect(find.text('Source'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'A {em | {field Word}}');
    await tester.pumpAndSettle();
    expect(_reported, startsWith('{front |\n  A {em | {field Word}}\n}'));
  });

  testWidgets('required fields are a checklist', (tester) async {
    await _pump(tester, _vocabulary);
    expect(
      tester.getSemantics(find.text('Word').last),
      matchesSemantics(
        isChecked: true,
        hasCheckedState: true,
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
        label: 'Word',
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Meaning').last);
    await tester.pumpAndSettle();
    expect(_reported, endsWith('{requires Word Meaning}'));
    await tester.tap(find.text('Word').last);
    await tester.pumpAndSettle();
    expect(_reported, endsWith('{requires Meaning}'));
    await tester.tap(find.text('Meaning').last);
    await tester.pumpAndSettle();
    expect(_reported, endsWith('}'));
    expect(_reported, isNot(contains('requires')));
  });

  testWidgets('a required field the note type lacks can be unchecked', (
    tester,
  ) async {
    await _pump(tester, '{front | }{back | }{requires Gone}');
    await tester.tap(find.text('Gone (not in this note type)'));
    await tester.pumpAndSettle();
    expect(_reported, isNot(contains('requires')));
  });

  testWidgets('without fields, only text can be added', (tester) async {
    await _pump(tester, '{front | }{back | }', fields: const []);
    await tester.tap(find.bySemanticsLabel('Add line').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Field'));
    await tester.tap(find.text('Condition'));
    await tester.pumpAndSettle();
    expect(_reported, isNull);
    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    expect(_reported, startsWith('{front |\n  \n}'));
  });

  testWidgets('starts over from a layout it did not report', (tester) async {
    await _pump(tester, _vocabulary);
    await _pump(tester, '{front | {field Meaning}}{back | }');
    expect(find.text('Prompt'), findsNothing);
    expect(_picker('Field'), findsOneWidget);
  });
}
