import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/scheduler/study_day.dart';
import 'package:memuki/scheduler/study_queue.dart';

void main() {
  // 21:00 on 29 October in UTC+9; the study day started at 03:00.
  final now = DateTime.utc(2026, 10, 29, 12);
  final today = DateTime.utc(2026, 10, 28, 18);
  final tomorrow = DateTime.utc(2026, 10, 29, 18);
  final day = StudyDay(utcOffset: const Duration(hours: 9));
  final root = DeckId.generate();

  QueueDeck deck(
    DeckId id, {
    DeckId? parent,
    int newCards = 50,
    int reviews = 500,
  }) => QueueDeck(
    id: id,
    parentId: parent,
    newCardsPerDay: newCards,
    reviewsPerDay: reviews,
  );

  QueueCard card(StudyCardState state, {DateTime? due, DeckId? deckId}) =>
      QueueCard(
        deckId: deckId ?? root,
        state: SchedulingState(
          studyCardId: StudyCardId.derive(
            NoteId.generate(),
            StudyCardTemplateId.generate(),
          ),
          state: state,
          due: due,
        ),
      );

  QueueCard newCard({DeckId? deckId}) =>
      card(StudyCardState.newCard, deckId: deckId);
  QueueCard reviewCard({DateTime? due, DeckId? deckId}) =>
      card(StudyCardState.review, due: due ?? today, deckId: deckId);
  QueueCard learningCard(DateTime due) =>
      card(StudyCardState.learning, due: due);

  StudyQueue build(
    List<QueueCard> cards, {
    Map<DeckId, QueueDeck>? decks,
    Map<DeckId, int> newDone = const {},
    Map<DeckId, int> reviewsDone = const {},
    NewCardMix mix = NewCardMix.mixed,
    NewCardOrder order = NewCardOrder.created,
    DateTime? at,
  }) => StudyQueue.build(
    decks: decks ?? {root: deck(root)},
    cards: cards,
    newDone: newDone,
    reviewsDone: reviewsDone,
    now: at ?? now,
    day: day,
    mix: mix,
    order: order,
  );

  /// The order in which the cards would be shown, studying each in turn.
  List<QueueCard> session(
    List<QueueCard> cards, {
    NewCardMix mix = NewCardMix.mixed,
    NewCardOrder order = NewCardOrder.created,
  }) {
    final left = [...cards];
    final shown = <QueueCard>[];
    var newDone = 0;
    var reviewsDone = 0;
    while (true) {
      final next = build(
        left,
        newDone: {root: newDone},
        reviewsDone: {root: reviewsDone},
        mix: mix,
        order: order,
      ).next;
      if (next == null) return shown;
      final card = left.singleWhere((c) => c.id == next);
      left.remove(card);
      shown.add(card);
      if (card.state.state == StudyCardState.newCard) {
        newDone++;
      } else {
        reviewsDone++;
      }
    }
  }

  test('an empty deck has nothing to show', () {
    final queue = build([]);
    expect(queue.next, isNull);
    expect(queue.newCount, 0);
    expect(queue.learningCount, 0);
    expect(queue.reviewCount, 0);
    expect(queue.nextDue, isNull);
  });

  test('due learning cards come first, earliest first', () {
    final review = reviewCard();
    final later = learningCard(now.subtract(const Duration(minutes: 1)));
    final earlier = learningCard(now.subtract(const Duration(hours: 1)));
    final queue = build([newCard(), review, later, earlier]);
    expect(queue.next, earlier.id);
    expect(queue.learningCount, 2);
    expect(queue.reviewCount, 1);
    expect(queue.newCount, 1);
  });

  test('relearning cards count as learning', () {
    final relearning = card(StudyCardState.relearning, due: now);
    final queue = build([reviewCard(), relearning]);
    expect(queue.next, relearning.id);
    expect(queue.learningCount, 1);
  });

  test('reviews due today are shown, most overdue first; later ones are '
      'not', () {
    final overdue = reviewCard(due: today.subtract(const Duration(days: 3)));
    final due = reviewCard(due: today);
    final dueLaterToday = reviewCard(due: now.add(const Duration(hours: 1)));
    final dueTomorrow = reviewCard(due: tomorrow);
    final queue = build([due, dueTomorrow, overdue, dueLaterToday]);
    expect(queue.next, overdue.id);
    expect(queue.reviewCount, 3);
  });

  test('burned cards are never shown', () {
    final queue = build([card(StudyCardState.burned)]);
    expect(queue.next, isNull);
    expect(queue.reviewCount, 0);
  });

  group('learning ahead', () {
    test('learning cards due within 20 minutes are shown when nothing else '
        'is left', () {
      final soon = learningCard(now.add(const Duration(minutes: 20)));
      final queue = build([soon]);
      expect(queue.next, soon.id);
      expect(queue.learningCount, 1);
    });

    test('other cards come before learning ahead', () {
      final soon = learningCard(now.add(const Duration(minutes: 5)));
      final review = reviewCard();
      expect(build([soon, review]).next, review.id);
    });

    test('reports when the next learning card falls due today', () {
      final later = now.add(const Duration(hours: 2));
      final queue = build([
        learningCard(later),
        learningCard(tomorrow.add(const Duration(hours: 1))),
      ]);
      expect(queue.next, isNull);
      expect(queue.learningCount, 0);
      expect(queue.nextDue, later);
    });

    test('learning cards due tomorrow are not reported', () {
      expect(build([learningCard(tomorrow)]).nextDue, isNull);
    });
  });

  group('new cards', () {
    test('are introduced in creation order', () {
      final cards = [for (var i = 0; i < 5; i++) newCard()];
      expect(session(cards), cards);
    });

    test('in random order are shuffled the same way all day', () {
      final cards = [for (var i = 0; i < 20; i++) newCard()];
      final shuffled = session(cards, order: NewCardOrder.random);
      expect(shuffled, unorderedEquals(cards));
      expect(shuffled, isNot(cards));
      expect(
        session(cards.reversed.toList(), order: NewCardOrder.random),
        shuffled,
      );
    });
  });

  group('mixing', () {
    final reviews = [for (var i = 0; i < 10; i++) reviewCard()];
    final newCards = [newCard(), newCard()];

    String pattern(NewCardMix mix) => session(
      [...reviews, ...newCards],
      mix: mix,
    ).map((c) => c.state.state == StudyCardState.newCard ? 'N' : 'r').join();

    test('spreads new cards evenly among reviews', () {
      expect(pattern(NewCardMix.mixed), 'rrrNrrrrrNrr');
    });

    test('can show reviews or new cards first', () {
      expect(pattern(NewCardMix.reviewsFirst), 'rrrrrrrrrrNN');
      expect(pattern(NewCardMix.newFirst), 'NNrrrrrrrrrr');
    });

    test('shows new cards when no reviews are due', () {
      expect(session(newCards), newCards);
    });
  });

  group('limits', () {
    test('cap new cards and reviews, less what was done today', () {
      final queue = build(
        [
          for (var i = 0; i < 5; i++) ...[newCard(), reviewCard()],
        ],
        decks: {root: deck(root, newCards: 3, reviews: 4)},
        newDone: {root: 1},
        reviewsDone: {root: 1},
      );
      expect(queue.newCount, 2);
      expect(queue.reviewCount, 3);
    });

    test('do not apply to learning cards', () {
      final queue = build(
        [for (var i = 0; i < 3; i++) learningCard(now)],
        decks: {root: deck(root, newCards: 0, reviews: 0)},
      );
      expect(queue.learningCount, 3);
      expect(queue.next, isNotNull);
    });

    test('used up limits leave nothing to show', () {
      final queue = build(
        [newCard(), reviewCard()],
        decks: {root: deck(root, newCards: 2, reviews: 1)},
        newDone: {root: 2},
        reviewsDone: {root: 3},
      );
      expect(queue.next, isNull);
      expect(queue.newCount, 0);
      expect(queue.reviewCount, 0);
    });

    test('each subdeck\'s limit applies, and the studied deck caps the '
        'total', () {
      final n5 = DeckId.generate();
      final n4 = DeckId.generate();
      final verbs = DeckId.generate();
      final decks = {
        root: deck(root, newCards: 6),
        n5: deck(n5, parent: root, newCards: 2),
        n4: deck(n4, parent: root, newCards: 10),
        verbs: deck(verbs, parent: n4, newCards: 3),
      };
      List<QueueCard> cards(DeckId deckId) => [
        for (var i = 0; i < 5; i++) newCard(deckId: deckId),
      ];
      final n5Cards = cards(n5);
      final verbCards = cards(verbs);
      final n4Cards = cards(n4);
      final queue = build([...n5Cards, ...verbCards, ...n4Cards], decks: decks);
      // N5 takes its 2, verbs its 3, and N4 the last 1 the root allows.
      expect(queue.newCount, 6);
      expect(queue.next, n5Cards.first.id);
    });

    test('cards done today in a subdeck count against the decks above '
        'it', () {
      final n5 = DeckId.generate();
      final queue = build(
        [newCard(), newCard(deckId: n5)],
        decks: {
          root: deck(root, newCards: 3),
          n5: deck(n5, parent: root, newCards: 3),
        },
        newDone: {n5: 2},
      );
      expect(queue.newCount, 1);
    });
  });
}
