import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/note.dart';
import '../converters.dart';
import '../database.dart';
import 'cascades.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';
import 'watch_tables.dart';

/// Notes with their field values, and the tags attached to them.
class NoteRepository {
  NoteRepository(this._db)
    : _tagTree = TreeQueries(_db, _db.tags, tagIdConverter);

  final MemukiDatabase _db;
  final TreeQueries<TagId> _tagTree;

  Future<Note?> note(NoteId id) async =>
      (await _query((n) => n.id.equalsValue(id))).singleOrNull;

  /// All notes of a collection, oldest first.
  Future<List<Note>> notes(CollectionId collectionId) =>
      _query((n) => n.collectionId.equalsValue(collectionId));

  Stream<List<Note>> watchNotes(CollectionId collectionId) =>
      watchTables(_db, [_db.notes, _db.noteFields], () => notes(collectionId));

  /// Notes tagged with [tagId] or a tag below it, oldest first.
  Future<List<Note>> notesWithTag(TagId tagId) async {
    final tagIds = (await _tagTree.subtree(tagId)).toList();
    final tagged = _db.selectOnly(_db.noteTags)
      ..addColumns([_db.noteTags.noteId])
      ..where(_db.noteTags.tagId.isInValues(tagIds));
    return _query((n) => n.id.isInQuery(tagged));
  }

  /// Creates a note. Its fields must belong to its note type, which must be
  /// in the same collection.
  Future<void> createNote(Note note) => _db.transaction(() async {
    await _requireNoteType(note);
    await _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            id: note.id,
            collectionId: note.collectionId,
            noteTypeId: note.noteTypeId,
            sourceKind: Value(note.source?.kind),
            sourceReference: Value(note.source?.reference),
          ),
        );
    await _writeFields(note);
  });

  /// Saves a note's field values and source. Fields missing from
  /// [Note.fields] lose their value. The note type cannot change.
  Future<void> updateNote(Note note) => _db.transaction(() async {
    final current = await _noteRow(note.id);
    if (current == null) throw _notFound(note.id);
    if (current.collectionId != note.collectionId) {
      throw CrossCollectionException(
        'Note ${note.id} cannot move to another collection',
      );
    }
    if (current.noteTypeId != note.noteTypeId) {
      throw NoteTypeMismatchException(
        'Note ${note.id} cannot change its note type',
      );
    }
    await _requireNoteType(note);
    await (_db.update(
      _db.notes,
    )..where((n) => n.id.equalsValue(note.id))).write(
      NotesCompanion(
        sourceKind: Value(note.source?.kind),
        sourceReference: Value(note.source?.reference),
      ),
    );
    await (_db.delete(_db.noteFields)..where(
          (f) =>
              f.noteId.equalsValue(note.id) &
              f.fieldId.isInValues(note.fields.keys).not(),
        ))
        .go();
    await _writeFields(note);
  });

  /// Deletes a note with its cards, their review history, and its tags.
  Future<void> deleteNote(NoteId id) => _db.transaction(() async {
    if (await _noteRow(id) == null) throw _notFound(id);
    await deleteCardsWhere(_db, (c) => c.noteId.equalsValue(id));
    await (_db.delete(_db.notes)..where((n) => n.id.equalsValue(id))).go();
  });

  // Tags

  Future<Set<TagId>> tagIds(NoteId noteId) async {
    final rows = await (_db.select(
      _db.noteTags,
    )..where((t) => t.noteId.equalsValue(noteId))).get();
    return {for (final r in rows) r.tagId};
  }

  /// Attaches a tag of the note's collection. Does nothing if it is
  /// attached already.
  Future<void> addTag(NoteId noteId, TagId tagId) => _db.transaction(() async {
    final note = await _noteRow(noteId);
    if (note == null) throw _notFound(noteId);
    final tag = await (_db.select(
      _db.tags,
    )..where((t) => t.id.equalsValue(tagId))).getSingleOrNull();
    if (tag == null) throw EntityNotFoundException('Tag $tagId does not exist');
    if (tag.collectionId != note.collectionId) {
      throw CrossCollectionException(
        'Tag $tagId is in another collection than note $noteId',
      );
    }
    await _db
        .into(_db.noteTags)
        .insert(
          NoteTagsCompanion.insert(
            collectionId: note.collectionId,
            noteId: noteId,
            tagId: tagId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  });

  Future<void> removeTag(NoteId noteId, TagId tagId) =>
      (_db.delete(_db.noteTags)..where(
            (t) => t.noteId.equalsValue(noteId) & t.tagId.equalsValue(tagId),
          ))
          .go();

  Future<NoteRow?> _noteRow(NoteId id) => (_db.select(
    _db.notes,
  )..where((n) => n.id.equalsValue(id))).getSingleOrNull();

  Future<void> _requireNoteType(Note note) async {
    final noteType = await (_db.select(
      _db.noteTypes,
    )..where((t) => t.id.equalsValue(note.noteTypeId))).getSingleOrNull();
    if (noteType == null) {
      throw EntityNotFoundException(
        'Note type ${note.noteTypeId} does not exist',
      );
    }
    if (noteType.collectionId != note.collectionId) {
      throw CrossCollectionException(
        'Note type ${note.noteTypeId} is in another collection',
      );
    }
    final fields = await (_db.select(
      _db.fieldDefinitions,
    )..where((f) => f.noteTypeId.equalsValue(note.noteTypeId))).get();
    final known = {for (final f in fields) f.id};
    final unknown = note.fields.keys.where((id) => !known.contains(id));
    if (unknown.isNotEmpty) {
      throw NoteTypeMismatchException(
        'Fields ${unknown.join(', ')} are not fields of note type '
        '${note.noteTypeId}',
      );
    }
  }

  Future<void> _writeFields(Note note) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.noteFields, [
      for (final MapEntry(:key, :value) in note.fields.entries)
        NoteFieldsCompanion.insert(noteId: note.id, fieldId: key, value: value),
    ]);
  });

  /// Loads the notes matching [filter] with their field values.
  Future<List<Note>> _query(
    Expression<bool> Function($NotesTable n) filter,
  ) async {
    final rows =
        await (_db.select(_db.notes)
              ..where(filter)
              ..orderBy([(n) => OrderingTerm(expression: n.id)]))
            .get();
    if (rows.isEmpty) return const [];
    final fieldRows = await (_db.select(_db.noteFields).join([
      innerJoin(_db.notes, _db.notes.id.equalsExp(_db.noteFields.noteId)),
    ])..where(filter(_db.notes))).map((r) => r.readTable(_db.noteFields)).get();

    final fields = <NoteId, Map<FieldDefinitionId, String>>{};
    for (final f in fieldRows) {
      (fields[f.noteId] ??= {})[f.fieldId] = f.value;
    }
    return [
      for (final row in rows)
        Note(
          id: row.id,
          collectionId: row.collectionId,
          noteTypeId: row.noteTypeId,
          fields: fields[row.id] ?? const {},
          source: switch (row.sourceKind) {
            null => null,
            final kind => SourceAttribution(
              kind: kind,
              reference: row.sourceReference,
            ),
          },
        ),
    ];
  }
}

EntityNotFoundException _notFound(NoteId id) =>
    EntityNotFoundException('Note $id does not exist');
