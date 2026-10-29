import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/repositories/collection_repository.dart';
import 'package:memuki/storage/repositories/note_repository.dart';
import 'package:memuki/storage/repositories/note_type_repository.dart';
import 'package:memuki/storage/repositories/review_repository.dart';
import 'package:memuki/storage/repositories/study_card_repository.dart';
import 'package:memuki/storage/repositories/tag_repository.dart';

/// An in-memory database, closed after the test.
MemukiDatabase openTestDatabase() {
  // Tests open several databases, each on its own connection.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = MemukiDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

/// All repositories over one database.
class Repositories {
  Repositories(this.db)
    : collections = CollectionRepository(db),
      tags = TagRepository(db),
      noteTypes = NoteTypeRepository(db),
      notes = NoteRepository(db),
      cards = StudyCardRepository(db),
      reviews = ReviewRepository(db);

  final MemukiDatabase db;
  final CollectionRepository collections;
  final TagRepository tags;
  final NoteTypeRepository noteTypes;
  final NoteRepository notes;
  final StudyCardRepository cards;
  final ReviewRepository reviews;

  /// Creates a collection with a "Basic" note type (fields Front and Back,
  /// one template) and a root deck.
  Future<SeededCollection> seedCollection({String name = 'Japanese'}) async {
    final collection = Collection(id: CollectionId.generate(), name: name);
    final noteType = NoteType(
      id: NoteTypeId.generate(),
      collectionId: collection.id,
      name: 'Basic',
      fields: [
        FieldDefinition(id: FieldDefinitionId.generate(), name: 'Front'),
        FieldDefinition(id: FieldDefinitionId.generate(), name: 'Back'),
      ],
      templates: [
        StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'Card 1'),
      ],
    );
    final deck = Deck(
      id: DeckId.generate(),
      collectionId: collection.id,
      name: 'Vocab',
    );
    await collections.createCollection(collection);
    await noteTypes.createNoteType(noteType);
    await collections.createDeck(deck);
    return SeededCollection(this, collection, noteType, deck);
  }
}

class SeededCollection {
  SeededCollection(this._repos, this.collection, this.noteType, this.deck);

  final Repositories _repos;
  final Collection collection;
  final NoteType noteType;
  final Deck deck;

  CollectionId get id => collection.id;

  /// Creates a deck in this collection.
  Future<Deck> addDeck(String name, {DeckId? parentId}) async {
    final deck = Deck(
      id: DeckId.generate(),
      collectionId: id,
      parentId: parentId,
      name: name,
    );
    await _repos.collections.createDeck(deck);
    return deck;
  }

  /// Creates a tag in this collection.
  Future<Tag> addTag(String name, {TagId? parentId}) async {
    final tag = Tag(
      id: TagId.generate(),
      collectionId: id,
      parentId: parentId,
      name: name,
    );
    await _repos.tags.createTag(tag);
    return tag;
  }

  /// Creates a note with [front] and its card in [deckId] (default: the
  /// seeded deck).
  Future<(Note, StudyCard)> addNote(String front, {DeckId? deckId}) async {
    final note = Note(
      id: NoteId.generate(),
      collectionId: id,
      noteTypeId: noteType.id,
      fields: {noteType.fields.first.id: front},
    );
    final card = StudyCard(
      noteId: note.id,
      templateId: noteType.templates.single.id,
      deckId: deckId ?? deck.id,
    );
    await _repos.notes.createNote(note);
    await _repos.cards.createCard(card);
    return (note, card);
  }
}
