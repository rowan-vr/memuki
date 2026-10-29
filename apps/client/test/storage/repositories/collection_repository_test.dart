import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/converters.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';
import 'package:memuki/storage/repositories/tree_queries.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  group('collections', () {
    test('are created, renamed, and listed by name', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      await repos.collections.updateCollection(
        korean.collection.copyWith(name: 'Chinese'),
      );
      expect(
        [for (final c in await repos.collections.collections()) c.name],
        ['Chinese', 'Japanese'],
      );
    });

    test('updating a missing collection fails', () async {
      await expectLater(
        repos.collections.updateCollection(
          Collection(id: CollectionId.generate(), name: 'Gone'),
        ),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('deleting one removes everything in it and nothing else', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      await japanese.addNote('猫');
      await japanese.addTag('animals');
      await korean.addNote('고양이');

      await repos.collections.deleteCollection(japanese.id);

      expect(await repos.collections.collection(japanese.id), isNull);
      expect(await repos.notes.notes(japanese.id), isEmpty);
      expect(await repos.noteTypes.noteTypes(japanese.id), isEmpty);
      expect(await repos.tags.tags(japanese.id), isEmpty);
      expect(await repos.collections.decks(japanese.id), isEmpty);
      expect(await repos.notes.notes(korean.id), hasLength(1));
    });

    test('watching emits on changes', () async {
      final names = repos.collections.watchCollections().map(
        (cs) => [for (final c in cs) c.name],
      );
      expect(
        names,
        emitsInOrder([
          ['Japanese'],
          ['Japanese', 'Korean'],
        ]),
      );
      await repos.seedCollection(name: 'Korean');
    });
  });

  group('decks', () {
    test('cannot have a parent in another collection', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      await expectLater(
        japanese.addDeck('Child', parentId: korean.deck.id),
        throwsA(isA<CrossCollectionException>()),
      );
    });

    test('cannot have a missing parent', () async {
      await expectLater(
        japanese.addDeck('Child', parentId: DeckId.generate()),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('cannot move to another collection', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      await expectLater(
        repos.collections.updateDeck(
          japanese.deck.copyWith(collectionId: korean.id),
        ),
        throwsA(isA<CrossCollectionException>()),
      );
    });

    test('can be renamed and moved', () async {
      final grammar = await japanese.addDeck('Grammar');
      await repos.collections.updateDeck(
        grammar.copyWith(name: 'N5 grammar', parentId: japanese.deck.id),
      );
      final moved = await repos.collections.deck(grammar.id);
      expect(moved!.name, 'N5 grammar');
      expect(moved.parentId, japanese.deck.id);
    });

    test('cannot move below themselves', () async {
      final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
      final grandchild = await japanese.addDeck(
        'Grandchild',
        parentId: child.id,
      );

      await expectLater(
        repos.collections.updateDeck(
          japanese.deck.copyWith(parentId: grandchild.id),
        ),
        throwsA(isA<ParentCycleException>()),
      );
      expect(
        (await repos.collections.deck(japanese.deck.id))!.parentId,
        isNull,
      );
    });

    test(
      'deleting one removes its subdecks, their cards, and orphaned notes',
      () async {
        final child = await japanese.addDeck(
          'Child',
          parentId: japanese.deck.id,
        );
        final other = await japanese.addDeck('Other');
        final (inChild, _) = await japanese.addNote(
          'in child',
          deckId: child.id,
        );
        final (elsewhere, _) = await japanese.addNote(
          'elsewhere',
          deckId: other.id,
        );
        // A note with cards in both a deleted deck and a kept deck survives.
        final (split, _) = await japanese.addNote('split');
        final secondTemplate = StudyCardTemplate(
          id: StudyCardTemplateId.generate(),
          name: 'Card 2',
        );
        await repos.noteTypes.updateNoteType(
          japanese.noteType.copyWith(
            templates: [...japanese.noteType.templates, secondTemplate],
          ),
        );
        await repos.cards.createCard(
          StudyCard(
            noteId: split.id,
            templateId: secondTemplate.id,
            deckId: other.id,
          ),
        );

        await repos.collections.deleteDeck(japanese.deck.id);

        expect(
          [for (final d in await repos.collections.decks(japanese.id)) d.name],
          ['Other'],
        );
        expect(await repos.notes.note(inChild.id), isNull);
        expect(await repos.notes.note(elsewhere.id), isNotNull);
        expect(await repos.cards.cardsOfNote(split.id), hasLength(1));
      },
    );

    test('subtree walks stop at the depth limit on a cycle', () async {
      final a = await japanese.addDeck('A');
      final b = await japanese.addDeck('B', parentId: a.id);
      // Corrupt data: make A a child of B, bypassing the repository.
      await repos.db.customStatement(
        'UPDATE decks SET parent_id = ? WHERE id = ?',
        [deckIdConverter.toSql(b.id), deckIdConverter.toSql(a.id)],
      );

      final logs = <LogRecord>[];
      final sub = Logger('memuki.storage').onRecord.listen(logs.add);
      addTearDown(sub.cancel);

      expect(await repos.collections.deckSubtree(a.id), {a.id, b.id});
      expect(logs.single.message, contains('reached depth $maxTreeDepth'));
    });
  });

  test('a failed transaction across repositories leaves nothing', () async {
    final note = Note(
      id: NoteId.generate(),
      collectionId: japanese.id,
      noteTypeId: japanese.noteType.id,
      fields: {japanese.noteType.fields.first.id: '犬'},
    );
    await expectLater(
      repos.db.transaction(() async {
        await repos.notes.createNote(note);
        await repos.cards.createCard(
          StudyCard(
            noteId: note.id,
            templateId: japanese.noteType.templates.single.id,
            deckId: DeckId.generate(),
          ),
        );
      }),
      throwsA(isA<EntityNotFoundException>()),
    );
    expect(await repos.notes.note(note.id), isNull);
  });
}
