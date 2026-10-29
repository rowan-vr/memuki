import '../domain/ids.dart';
import '../domain/note.dart' show Tag;
import '../domain/review.dart';
import '../scheduler/scheduler_registry.dart';
import '../scheduler/scheduling_engine.dart';
import '../storage/database.dart';
import '../storage/repositories/note_repository.dart';
import '../storage/repositories/repository_exceptions.dart';
import '../storage/repositories/review_repository.dart';
import '../storage/repositories/study_card_repository.dart';
import '../storage/repositories/tag_repository.dart';

/// The current time in UTC and the device's offset from UTC.
typedef DeviceNow = ({DateTime at, Duration utcOffset}) Function();

({DateTime at, Duration utcOffset}) _deviceNow() {
  final now = DateTime.now();
  return (at: now.toUtc(), utcOffset: now.timeZoneOffset);
}

/// Records reviews. A review appends a complete event to the card's history,
/// updates its scheduling state, and tags its note when the card becomes a
/// leech, all in one transaction.
class ReviewService {
  ReviewService({
    required this._db,
    required this._cards,
    required this._notes,
    required this._tags,
    required this._reviews,
    required this._schedulers,
    this._now = _deviceNow,
  }) : _engine = SchedulingEngine(_schedulers);

  /// The tag given to leeches, at the root of the collection's tags.
  static const leechTag = 'leech';

  final MemukiDatabase _db;
  final StudyCardRepository _cards;
  final NoteRepository _notes;
  final TagRepository _tags;
  final ReviewRepository _reviews;
  final SchedulerRegistry _schedulers;
  final SchedulingEngine _engine;
  final DeviceNow _now;

  /// Grades a card now and returns its new scheduling state.
  Future<SchedulingState> review(
    StudyCardId cardId,
    Grade grade, {
    required SchedulingSettings settings,
    Duration? responseTime,
  }) => _db.transaction(() async {
    final card = await _cards.card(cardId);
    if (card == null) {
      throw EntityNotFoundException('Card $cardId does not exist');
    }
    final before =
        await _cards.schedulingState(cardId) ?? _engine.initial(cardId);
    final scheduler = _schedulers.latest(settings.schedulerId);
    final now = _now();
    final event = ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: cardId,
      kind: ReviewEventKind.review,
      at: now.at,
      utcOffset: now.utcOffset,
      grade: grade,
      responseTime: responseTime,
      dueBefore: before.due,
      schedulerId: scheduler.id,
      schedulerVersion: scheduler.version,
      configVersion: settings.configVersion,
    );
    final after = _engine.apply(before, event, settings);
    await _reviews.append(event.copyWith(dueAfter: after.due));
    await _cards.saveSchedulingState(after);
    if (_engine.becameLeech(before, after, settings)) {
      await _tagLeech(card.noteId);
    }
    return after;
  });

  /// Adds the leech tag to the note, creating the tag if the collection
  /// has none. An existing root tag named "leech" in any case is reused.
  Future<void> _tagLeech(NoteId noteId) async {
    final note = (await _notes.note(noteId))!;
    final existing = (await _tags.tags(note.collectionId))
        .where((t) => t.parentId == null && t.name.toLowerCase() == leechTag)
        .firstOrNull;
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
}
