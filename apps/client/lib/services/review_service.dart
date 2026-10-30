import '../domain/ids.dart';
import '../domain/note.dart' show Tag;
import '../domain/review.dart';
import '../domain/review_history.dart';
import '../domain/study_card.dart';
import '../scheduler/scheduler_registry.dart';
import '../scheduler/scheduling_engine.dart';
import '../storage/database.dart';
import '../storage/repositories/collection_repository.dart';
import '../storage/repositories/note_repository.dart';
import '../storage/repositories/preset_repository.dart';
import '../storage/repositories/repository_exceptions.dart';
import '../storage/repositories/review_repository.dart';
import '../storage/repositories/study_card_repository.dart';
import '../storage/repositories/tag_repository.dart';
import 'rebuild_service.dart';

/// The current time in UTC and the device's offset from UTC.
typedef DeviceNow = ({DateTime at, Duration utcOffset}) Function();

({DateTime at, Duration utcOffset}) _deviceNow() {
  final now = DateTime.now();
  return (at: now.toUtc(), utcOffset: now.timeZoneOffset);
}

/// Records reviews, manual burns and unburns, and undos. Each appends a
/// complete event to the card's history, updates its scheduling state, and
/// tags or untags its note as a leech, all in one transaction.
class ReviewService {
  ReviewService({
    required this._db,
    required this._collections,
    required this._presets,
    required this._cards,
    required this._notes,
    required this._tags,
    required this._reviews,
    required this._schedulers,
    this._now = _deviceNow,
  }) : _engine = SchedulingEngine(_schedulers),
       _rebuild = RebuildService(
         db: _db,
         collections: _collections,
         presets: _presets,
         cards: _cards,
         reviews: _reviews,
         schedulers: _schedulers,
       );

  /// The tag given to leeches, at the root of the collection's tags.
  static const leechTag = 'leech';

  final MemukiDatabase _db;
  final CollectionRepository _collections;
  final PresetRepository _presets;
  final StudyCardRepository _cards;
  final NoteRepository _notes;
  final TagRepository _tags;
  final ReviewRepository _reviews;
  final SchedulerRegistry _schedulers;
  final SchedulingEngine _engine;
  final RebuildService _rebuild;
  final DeviceNow _now;

  /// Grades a card now with the settings of its deck's preset and returns
  /// its new scheduling state.
  Future<SchedulingState> review(
    StudyCardId cardId,
    Grade grade, {
    Duration? responseTime,
  }) => _db.transaction(() async {
    final target = await _target(cardId);
    final event = _event(
      target,
      ReviewEventKind.review,
      grade: grade,
      responseTime: responseTime,
    );
    return _record(
      target,
      event,
      _engine.apply(target.before, event, target.settings),
    );
  });

  /// Burns a card manually. Throws [InvalidReviewEventException] if it is
  /// burned already.
  Future<SchedulingState> burn(StudyCardId cardId) => _db.transaction(() async {
    final target = await _target(cardId);
    if (target.before.state == StudyCardState.burned) {
      throw InvalidReviewEventException('Card $cardId is burned already');
    }
    final event = _event(target, ReviewEventKind.burn);
    return _record(
      target,
      event,
      _engine.apply(target.before, event, target.settings),
    );
  });

  /// Returns a burned card to reviews, due today. Throws
  /// [InvalidReviewEventException] if it is not burned.
  Future<SchedulingState> unburn(StudyCardId cardId) =>
      _db.transaction(() async {
        final target = await _target(cardId);
        if (target.before.state != StudyCardState.burned) {
          throw InvalidReviewEventException('Card $cardId is not burned');
        }
        final event = _event(target, ReviewEventKind.unburn);
        return _record(
          target,
          event,
          _engine.apply(target.before, event, target.settings),
        );
      });

  /// Undoes the card's latest review, burn, or unburn that is in effect.
  /// Throws [InvalidReviewEventException] if there is none.
  Future<SchedulingState> undo(StudyCardId cardId) =>
      _undo(cardId, redo: false);

  /// Redoes the card's latest undo, if nothing but undos and redos was
  /// recorded since. Throws [InvalidReviewEventException] otherwise.
  Future<SchedulingState> redo(StudyCardId cardId) => _undo(cardId, redo: true);

