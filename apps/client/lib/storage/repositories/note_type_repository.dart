import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/note_type.dart';
import '../database.dart';
import 'repository_exceptions.dart';
import 'watch_tables.dart';

/// Note types with their fields and card templates, saved as one unit.
class NoteTypeRepository {
  NoteTypeRepository(this._db);

  final MemukiDatabase _db;

  Future<NoteType?> noteType(NoteTypeId id) async {
    final row = await _noteTypeRow(id);
    if (row == null) return null;
    return (await _assemble([row])).single;
  }

  /// All note types of a collection, by name.
  Future<List<NoteType>> noteTypes(CollectionId collectionId) async {
    final rows =
        await (_db.select(_db.noteTypes)
              ..where((t) => t.collectionId.equalsValue(collectionId))
              ..orderBy([(t) => OrderingTerm(expression: t.name)]))
            .get();
    return _assemble(rows);
  }

  Stream<List<NoteType>> watchNoteTypes(CollectionId collectionId) =>
      watchTables(_db, [
        _db.noteTypes,
        _db.fieldDefinitions,
        _db.studyCardTemplates,
      ], () => noteTypes(collectionId));

  Future<void> createNoteType(NoteType noteType) => _db.transaction(() async {
    final collection = await (_db.select(
      _db.collections,
    )..where((c) => c.id.equalsValue(noteType.collectionId))).getSingleOrNull();
    if (collection == null) {
      throw EntityNotFoundException(
        'Collection ${noteType.collectionId} does not exist',
      );
    }
    await _db
        .into(_db.noteTypes)
        .insert(
          NoteTypesCompanion.insert(
            id: noteType.id,
            collectionId: noteType.collectionId,
            name: noteType.name,
          ),
        );
    await _writeParts(noteType);
  });

  /// Saves the note type's name, fields, and templates.
  ///
  /// Removing a field deletes its values from all notes. Removing a template
  /// that still has cards is rejected.
  Future<void> updateNoteType(NoteType noteType) => _db.transaction(() async {
    final current = await _noteTypeRow(noteType.id);
    if (current == null) throw _notFound(noteType.id);
    if (current.collectionId != noteType.collectionId) {
      throw CrossCollectionException(
        'Note type ${noteType.id} cannot move to another collection',
      );
    }

    final fieldIds = [for (final f in noteType.fields) f.id];
    final templateIds = [for (final t in noteType.templates) t.id];
    final foreignField =
        await (_db.select(_db.fieldDefinitions)..where(
              (f) =>
                  f.id.isInValues(fieldIds) &
                  f.noteTypeId.equalsValue(noteType.id).not(),
            ))
            .get();
    final foreignTemplate =
        await (_db.select(_db.studyCardTemplates)..where(
              (t) =>
                  t.id.isInValues(templateIds) &
                  t.noteTypeId.equalsValue(noteType.id).not(),
            ))
            .get();
    if (foreignField.isNotEmpty || foreignTemplate.isNotEmpty) {
      throw NoteTypeMismatchException(
        'Note type ${noteType.id} uses fields or templates of another '
        'note type',
      );
    }

    final removedTemplates = _db.selectOnly(_db.studyCardTemplates)
      ..addColumns([_db.studyCardTemplates.id])
      ..where(
        _db.studyCardTemplates.noteTypeId.equalsValue(noteType.id) &
            _db.studyCardTemplates.id.isInValues(templateIds).not(),
      );
    final cardsOfRemoved =
        await (_db.select(_db.studyCards)
              ..where((c) => c.templateId.isInQuery(removedTemplates))
              ..limit(1))
            .get();
    if (cardsOfRemoved.isNotEmpty) {
      throw EntityInUseException(
        'Note type ${noteType.id} removes a template that has cards',
      );
    }

    await (_db.update(_db.noteTypes)
          ..where((t) => t.id.equalsValue(noteType.id)))
        .write(NoteTypesCompanion(name: Value(noteType.name)));
    await (_db.delete(_db.fieldDefinitions)..where(
          (f) =>
              f.noteTypeId.equalsValue(noteType.id) &
              f.id.isInValues(fieldIds).not(),
        ))
        .go();
    await (_db.delete(_db.studyCardTemplates)..where(
          (t) =>
              t.noteTypeId.equalsValue(noteType.id) &
              t.id.isInValues(templateIds).not(),
        ))
        .go();
    await _writeParts(noteType);
  });

  /// Deletes a note type that no notes use.
  Future<void> deleteNoteType(NoteTypeId id) => _db.transaction(() async {
    if (await _noteTypeRow(id) == null) throw _notFound(id);
    final notes =
        await (_db.select(_db.notes)
              ..where((n) => n.noteTypeId.equalsValue(id))
              ..limit(1))
            .get();
    if (notes.isNotEmpty) {
      throw EntityInUseException('Note type $id is used by notes');
    }
    await (_db.delete(_db.noteTypes)..where((t) => t.id.equalsValue(id))).go();
  });

  Future<NoteTypeRow?> _noteTypeRow(NoteTypeId id) => (_db.select(
    _db.noteTypes,
  )..where((t) => t.id.equalsValue(id))).getSingleOrNull();

  /// Inserts or updates the fields and templates, with their list positions.
  ///
  /// Uses an upsert rather than REPLACE, which would delete the old row and
  /// cascade to the notes' field values.
  Future<void> _writeParts(NoteType noteType) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.fieldDefinitions, [
      for (final (i, field) in noteType.fields.indexed)
        FieldDefinitionsCompanion.insert(
          id: field.id,
          noteTypeId: noteType.id,
          position: i,
          name: field.name,
          type: field.type,
        ),
    ]);
    b.insertAllOnConflictUpdate(_db.studyCardTemplates, [
      for (final (i, template) in noteType.templates.indexed)
        StudyCardTemplatesCompanion.insert(
          id: template.id,
          noteTypeId: noteType.id,
          position: i,
          name: template.name,
        ),
    ]);
  });

  Future<List<NoteType>> _assemble(List<NoteTypeRow> rows) async {
    final ids = [for (final r in rows) r.id];
    final fields =
        await (_db.select(_db.fieldDefinitions)
              ..where((f) => f.noteTypeId.isInValues(ids))
              ..orderBy([(f) => OrderingTerm(expression: f.position)]))
            .get();
    final templates =
        await (_db.select(_db.studyCardTemplates)
              ..where((t) => t.noteTypeId.isInValues(ids))
              ..orderBy([(t) => OrderingTerm(expression: t.position)]))
            .get();
    return [
      for (final row in rows)
        NoteType(
          id: row.id,
          collectionId: row.collectionId,
          name: row.name,
          fields: [
            for (final f in fields)
              if (f.noteTypeId == row.id)
                FieldDefinition(id: f.id, name: f.name, type: f.type),
          ],
          templates: [
            for (final t in templates)
              if (t.noteTypeId == row.id)
                StudyCardTemplate(id: t.id, name: t.name),
          ],
        ),
    ];
  }
}

EntityNotFoundException _notFound(NoteTypeId id) =>
    EntityNotFoundException('Note type $id does not exist');
