import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/card.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/media_asset.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';

void main() {
  final collectionId = CollectionId.generate();

  group('names', () {
    test('must not be blank', () {
      expect(
        () => Collection(id: collectionId, name: ' '),
        throwsArgumentError,
      );
      expect(
        () => Deck(id: DeckId.generate(), collectionId: collectionId, name: ''),
        throwsArgumentError,
      );
    });

    test('are also checked by copyWith', () {
      final collection = Collection(id: collectionId, name: 'Japanese');
      expect(() => collection.copyWith(name: ''), throwsArgumentError);
    });
  });

  group('Deck and Tag', () {
    test('cannot be their own parent', () {
      final deckId = DeckId.generate();
      expect(
        () => Deck(
          id: deckId,
          collectionId: collectionId,
          parentId: deckId,
          name: 'Vocab',
        ),
        throwsArgumentError,
      );
      final tagId = TagId.generate();
      expect(
        () => Tag(
          id: tagId,
          collectionId: collectionId,
          parentId: tagId,
          name: 'grammar',
        ),
        throwsArgumentError,
      );
    });

    test('tag names may contain spaces', () {
      final tag = Tag(
        id: TagId.generate(),
        collectionId: collectionId,
        name: 'JLPT N3',
      );
      expect(tag.name, 'JLPT N3');
    });
  });

  group('NoteType', () {
    FieldDefinition field(String name) =>
        FieldDefinition(id: FieldDefinitionId.generate(), name: name);
    CardTemplate template(String name) =>
        CardTemplate(id: CardTemplateId.generate(), name: name);

    NoteType noteType({
      List<FieldDefinition>? fields,
      List<CardTemplate>? templates,
    }) => NoteType(
      id: NoteTypeId.generate(),
      collectionId: collectionId,
      name: 'Vocab',
      fields: fields ?? [field('Expression'), field('Meaning')],
      templates: templates ?? [template('Recognition')],
    );

    test('needs at least one field and one template', () {
      expect(() => noteType(fields: []), throwsArgumentError);
      expect(() => noteType(templates: []), throwsArgumentError);
    });

    test('rejects duplicate field names and IDs', () {
      expect(
        () => noteType(fields: [field('Expression'), field('Expression')]),
        throwsArgumentError,
      );
      final duplicate = field('Expression');
      expect(
        () => noteType(
          fields: [
            duplicate,
            duplicate.copyWith(name: 'Other'),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('looks up fields by ID', () {
      final meaning = field('Meaning');
      final type = noteType(fields: [field('Expression'), meaning]);
      expect(type.field(meaning.id), meaning);
      expect(type.field(FieldDefinitionId.generate()), isNull);
    });

    test('fields default to text', () {
      expect(field('Expression').type, FieldType.text);
    });
  });

  group('Note', () {
    test('compares field values by content', () {
      final fieldId = FieldDefinitionId.generate();
      Note note() => Note(
        id: NoteId.parse('018f4a2b-1c3d-7e4f-8a5b-6c7d8e9f0a1b'),
        collectionId: collectionId,
        noteTypeId: NoteTypeId.parse('018f4a2b-1c3d-7e4f-8a5b-6c7d8e9f0a1c'),
        fields: {fieldId: '猫'},
      );
      expect(note(), note());
    });

    test('field values cannot be modified in place', () {
      final note = Note(
        id: NoteId.generate(),
        collectionId: collectionId,
        noteTypeId: NoteTypeId.generate(),
        fields: {},
      );
      expect(
        () => note.fields[FieldDefinitionId.generate()] = 'x',
        throwsUnsupportedError,
      );
    });
  });

  group('Card', () {
    test('ID is derived from note and template', () {
      final card = Card(
        noteId: NoteId.generate(),
        templateId: CardTemplateId.generate(),
        deckId: DeckId.generate(),
      );
      expect(card.id, CardId.derive(card.noteId, card.templateId));
      expect(card.copyWith(deckId: DeckId.generate()).id, card.id);
    });
  });

  group('MediaAsset', () {
    test('rejects negative sizes', () {
      expect(
        () => MediaAsset(
          collectionId: collectionId,
          hash: ContentHash.of([1, 2, 3]),
          mimeType: 'audio/mpeg',
          sizeBytes: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ReviewEvent', () {
    final cardId = CardId.derive(NoteId.generate(), CardTemplateId.generate());
    final at = DateTime.utc(2026, 10, 29, 9);

    ReviewEvent event({
      ReviewEventKind kind = ReviewEventKind.review,
      Grade? grade = Grade.good,
      DateTime? time,
      ReviewEventId? undoneEventId,
      Duration? responseTime,
    }) => ReviewEvent(
      id: ReviewEventId.generate(),
      cardId: cardId,
      kind: kind,
      at: time ?? at,
      grade: grade,
      responseTime: responseTime,
      undoneEventId: undoneEventId,
      schedulerId: 'memuki.default',
      schedulerVersion: 1,
      configVersion: 1,
    );

    test('accepts a graded review', () {
      expect(event().grade, Grade.good);
    });

    test('requires a grade for reviews only', () {
      expect(() => event(grade: null), throwsArgumentError);
      expect(() => event(kind: ReviewEventKind.burn), throwsArgumentError);
      expect(event(kind: ReviewEventKind.burn, grade: null).grade, isNull);
    });

    test('undo events reference the undone event', () {
      expect(
        () => event(kind: ReviewEventKind.undo, grade: null),
        throwsArgumentError,
      );
      final undo = event(
        kind: ReviewEventKind.undo,
        grade: null,
        undoneEventId: ReviewEventId.generate(),
      );
      expect(undo.undoneEventId, isNotNull);
    });

    test('times must be UTC', () {
      expect(() => event(time: DateTime(2026, 10, 29)), throwsArgumentError);
    });

    test('response time must not be negative', () {
      expect(
        () => event(responseTime: const Duration(seconds: -1)),
        throwsArgumentError,
      );
    });
  });

  group('SchedulingState', () {
    final cardId = CardId.derive(NoteId.generate(), CardTemplateId.generate());

    test('defaults describe a new card', () {
      final state = SchedulingState(cardId: cardId, state: CardState.newCard);
      expect(state.due, isNull);
      expect(state.interval, Duration.zero);
      expect(state.reviewCount, 0);
    });

    test('rejects negative counters and local due times', () {
      expect(
        () => SchedulingState(
          cardId: cardId,
          state: CardState.review,
          lapses: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => SchedulingState(
          cardId: cardId,
          state: CardState.review,
          due: DateTime(2026, 11),
        ),
        throwsArgumentError,
      );
    });
  });
}