  Future<SchedulingState> _undo(StudyCardId cardId, {required bool redo}) =>
      _db.transaction(() async {
        final target = await _target(cardId);
        final history = await _reviews.history(cardId);
        final resolved = ReviewHistory(history);
        final undone = redo ? resolved.redoable : resolved.undoable;
        if (undone == null) {
          throw InvalidReviewEventException(
            'Card $cardId has nothing to ${redo ? 'redo' : 'undo'}',
          );
        }
        final event = _event(
          target,
          ReviewEventKind.undo,
          undoneEventId: undone.id,
        );
        final after = await _rebuild.replay(target.card, [...history, event]);
        return _record(target, event, after);
      });

  /// Loads what recording an event for the card needs.
  Future<_Target> _target(StudyCardId cardId) async {
    final card = await _cards.card(cardId);
    if (card == null) {
      throw EntityNotFoundException('Card $cardId does not exist');
    }
    final preset = await _presets.effectivePreset(card.deckId);
    final collection = (await _collections.collection(preset.collectionId))!;
    return _Target(
      card: card,
      presetVersionId: preset.version.id,
      settings: SchedulingSettings.fromPreset(
        preset.version,
        dayStart: collection.dayStart,
      ),
      before: await _cards.schedulingState(cardId) ?? _engine.initial(cardId),
    );
  }

  /// An event for the card now, with the scheduler its preset uses.
  ReviewEvent _event(
    _Target target,
    ReviewEventKind kind, {
    Grade? grade,
    Duration? responseTime,
    ReviewEventId? undoneEventId,
  }) {
    final scheduler = _schedulers.latest(target.settings.schedulerId);
    final now = _now();
    return ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: target.card.id,
      kind: kind,
      at: now.at,
      utcOffset: now.utcOffset,
      grade: grade,
      responseTime: responseTime,
      dueBefore: target.before.due,
      undoneEventId: undoneEventId,
      schedulerId: scheduler.id,
      schedulerVersion: scheduler.version,
      presetVersionId: target.presetVersionId,
    );
  }

  /// Appends [event], saves the card's new state [after], and updates the
  /// note's leech tag.
  Future<SchedulingState> _record(
    _Target target,
    ReviewEvent event,
    SchedulingState after,
  ) async {
    await _reviews.append(event.copyWith(dueAfter: after.due));
    await _cards.saveSchedulingState(after);
    if (_engine.becameLeech(target.before, after, target.settings)) {
      await _tagLeech(target.card.noteId);
    } else if (_stoppedBeingLeech(target.before, after, target.settings)) {
      await _untagLeech(target.card);
    }
    return after;
  }

  /// Whether an undo took the card from at least its leech threshold to
  /// below it.
  bool _stoppedBeingLeech(
    SchedulingState before,
    SchedulingState after,
    SchedulingSettings settings,
  ) {
    final threshold = settings.leechThreshold;
    return threshold != null &&
        before.lapses >= threshold &&
        after.lapses < threshold;
  }

  /// Adds the leech tag to the note, creating the tag if the collection
  /// has none. An existing root tag named "leech" in any case is reused.
  Future<void> _tagLeech(NoteId noteId) async {
    final note = (await _notes.note(noteId))!;
    final existing = await _leechTag(note.collectionId);
    final tag =
        existing ??
        Tag(
          id: TagId.generate(),
          collectionId: note.collectionId,
          name: leechTag,
        );
    if (existing == null) await _tags.createTag(tag);
    await _notes.addTag(noteId, tag.id);
  }

  /// Removes the leech tag from the note of [card], unless another card of
  /// the note is still at or above its own leech threshold. The tag itself is
  /// kept.
  Future<void> _untagLeech(StudyCard card) async {
    for (final sibling in await _cards.cardsOfNote(card.noteId)) {
      if (sibling.id == card.id) continue;
      final threshold = (await _presets.effectivePreset(sibling.deckId))
          .version
          .leechThreshold;
      final state = await _cards.schedulingState(sibling.id);
      if (threshold != null && state != null && state.lapses >= threshold) {
        return;
      }
    }
    final note = (await _notes.note(card.noteId))!;
    final tag = await _leechTag(note.collectionId);
    if (tag != null) await _notes.removeTag(note.id, tag.id);
  }

  /// The collection's root tag named "leech" in any case, if it has one.
  Future<Tag?> _leechTag(CollectionId collectionId) async =>
      (await _tags.tags(collectionId))
          .where((t) => t.parentId == null && t.name.toLowerCase() == leechTag)
          .firstOrNull;
}

/// A card about to receive an event, with the settings that apply to it.
final class _Target {
  const _Target({
    required this.card,
    required this.presetVersionId,
    required this.settings,
    required this.before,
  });

  final StudyCard card;
  final PresetVersionId presetVersionId;
  final SchedulingSettings settings;
  final SchedulingState before;
}
