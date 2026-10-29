import 'package:drift/drift.dart';

import '../converters.dart';

@DataClassName('CollectionRow')
class Collections extends Table {
  BlobColumn get id => blob().map(collectionIdConverter)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'decks_parent', columns: {#collectionId, #parentId})
@DataClassName('DeckRow')
class Decks extends Table {
  BlobColumn get id => blob().map(deckIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get parentId => blob().map(deckIdConverter).nullable()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, parent_id) '
        'REFERENCES decks (collection_id, id) DEFERRABLE INITIALLY DEFERRED',
  ];
}
