import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/review.dart';
import '../../domain/study_card.dart';
import '../converters.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import 'cascades.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';

/// Cards and their scheduling state.
class StudyCardRepository {
  StudyCardRepository(this._db)
    : _changes = ChangeRecorder(_db),
      _deckTree = TreeQueries(_db, _db.decks, deckIdConverter);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;
  final TreeQueries<DeckId> _deckTree;

  Future<StudyCard?> card(StudyCardId id) async {
    final row = await _cardRow(id);
    return row == null ? null : _card(row);
  }

  Future<List<StudyCard>> cardsOfNote(NoteId noteId) =>
      (_db.select(_db.studyCards)..where(
            (c) => c.noteId.equalsValue(noteId) & c.deleted.equals(false),
          ))
          .map(_card)
          .get();

  /// Cards in [deckId], and in the decks below it if [includeSubdecks].
  Future<List<StudyCard>> cardsInDeck(
    DeckId deckId, {
    bool includeSubdecks = false,
  }) async =>
      (await _cardsInDeckQuery(deckId, includeSubdecks)).map(_card).get();

  Stream<List<StudyCard>> watchCardsInDeck(
    DeckId deckId, {
    bool includeSubdecks = false,
  }) async* {
    yield* (await _cardsInDeckQuery(
      deckId,
      includeSubdecks,
    )).map(_card).watch();
  }

  /// Creates a card in a deck of its note's collection, with a new-card
  /// scheduling state. The template must belong to the note's note type.
  ///
  /// A card's ID is derived from its note and template, so creating a card
  /// that was deleted before revives it, keeping its review history and
  /// scheduling state.
  Future<void> createCard(StudyCard card) => _changes.write((hlc) async {
    final note =
        await (_db.select(_db.notes)..where(
              (n) => n.id.equalsValue(card.noteId) & n.deleted.equals(false),
            ))
            .getSingleOrNull();
    if (note == null) {
      throw EntityNotFoundException('Note ${card.noteId} does not exist');
    }
    final template =
        await (_db.select(_db.studyCardTemplates)..where(
              (t) =>
                  t.id.equalsValue(card.templateId) & t.deleted.equals(false),
            ))
            .getSingleOrNull();
    if (template == null) {
      throw EntityNotFoundException(
        'Card template ${card.templateId} does not exist',
      );
    }
    if (template.noteTypeId != note.noteTypeId) {
      throw NoteTypeMismatchException(
        'Card template ${card.templateId} is not a template of note '
        '${card.noteId}\'s note type',
      );
    }
    await _requireDeck(card.deckId, note.collectionId);
    if (await _cardRow(card.id) != null) {
      throw DuplicateEntityException('Card ${card.id} already exists');
    }
    await _db
        .into(_db.studyCards)
        .insertOnConflictUpdate(
          StudyCardsCompanion.insert(
            id: card.id,
            collectionId: note.collectionId,
            noteId: card.noteId,
            templateId: card.templateId,
            deckId: card.deckId,
            hlc: hlc,
            deleted: const Value(false),
          ),
        );
    await _db
        .into(_db.schedulingStates)
        .insert(
          _stateCompanion(
            SchedulingState(
              studyCardId: card.id,
              state: StudyCardState.newCard,
            ),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  });

  /// Moves a card to another deck of the same collection.
  Future<void> moveCard(StudyCardId id, DeckId deckId) =>
      _changes.write((hlc) async {
        final card = await _cardRow(id);
        if (card == null) throw _notFound(id);
        await _requireDeck(deckId, card.collectionId);
        await (_db.update(_db.studyCards)..where((c) => c.id.equalsValue(id)))
            .write(StudyCardsCompanion(deckId: Value(deckId), hlc: Value(hlc)));
      });

  /// Deletes a card. Its review history is kept.
  Future<void> deleteCard(StudyCardId id) => _changes.write((hlc) async {
    if (await _cardRow(id) == null) throw _notFound(id);
    await tombstoneCardsWhere(_db, hlc, (c) => c.id.equalsValue(id));
  });

  // Scheduling state

  Future<SchedulingState?> schedulingState(StudyCardId id) async {
    final row = await (_db.select(
      _db.schedulingStates,
    )..where((s) => s.studyCardId.equalsValue(id))).getSingleOrNull();
    return row == null ? null : _state(row);
  }

  /// Replaces a card's scheduling state. The state is a local cache of the
  /// review history and is not synced.
  Future<void> saveSchedulingState(SchedulingState state) =>
      _db.transaction(() async {
        if (await _cardRow(state.studyCardId) == null) {
          throw _notFound(state.studyCardId);
        }
        await _db
            .into(_db.schedulingStates)
            .insertOnConflictUpdate(_stateCompanion(state));
      });

  Future<StudyCardRow?> _cardRow(StudyCardId id) =>
      (_db.select(_db.studyCards)
            ..where((c) => c.id.equalsValue(id) & c.deleted.equals(false)))
          .getSingleOrNull();

  Future<SimpleSelectStatement<$StudyCardsTable, StudyCardRow>>
  _cardsInDeckQuery(DeckId deckId, bool includeSubdecks) async {
    final deckIds = includeSubdecks
        ? (await _deckTree.subtree(deckId)).toList()
        : [deckId];
    return _db.select(_db.studyCards)
      ..where((c) => c.deckId.isInValues(deckIds) & c.deleted.equals(false))
      ..orderBy([(c) => OrderingTerm(expression: c.noteId)]);
  }

  Future<void> _requireDeck(DeckId deckId, CollectionId collectionId) async {
    final deck =
        await (_db.select(
              _db.decks,
            )..where((d) => d.id.equalsValue(deckId) & d.deleted.equals(false)))
            .getSingleOrNull();
    if (deck == null) {
      throw EntityNotFoundException('Deck $deckId does not exist');
    }
    if (deck.collectionId != collectionId) {
      throw CrossCollectionException('Deck $deckId is in another collection');
    }
  }
}

StudyCard _card(StudyCardRow row) => StudyCard(
  noteId: row.noteId,
  templateId: row.templateId,
  deckId: row.deckId,
);

SchedulingState _state(SchedulingStateRow row) => SchedulingState(
  studyCardId: row.studyCardId,
  state: row.state,
  due: row.due,
  interval: row.interval,
  ease: row.ease,
  step: row.step,
  lapses: row.lapses,
  reviewCount: row.reviewCount,
  lastEventId: row.lastEventId,
);

SchedulingStatesCompanion _stateCompanion(SchedulingState state) =>
    SchedulingStatesCompanion.insert(
      studyCardId: state.studyCardId,
      state: state.state,
      due: Value(state.due),
      interval: state.interval,
      ease: Value(state.ease),
      step: state.step,
      lapses: state.lapses,
      reviewCount: state.reviewCount,
      lastEventId: Value(state.lastEventId),
    );

EntityNotFoundException _notFound(StudyCardId id) =>
    EntityNotFoundException('Card $id does not exist');
