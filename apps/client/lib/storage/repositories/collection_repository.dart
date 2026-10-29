import 'package:drift/drift.dart';

import '../../domain/collection.dart';
import '../../domain/ids.dart';
import '../converters.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';
import 'visibility.dart';

/// Collections and their decks.
class CollectionRepository {
  CollectionRepository(this._db)
    : _changes = ChangeRecorder(_db),
      _deckTree = TreeQueries(_db, _db.decks, deckIdConverter);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;
  final TreeQueries<DeckId> _deckTree;

  // Collections

  Future<Collection?> collection(CollectionId id) async {
    final row =
        await (_db.select(_db.collections)..where(
              (c) => c.id.equalsValue(id) & _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
    return row == null ? null : _collection(row);
  }

  Future<List<Collection>> collections() =>
      _collectionsQuery().map(_collection).get();

  Stream<List<Collection>> watchCollections() =>
      _collectionsQuery().map(_collection).watch();

  Future<void> createCollection(Collection collection) => _changes.write(
    (hlc) => _db
        .into(_db.collections)
        .insert(
          CollectionsCompanion.insert(
            id: collection.id,
            name: collection.name,
            hlc: hlc,
          ),
        ),
  );

  Future<void> updateCollection(Collection collection) =>
      _changes.write((hlc) async {
        final updated =
            await (_db.update(_db.collections)..where(
                  (c) =>
                      c.id.equalsValue(collection.id) &
                      _db.isVisibleCollection(c.id),
                ))
                .write(
                  CollectionsCompanion(
                    name: Value(collection.name),
                    hlc: Value(hlc),
                  ),
                );
        if (updated == 0) throw _collectionNotFound(collection.id);
      });

  /// Deletes the collection. Everything in it is hidden with it.
  Future<void> deleteCollection(CollectionId id) => _changes.write((hlc) async {
    final updated =
        await (_db.update(_db.collections)..where(
              (c) => c.id.equalsValue(id) & _db.isVisibleCollection(c.id),
            ))
            .write(
              CollectionsCompanion(deleted: const Value(true), hlc: Value(hlc)),
            );
    if (updated == 0) throw _collectionNotFound(id);
  });

  // Decks

  Future<Deck?> deck(DeckId id) async {
    final row = await _deckRow(id);
    return row == null ? null : _deck(row);
  }

  /// All decks of a collection, by name. Callers build the tree from
  /// [Deck.parentId].
  Future<List<Deck>> decks(CollectionId collectionId) =>
      _decksQuery(collectionId).map(_deck).get();

  Stream<List<Deck>> watchDecks(CollectionId collectionId) =>
      _decksQuery(collectionId).map(_deck).watch();

  /// The IDs of [id] and all decks below it.
  Future<Set<DeckId>> deckSubtree(DeckId id) => _deckTree.subtree(id);

  Future<void> createDeck(Deck deck) => _changes.write((hlc) async {
    if (await collection(deck.collectionId) == null) {
      throw _collectionNotFound(deck.collectionId);
    }
    if (deck.parentId case final parentId?) {
      await _requireParent(deck.collectionId, parentId);
    }
    await _db
        .into(_db.decks)
        .insert(
          DecksCompanion.insert(
            id: deck.id,
            collectionId: deck.collectionId,
            parentId: Value(deck.parentId),
            name: deck.name,
            hlc: hlc,
          ),
        );
  });

  /// Renames or moves a deck. Moving a deck below itself or one of its
  /// descendants is rejected.
  Future<void> updateDeck(Deck deck) => _changes.write((hlc) async {
    final current = await _deckRow(deck.id);
    if (current == null) throw _deckNotFound(deck.id);
    if (current.collectionId != deck.collectionId) {
      throw CrossCollectionException(
        'Deck ${deck.id} cannot move to another collection',
      );
    }
    final parentId = deck.parentId;
    if (parentId != null && parentId != current.parentId) {
      await _requireParent(deck.collectionId, parentId);
      if ((await _deckTree.ancestors(parentId)).contains(deck.id)) {
        throw ParentCycleException('Deck $parentId is below deck ${deck.id}');
      }
    }
    await (_db.update(
      _db.decks,
    )..where((d) => d.id.equalsValue(deck.id))).write(
      DecksCompanion(
        parentId: Value(parentId),
        name: Value(deck.name),
        hlc: Value(hlc),
      ),
    );
  });

  /// Deletes a deck. Its subdecks and their cards are hidden with it, and
  /// so are notes left without visible cards.
  Future<void> deleteDeck(DeckId id) => _changes.write((hlc) async {
    if (await _deckRow(id) == null) throw _deckNotFound(id);
    await (_db.update(_db.decks)..where((d) => d.id.equalsValue(id))).write(
      DecksCompanion(deleted: const Value(true), hlc: Value(hlc)),
    );
  });

  Future<DeckRow?> _deckRow(DeckId id) =>
      (_db.select(_db.decks)
            ..where((d) => d.id.equalsValue(id) & _db.isVisibleDeck(d.id)))
          .getSingleOrNull();

  Future<void> _requireParent(
    CollectionId collectionId,
    DeckId parentId,
  ) async {
    final parent = await _deckRow(parentId);
    if (parent == null) throw _deckNotFound(parentId);
    if (parent.collectionId != collectionId) {
      throw CrossCollectionException(
        'Parent deck $parentId is in another collection',
      );
    }
  }

  SimpleSelectStatement<$CollectionsTable, CollectionRow> _collectionsQuery() =>
      _db.select(_db.collections)
        ..where((c) => _db.isVisibleCollection(c.id))
        ..orderBy([(c) => OrderingTerm(expression: c.name)]);

  SimpleSelectStatement<$DecksTable, DeckRow> _decksQuery(
    CollectionId collectionId,
  ) => _db.select(_db.decks)
    ..where(
      (d) => d.collectionId.equalsValue(collectionId) & _db.isVisibleDeck(d.id),
    )
    ..orderBy([(d) => OrderingTerm(expression: d.name)]);
}

Collection _collection(CollectionRow row) =>
    Collection(id: row.id, name: row.name);

Deck _deck(DeckRow row) => Deck(
  id: row.id,
  collectionId: row.collectionId,
  parentId: row.parentId,
  name: row.name,
);

EntityNotFoundException _collectionNotFound(CollectionId id) =>
    EntityNotFoundException('Collection $id does not exist');

EntityNotFoundException _deckNotFound(DeckId id) =>
    EntityNotFoundException('Deck $id does not exist');
