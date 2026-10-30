import '../domain/ids.dart';
import '../domain/preset.dart';
import '../domain/review.dart';
import 'study_day.dart';
import 'unit_hash.dart';

/// A deck in a study session, with the daily limits of its preset.
final class QueueDeck {
  const QueueDeck({
    required this.id,
    this.parentId,
    required this.newCardsPerDay,
    required this.reviewsPerDay,
  });

  final DeckId id;
  final DeckId? parentId;
  final int newCardsPerDay;
  final int reviewsPerDay;
}

/// A card in a study session.
final class QueueCard {
  const QueueCard({required this.deckId, required this.state});

  final DeckId deckId;
  final SchedulingState state;

  StudyCardId get id => state.studyCardId;
}

/// What a study session shows next, and how much is left today.
///
/// Learning and relearning cards come first once due, and are never limited.
/// Due reviews and new cards follow in the order the preset sets, each
/// limited per day: every deck's limit caps the cards from that deck and the
/// decks below it, and the studied deck's limit caps the total. When nothing
/// else is left, learning cards due within [learnAhead] are shown early.
/// Burned cards are never in the queue.
final class StudyQueue {
  const StudyQueue._({
    required this.next,
    required this.newCount,
    required this.learningCount,
    required this.reviewCount,
    required this.nextDue,
  });

  /// How long before they are due learning cards are shown when nothing
  /// else is left.
  static const learnAhead = Duration(minutes: 20);

  /// Builds the queue of a deck.
  ///
  /// [decks] are the studied deck and the decks below it; their limits
  /// apply. [cards] are their
  /// cards, oldest note first and a note's cards in template order.
  /// [newDone] and [reviewsDone] count the new cards and reviews studied
  /// today, by deck of the card. [mix] and [order] come from the studied
  /// deck's preset.
  factory StudyQueue.build({
    required Map<DeckId, QueueDeck> decks,
    required List<QueueCard> cards,
    required Map<DeckId, int> newDone,
    required Map<DeckId, int> reviewsDone,
    required DateTime now,
    required StudyDay day,
    NewCardMix mix = NewCardMix.mixed,
    NewCardOrder order = NewCardOrder.created,
  }) {
    final today = day.startOf(now);
    final tomorrow = day.startAfter(now, 1);

    final learning = <QueueCard>[];
    final reviews = <QueueCard>[];
    final newCards = <QueueCard>[];
    for (final card in cards) {
      if (!decks.containsKey(card.deckId)) continue;
      final due = card.state.due;
      switch (card.state.state) {
        case StudyCardState.learning || StudyCardState.relearning
            when due != null:
          learning.add(card);
        case StudyCardState.review when due != null && due.isBefore(tomorrow):
          reviews.add(card);
        case StudyCardState.newCard:
          newCards.add(card);
        default:
          break;
      }
    }
    // Ties keep creation order, since sorting is not stable.
    final position = {for (final (i, c) in cards.indexed) c.id: i};
    int byCreation(QueueCard a, QueueCard b) =>
        position[a.id]!.compareTo(position[b.id]!);
    int byDue(QueueCard a, QueueCard b) =>
        switch (a.state.due!.compareTo(b.state.due!)) {
          0 => byCreation(a, b),
          final order => order,
        };
    learning.sort(byDue);
    reviews.sort(byDue);
    if (order == NewCardOrder.random) {
      final seed = today.millisecondsSinceEpoch;
      final keys = {for (final c in newCards) c.id: unitHash('${c.id}:$seed')};
      newCards.sort(
        (a, b) => switch (keys[a.id]!.compareTo(keys[b.id]!)) {
          0 => byCreation(a, b),
          final order => order,
        },
      );
    }

    final reviewSlots = _remaining(decks, reviewsDone, (d) => d.reviewsPerDay);
    final newSlots = _remaining(decks, newDone, (d) => d.newCardsPerDay);
    final dueReviews = _take(reviews, reviewSlots, decks);
    final dueNew = _take(newCards, newSlots, decks);

    final ahead = now.add(learnAhead);
    final learningNow = learning.where((c) => !c.state.due!.isAfter(now));
    final learningSoon = learning.where((c) => !c.state.due!.isAfter(ahead));

    QueueCard? next = learningNow.firstOrNull;
    if (next == null && (dueReviews.isNotEmpty || dueNew.isNotEmpty)) {
      final showNew = switch (mix) {
        _ when dueReviews.isEmpty => true,
        _ when dueNew.isEmpty => false,
        NewCardMix.reviewsFirst => false,
        NewCardMix.newFirst => true,
        NewCardMix.mixed => _newIsDue(
          newDone: _sum(newDone, decks),
          reviewsDone: _sum(reviewsDone, decks),
          newLeft: dueNew.length,
          reviewsLeft: dueReviews.length,
        ),
      };
      next = showNew ? dueNew.first : dueReviews.first;
    }
    next ??= learningSoon.firstOrNull;

    return StudyQueue._(
      next: next?.id,
      newCount: dueNew.length,
      learningCount: learningSoon.length,
      reviewCount: dueReviews.length,
      nextDue: next != null
          ? null
          : learning
                .map((c) => c.state.due!)
                .where((due) => due.isBefore(tomorrow))
                .firstOrNull,
    );
  }

