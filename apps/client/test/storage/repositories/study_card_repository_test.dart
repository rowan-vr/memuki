import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';
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

  test(
    'cardsWithState lists cards with their state in creation order',
    () async {
      final second = StudyCardTemplate(
        id: StudyCardTemplateId.generate(),
        name: 'Card 2',
      );
      // Listed before the first template, so position decides the order.
      await repos.noteTypes.updateNoteType(
        japanese.noteType.copyWith(
          templates: [second, ...japanese.noteType.templates],
        ),
      );
      final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
      final (older, olderCard) = await japanese.addNote('猫', deckId: child.id);
      final (_, newerCard) = await japanese.addNote('犬');
      final secondCard = StudyCard(
        noteId: older.id,
        templateId: second.id,
        deckId: japanese.deck.id,
      );
      await repos.cards.createCard(secondCard);
      final state = SchedulingState(
        studyCardId: newerCard.id,
        state: StudyCardState.review,
        due: DateTime.utc(2026, 10, 29),
        interval: const Duration(days: 3),
        ease: 2.5,
      );
      await repos.cards.saveSchedulingState(state);

      final listed = await repos.cards.cardsWithState(japanese.deck.id);
      expect(listed.map((e) => e.$1), [secondCard, olderCard, newerCard]);
      expect(listed.last.$2, state);
      expect(listed.first.$2!.state, StudyCardState.newCard);
      expect(await repos.cards.cardsWithState(child.id), hasLength(1));
    },
  );

  test('cardsWithState can list only new cards and cards due before a '
      'time', () async {
    final cutoff = DateTime.utc(2026, 10, 29, 18);
    Future<StudyCard> withState(StudyCardState state, {DateTime? due}) async {
      final (_, card) = await japanese.addNote('${state.name} $due');
      await repos.cards.saveSchedulingState(
        SchedulingState(studyCardId: card.id, state: state, due: due),
      );
      return card;
    }

    final newCard = await withState(StudyCardState.newCard);
    final dueReview = await withState(
      StudyCardState.review,
      due: cutoff.subtract(const Duration(days: 1)),
    );
    final dueLearning = await withState(
      StudyCardState.learning,
      due: cutoff.subtract(const Duration(minutes: 1)),
    );
    await withState(StudyCardState.review, due: cutoff);
    await withState(StudyCardState.burned);

    final listed = await repos.cards.cardsWithState(
      japanese.deck.id,
      dueBefore: cutoff,
    );
    expect(listed.map((e) => e.$1), [newCard, dueReview, dueLearning]);
  });

  test('watching a deck emits when a deck above it is deleted', () async {
    final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
    final (_, card) = await japanese.addNote('猫', deckId: child.id);
    final cards = repos.cards.watchCardsInDeck(child.id);
    expect(
      cards,
      emitsInOrder([
        [card],
        isEmpty,
      ]),
    );
    await pumpEventQueue();
    await repos.collections.deleteDeck(japanese.deck.id);
  });

  test('scheduling state is saved and replaced', () async {
    final (_, card) = await japanese.addNote('猫');
    final event = ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: card.id,
      kind: ReviewEventKind.review,
      at: DateTime.utc(2026, 10, 29),
      utcOffset: Duration.zero,
      stateBefore: StudyCardState.newCard,
      grade: Grade.good,
      schedulerId: 'sm2',
      schedulerVersion: 1,
      presetVersionId: japanese.preset.version.id,
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
    expect(await repos.cards.card(card.id), isNull);
  });
}
