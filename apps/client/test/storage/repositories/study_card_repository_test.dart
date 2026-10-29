import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  test('new cards start in the new state', () async {
    final (_, card) = await japanese.addNote('猫');
    expect(await repos.cards.card(card.id), card);
    final state = await repos.cards.schedulingState(card.id);
    expect(state!.state, StudyCardState.newCard);
  });

  test('rejects a template of another note type', () async {
    final korean = await repos.seedCollection(name: 'Korean');
    final (note, _) = await japanese.addNote('猫');
    await expectLater(
      repos.cards.createCard(
        StudyCard(
          noteId: note.id,
          templateId: korean.noteType.templates.single.id,
          deckId: japanese.deck.id,
        ),
      ),
      throwsA(isA<NoteTypeMismatchException>()),
    );
  });

  test('cannot move to a deck of another collection', () async {
    final korean = await repos.seedCollection(name: 'Korean');
    final (_, card) = await japanese.addNote('猫');
    await expectLater(
      repos.cards.moveCard(card.id, korean.deck.id),
      throwsA(isA<CrossCollectionException>()),
    );
  });

  test('cardsInDeck can include subdecks', () async {
    final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
    final (_, top) = await japanese.addNote('top');
    final (_, nested) = await japanese.addNote('nested', deckId: child.id);

    expect(await repos.cards.cardsInDeck(japanese.deck.id), [top]);
    expect(
      await repos.cards.cardsInDeck(japanese.deck.id, includeSubdecks: true),
      unorderedEquals([top, nested]),
    );
  });

  test('scheduling state is saved and replaced', () async {
    final (_, card) = await japanese.addNote('猫');
    final event = ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: card.id,
      kind: ReviewEventKind.review,
      at: DateTime.utc(2026, 10, 29),
      grade: Grade.good,
      schedulerId: 'sm2',
      schedulerVersion: 1,
      configVersion: 1,
    );
    await repos.reviews.append(event);
    final state = SchedulingState(
      studyCardId: card.id,
      state: StudyCardState.learning,
      due: DateTime.utc(2026, 10, 29, 0, 10),
      interval: const Duration(minutes: 10),
      step: 1,
      reviewCount: 1,
      lastEventId: event.id,
    );
    await repos.cards.saveSchedulingState(state);
    expect(await repos.cards.schedulingState(card.id), state);

    await repos.cards.deleteCard(card.id);
    expect(await repos.cards.schedulingState(card.id), isNull);
  });
}
