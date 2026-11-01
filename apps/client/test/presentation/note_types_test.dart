import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/presentation/components/check_chip.dart';
import 'package:memuki/presentation/components/icons.dart';
import 'package:memuki/presentation/components/screen.dart';
import 'package:memuki/presentation/content/template_editor.dart';
import 'package:memuki/presentation/note_types/note_type_editor_screen.dart';
import 'package:memuki/presentation/note_types/note_types_screen.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/providers.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

void main() {
  late MemukiDatabase db;
  late Repositories repos;

  setUp(() {
    db = openTestDatabase();
    repos = Repositories(db);
  });

  Future<void> pump(WidgetTester tester, {String? at}) async {
    await tester.pumpApp(
      size: const Size(1280, 2400),
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    if (at != null) {
      GoRouter.of(tester.element(find.byType(Screen).first)).go(at);
      await tester.pumpAndSettle();
    }
  }

  /// A note type in [collection] whose card shows both its fields, opened in
  /// the editor.
  Future<NoteType> open(WidgetTester tester) async {
    final collection = Collection(
      id: CollectionId.generate(),
      name: 'My collection',
    );
    final front = FieldDefinition(id: FieldDefinitionId.generate(), name: 'A');
    final back = FieldDefinition(id: FieldDefinitionId.generate(), name: 'B');
    final noteType = NoteType(
      id: NoteTypeId.generate(),
      collectionId: collection.id,
      name: 'Words',
      fields: [front, back],
      templates: [
        StudyCardTemplate(
          id: StudyCardTemplateId.generate(),
          name: 'Card 1',
          source: '{front | {field A}}\n{back | {field B}}',
        ),
      ],
    );
    await tester.runAsync(() async {
      await repos.collections.createCollection(collection);
      await repos.noteTypes.createNoteType(noteType);
    });
    await pump(tester, at: '/settings/note-types/${noteType.id.value}');
    expect(find.byType(NoteTypeEditorScreen), findsOneWidget);
    return noteType;
  }

  Future<NoteType> stored(WidgetTester tester, NoteTypeId id) async =>
      (await tester.runAsync(() => repos.noteTypes.noteType(id)))!;

  Finder field(String text) => find.widgetWithText(TextField, text);

  /// Types [text] into [finder] once it is scrolled into view.
  Future<void> enter(WidgetTester tester, Finder finder, String text) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
  }

  /// Taps [finder] once it is scrolled into view.
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  Future<void> save(WidgetTester tester) async {
    await tap(tester, find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('settings lead to the note types, where one is made', (
    tester,
  ) async {
    await pump(tester, at: '/settings');
    await tap(tester, find.text('Note types'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteTypesScreen), findsOneWidget);
    expect(find.text('No note types yet.'), findsOneWidget);

    await tap(tester, find.text('New note type'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteTypeEditorScreen), findsOneWidget);
    expect(field('Front'), findsOneWidget);
    expect(field('Back'), findsOneWidget);
    final collections = await tester.runAsync(repos.collections.collections);
    expect(collections!.single.name, 'My collection');
    final types = await tester.runAsync(
      () => repos.noteTypes.noteTypes(collections.single.id),
    );
    final made = types!.single;
    expect(made.duplicateCheck, made.fields.first.id);
    expect(made.templates.single.fieldNames, {'Front', 'Back'});
  });

  testWidgets('renaming a field rewrites the cards that show it', (
    tester,
  ) async {
    final noteType = await open(tester);
    await enter(tester, field('A'), 'Word');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await save(tester);

    final saved = await stored(tester, noteType.id);
    expect(saved.fields.first.name, 'Word');
    expect(saved.templates.single.fieldNames, {'Word', 'B'});
  });

  testWidgets('a taken or empty field name is refused and reverts', (
    tester,
  ) async {
    await open(tester);
    await enter(tester, field('A'), 'B');
    await tester.pump();
    expect(find.text('Another one has this name.'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(field('A'), findsOneWidget);

    await enter(tester, field('A'), ' ');
    await tester.pump();
    expect(find.text('A name is needed.'), findsOneWidget);
  });

  testWidgets('removing a field names the cards it is taken out of', (
    tester,
  ) async {
    final noteType = await open(tester);
    await tap(tester, find.bySemanticsLabel('Remove field').first);
    await tester.pumpAndSettle();
    expect(find.text('Remove A?'), findsOneWidget);
    expect(find.textContaining('Card 1'), findsWidgets);
    await tap(tester, find.text('Remove'));
    await tester.pumpAndSettle();
    expect(field('A'), findsNothing);
    await save(tester);

    final saved = await stored(tester, noteType.id);
    expect(saved.fields.map((f) => f.name), ['B']);
    expect(saved.templates.single.fieldNames, {'B'});
  });

  testWidgets('a field is set up from its settings', (tester) async {
    final noteType = await open(tester);
    await tap(
      tester,
      find
          .descendant(
            of: find.byType(NoteTypeEditorScreen),
            matching: find.bySemanticsLabel('Settings'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await enter(tester, find.widgetWithText(TextField, 'Language'), 'ja');
    await tap(tester, find.widgetWithText(CheckChip, 'Required'));
    await tap(tester, find.widgetWithText(CheckChip, 'Check for duplicates'));
    await tap(tester, find.widgetWithText(CheckChip, 'Emphasis'));
    await tester.pumpAndSettle();
    await save(tester);

    var saved = await stored(tester, noteType.id);
    final a = saved.fields.first;
    expect(a.language, 'ja');
    expect(a.isRequired, isTrue);
    expect(saved.duplicateCheck, a.id);
    expect(a.allows('em'), isFalse);
    expect(a.allows('sub'), isTrue);

    await tap(tester, find.widgetWithText(CheckChip, 'Emphasis'));
    await tap(tester, find.widgetWithText(CheckChip, 'Check for duplicates'));
    await enter(tester, find.widgetWithText(TextField, 'Language'), '');
    await tester.pumpAndSettle();
    await save(tester);
    saved = await stored(tester, noteType.id);
    expect(saved.fields.first.allowedMarks, isNull);
    expect(saved.fields.first.language, isNull);
    expect(saved.duplicateCheck, isNull);

    await tap(tester, find.widgetWithText(CheckChip, 'All'));
    await tester.pumpAndSettle();
    await save(tester);
    saved = await stored(tester, noteType.id);
    expect(saved.fields.first.allowedMarks, isEmpty);
  });

  testWidgets('fields and cards are added, and a card is edited as source', (
    tester,
  ) async {
    final noteType = await open(tester);
    expect(find.byType(TemplateEditor), findsOneWidget);
    await tap(tester, find.text('Add field'));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Add card'));
    await tester.pumpAndSettle();
    expect(field('Field 3'), findsOneWidget);
    expect(field('Card 2'), findsOneWidget, reason: 'a new card is opened');
    expect(field('Card 1'), findsNothing);

    await tap(tester, find.text('Card 1'));
    await tester.pumpAndSettle();
    expect(field('Card 1'), findsOneWidget);

    await tap(tester, find.text('Source').first);
    await tester.pumpAndSettle();
    await enter(
      tester,
      find.widgetWithText(TextField, '{front | {field A}}\n{back | {field B}}'),
      'stray {front |}',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Card 1 needs a front and a back, with nothing outside them.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Visual').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('can only be arranged visually'), findsOne);
    await tap(tester, find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      (await stored(tester, noteType.id)).templates,
      hasLength(1),
      reason: 'saving waits until every card is sound',
    );

    await tap(tester, find.text('Source').first);
    await tester.pumpAndSettle();
    await enter(
      tester,
      find.widgetWithText(TextField, 'stray {front |}'),
      '{front | {field Nope}}\n{back |}',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Card 1 shows fields this note type does not have: Nope'),
      findsOneWidget,
    );

    await tap(tester, find.bySemanticsLabel('Remove card').first);
    await tester.pumpAndSettle();
    await save(tester);
    final saved = await stored(tester, noteType.id);
    expect(saved.fields.map((f) => f.name), ['A', 'B', 'Field 3']);
    expect(saved.templates.single.name, 'Card 2');
  });

  testWidgets('the preview shows a side at a time, by field name', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('A'), findsWidgets);
    await tap(tester, find.text('Back').last);
    await tester.pumpAndSettle();
    expect(find.text('B'), findsWidgets);
  });

  testWidgets('a note type is deleted, back to the list', (tester) async {
    final noteType = await open(tester);
    await tap(tester, find.bySemanticsLabel('Delete note type'));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NoteTypesScreen), findsOneWidget);
    expect(find.text('No note types yet.'), findsOneWidget);
    expect(
      await tester.runAsync(() => repos.noteTypes.noteType(noteType.id)),
      isNull,
    );
  });

  testWidgets('leaving with changes asks to discard them', (tester) async {
    final noteType = await open(tester);
    await enter(tester, field('Words'), 'Phrases');
    await tester.pump();
    await tap(tester, find.byIcon(MemukiIcons.back));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tap(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteTypeEditorScreen), findsOneWidget);

    await tap(tester, find.byIcon(MemukiIcons.back));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteTypesScreen), findsOneWidget);
    expect(find.text('Words'), findsOneWidget);
    expect((await stored(tester, noteType.id)).name, 'Words');

    await tap(tester, find.text('Words'));
    await tester.pumpAndSettle();
    expect(find.byType(NoteTypeEditorScreen), findsOneWidget);
  });

  testWidgets('a note type name must be given and not taken', (tester) async {
    final noteType = await open(tester);
    await tester.runAsync(
      () => repos.noteTypes.createNoteType(
        noteType.copyWith(
          id: NoteTypeId.generate(),
          name: 'Other',
          fields: [
            FieldDefinition(id: FieldDefinitionId.generate(), name: 'X'),
          ],
          templates: [
            StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'C'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await enter(tester, field('Words'), 'Other');
    await tester.pumpAndSettle();
    expect(find.text('Another one has this name.'), findsOneWidget);
    await enter(tester, field('Other'), '');
    await tester.pumpAndSettle();
    expect(find.text('A name is needed.'), findsOneWidget);
  });
}
