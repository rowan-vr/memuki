import '../domain/ids.dart';
import '../domain/review.dart';
import '../domain/study_card.dart';
import '../scheduler/scheduler_registry.dart';
import '../scheduler/scheduling_engine.dart';
import '../scheduler/study_day.dart';
import '../scheduler/study_queue.dart';
import '../storage/database.dart';
import '../storage/repositories/collection_repository.dart';
import '../storage/repositories/preset_repository.dart';
import '../storage/repositories/repository_exceptions.dart';
import '../storage/repositories/review_repository.dart';
import '../storage/repositories/study_card_repository.dart';
import 'rebuild_service.dart';
import 'review_service.dart' show DeviceNow, deviceNow;

/// Builds the study queue of a deck: what to show next and how much is left
/// today (see [StudyQueue]).
///
/// What was already studied today comes from the review history in effect
/// in the current study day, in the device's UTC offset, so an undo gives a
/// card's slot back. A review counts as a new card if the card was new
/// before it, and against the review limit if the card was in review.
class StudyQueueService {
  StudyQueueService({
    required this._db,
    required this._collections,
    required this._presets,
    required this._cards,
    required this._reviews,
    required SchedulerRegistry schedulers,
    this._now = deviceNow,
  }) : _rebuild = RebuildService(
         db: _db,
         collections: _collections,
         presets: _presets,
         cards: _cards,
         reviews: _reviews,
         schedulers: schedulers,
       ),
       _engine = SchedulingEngine(schedulers);

  final MemukiDatabase _db;
  final CollectionRepository _collections;
  final PresetRepository _presets;
  final StudyCardRepository _cards;
  final ReviewRepository _reviews;
  final RebuildService _rebuild;
  final SchedulingEngine _engine;
  final DeviceNow _now;

  /// The queue of [deckId] and the decks below it, now.
  Future<StudyQueue> queue(DeckId deckId) => _db.transaction(() async {
    final studied = await _collections.deck(deckId);
    if (studied == null) {
      throw EntityNotFoundException('Deck $deckId does not exist');
    }
    final collection = (await _collections.collection(studied.collectionId))!;
    final now = _now();
    final day = StudyDay(utcOffset: now.utcOffset, start: collection.dayStart);

    final allDecks = await _collections.decks(collection.id);
    final children = <DeckId, List<DeckId>>{};
    for (final deck in allDecks) {
      if (deck.parentId case final parent?) {
        (children[parent] ??= []).add(deck.id);
      }
    }
    final parents = {for (final deck in allDecks) deck.id: deck.parentId};
    final decks = <DeckId, QueueDeck>{};
    final pending = [deckId];
    while (pending.isNotEmpty) {
      final id = pending.removeLast();
      final limits = (await _presets.effectivePreset(id)).version;
      decks[id] = QueueDeck(
        id: id,
        parentId: id == deckId ? null : parents[id],
        newCardsPerDay: limits.newCardsPerDay,
        reviewsPerDay: limits.reviewsPerDay,
      );
      pending.addAll(children[id] ?? const []);
    }

    // Learning cards due within the learn-ahead window can be shown even
    // when it reaches into tomorrow.
    final ahead = now.at.add(StudyQueue.learnAhead);
    final tomorrow = day.startAfter(now.at, 1);
    final cards = await _cards.cardsWithState(
      deckId,
      dueBefore: ahead.isAfter(tomorrow) ? ahead : tomorrow,
    );
    final (:newDone, :reviewsDone) = await _studiedToday(
      decks.keys.toSet(),
      collection.id,
      since: day.startOf(now.at),
      dayStart: collection.dayStart,
    );
    final preset = (await _presets.effectivePreset(deckId)).version;
    return StudyQueue.build(
      decks: decks,
      cards: [
        for (final (card, state) in cards)
          QueueCard(
            deckId: card.deckId,
            state: state ?? _engine.initial(card.id),
          ),
      ],
      newDone: newDone,
      reviewsDone: reviewsDone,
      now: now.at,
      day: day,
      mix: preset.newCardMix,
      order: preset.newCardOrder,
    );
  });

  /// The new cards and reviews studied since [since] in [deckIds], by deck
  /// of the card.
  Future<({Map<DeckId, int> newDone, Map<DeckId, int> reviewsDone})>
  _studiedToday(
    Set<DeckId> deckIds,
    CollectionId collectionId, {
    required DateTime since,
    required Duration dayStart,
  }) async {
    final histories = <StudyCard, List<ReviewEvent>>{};
    for (final MapEntry(key: id, value: history)
        in (await _reviews.historiesSince(collectionId, since)).entries) {
      final card = await _cards.card(id);
      if (card != null && deckIds.contains(card.deckId)) {
        histories[card] = history;
      }
    }
    final steps = await _rebuild.replaySteps(histories, dayStart: dayStart);
    final decks = {for (final card in histories.keys) card.id: card.deckId};
    final newDone = <DeckId, int>{};
    final reviewsDone = <DeckId, int>{};
    for (final MapEntry(key: cardId, value: cardSteps) in steps.entries) {
      final deckId = decks[cardId]!;
      for (final (event, before) in cardSteps) {
        if (event.kind != ReviewEventKind.review || event.at.isBefore(since)) {
          continue;
        }
        switch (before.state) {
          case StudyCardState.newCard:
            newDone[deckId] = (newDone[deckId] ?? 0) + 1;
          case StudyCardState.review:
            reviewsDone[deckId] = (reviewsDone[deckId] ?? 0) + 1;
          default:
            break;
        }
      }
    }
    return (newDone: newDone, reviewsDone: reviewsDone);
  }
}