  /// The card to show next, or null if nothing is left for now.
  final StudyCardId? next;

  /// New cards left today.
  final int newCount;

  /// Learning and relearning cards due now or within [learnAhead].
  final int learningCount;

  /// Due reviews left today.
  final int reviewCount;

  /// When nothing is left for now: when the next learning card falls due
  /// today, or null if none does.
  final DateTime? nextDue;
}

/// The decks whose limits apply to a card in [deckId]: its deck and the
/// decks above it, up to the studied deck.
List<DeckId> _chain(DeckId deckId, Map<DeckId, QueueDeck> decks) => [
  for (
    DeckId? id = deckId;
    id != null && decks.containsKey(id);
    id = decks[id]!.parentId
  )
    id,
];

/// The cards each deck can still take today: its limit, less what was done
/// today in it and the decks below it.
Map<DeckId, int> _remaining(
  Map<DeckId, QueueDeck> decks,
  Map<DeckId, int> done,
  int Function(QueueDeck deck) limit,
) {
  final remaining = {for (final deck in decks.values) deck.id: limit(deck)};
  for (final MapEntry(key: deckId, value: count) in done.entries) {
    for (final id in _chain(deckId, decks)) {
      remaining[id] = remaining[id]! - count;
    }
  }
  return remaining;
}

/// The cards of [candidates] that fit within [slots], in order. Each card
/// takes a slot of its deck and of every deck above it.
List<QueueCard> _take(
  List<QueueCard> candidates,
  Map<DeckId, int> slots,
  Map<DeckId, QueueDeck> decks,
) {
  final taken = <QueueCard>[];
  for (final card in candidates) {
    final chain = _chain(card.deckId, decks);
    if (!chain.every((id) => slots[id]! > 0)) continue;
    for (final id in chain) {
      slots[id] = slots[id]! - 1;
    }
    taken.add(card);
  }
  return taken;
}

int _sum(Map<DeckId, int> done, Map<DeckId, QueueDeck> decks) => done.entries
    .where((e) => decks.containsKey(e.key))
    .fold(0, (sum, e) => sum + e.value);

/// Whether the next card of a mixed queue is new, spreading the day's new
/// cards evenly among its reviews: new cards are shown when fewer than
/// their share of the cards studied so far, plus half a card, were new.
bool _newIsDue({
  required int newDone,
  required int reviewsDone,
  required int newLeft,
  required int reviewsLeft,
}) {
  final newTotal = newDone + newLeft;
  final total = newTotal + reviewsDone + reviewsLeft;
  return (2 * newDone + 1) * total < 2 * newTotal * (newDone + reviewsDone + 1);
}
