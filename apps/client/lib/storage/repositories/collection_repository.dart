import 'package:drift/drift.dart';

import '../../domain/collection.dart';
import '../../domain/ids.dart';
import '../converters.dart';
import '../database.dart';
import 'cascades.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';

/// Collections and their decks.
class CollectionRepository {
  CollectionRepository(this._db)
    : _deckTree = TreeQueries(_db, _db.decks, deckIdConverter);

  final MemukiDatabase _db;
  final TreeQueries<DeckId> _deckTree;

  // Collections

  Future<Collection?> collection(CollectionId id) async {
    final row = await (_db.select(
      _db.collections,
    )..where((c) => c.id.equalsValue(id))).getSingleOrNull();
    return row == null ? null : _collection(row);
  }

  Future<List<Collection>> collections() =>
      _collectionsQuery().map(_collection).get();

  Stream<List<Collection>> watchCollections() =>
      _collectionsQuery().map(_collection).watch();

  Future<void> createCollection(Collection collection) => _db
      .into(_db.collections)
      .insert(
        CollectionsCompanion.insert(id: collection.id, name: collection.name),
      );

  Future<void> updateCollection(Collection collection) =>
      _db.transaction(() async {
        final updated =
            await (_db.update(_db.collections)
                  ..where((c) => c.id.equalsValue(collection.id)))
                .write(CollectionsCompanion(name: Value(collection.name)));
        if (updated == 0) throw _collectionNotFound(collection.id);
      });

  /// Deletes the collection and everything in it.
  Future<void> deleteCollection(CollectionId id) => _db.transaction(() async {
    await deleteCardsWhere(_db, (c) => c.collectionId.equalsValue(id));
    await (_db.delete(
      _db.notes,
    )..where((n) => n.collectionId.equalsValue(id))).go();
    await (_db.delete(
      _db.noteTypes,
    )..where((t) => t.collectionId.equalsValue(id))).go();
    await (_db.delete(
      _db.tags,
    )..where((t) => t.collectionId.equalsValue(id))).go();
    await (_db.delete(
      _db.decks,
    )..where((d) => d.collectionId.equalsValue(id))).go();
    await (_db.delete(
      _db.mediaAssets,
    )..where((m) => m.collectionId.equalsValue(id))).go();
    final deleted = await (_db.delete(
      _db.collections,
    )..where((c) => c.id.equalsValue(id))).go();
    if (deleted == 0) throw _collectionNotFound(id);
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

  Future<void> createDeck(Deck deck) => _db.transaction(() async {
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
          ),
        );
  });

  /// Renames or moves a deck. Moving a deck below itself or one of its
  /// descendants is rejected.
  Future<void> updateDeck(Deck deck) => _db.transaction(() async {
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
      DecksCompanion(parentId: Value(parentId), name: Value(deck.name)),
    );
  });

  /// Deletes a deck with its subdecks and their cards. Notes left without
  /// cards are deleted too.
  Future<void> deleteDeck(DeckId id) => _db.transaction(() async {
    if (await _deckRow(id) == null) throw _deckNotFound(id);
    final deckIds = (await _deckTree.subtree(id)).toList();
    final noteIds = await notesOfCardsWhere(
      _db,
      (c) => c.deckId.isInValues(deckIds),
    );
    await deleteCardsWhere(_db, (c) => c.deckId.isInValues(deckIds));
    await deleteNotesWithoutCards(_db, noteIds);
    await (_db.delete(_db.decks)..where((d) => d.id.isInValues(deckIds))).go();
  });

  Future<DeckRow?> _deckRow(DeckId id) => (_db.select(
    _db.decks,
  )..where((d) => d.id.equalsValue(id))).getSingleOrNull();

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
        ..orderBy([(c) => OrderingTerm(expression: c.name)]);

  SimpleSelectStatement<$DecksTable, DeckRow> _decksQuery(
    CollectionId collectionId,
  ) => _db.select(_db.decks)
    ..where((d) => d.collectionId.equalsValue(collectionId))
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
