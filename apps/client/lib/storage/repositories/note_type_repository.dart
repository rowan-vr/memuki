import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/note_type.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import '../sync/hlc.dart';
import 'repository_exceptions.dart';
import 'visibility.dart';
import 'watch_tables.dart';

/// Note types with their fields and card templates, saved as one unit.
class NoteTypeRepository {
  NoteTypeRepository(this._db) : _changes = ChangeRecorder(_db);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;

  Future<NoteType?> noteType(NoteTypeId id) async {
    final row = await _noteTypeRow(id);
    if (row == null) return null;
    return (await _assemble([row])).single;
  }

  /// All note types of a collection, by name.
  Future<List<NoteType>> noteTypes(CollectionId collectionId) async {
    final rows =
        await (_db.select(_db.noteTypes)
              ..where(
                (t) =>
                    t.collectionId.equalsValue(collectionId) &
                    _db.isVisibleNoteType(t.id),
              )
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

  Future<void> createNoteType(NoteType noteType) => _changes.write((hlc) async {
    final collection =
        await (_db.select(_db.collections)..where(
              (c) =>
                  c.id.equalsValue(noteType.collectionId) &
                  _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
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
            hlc: hlc,
          ),
        );
    await _writeParts(noteType, hlc);
  });

  /// Saves the note type's name, fields, and templates.
  ///
  /// Removing a field hides its values in all notes; adding it back with the
  /// same ID shows them again. Removing a template that still has cards is
  /// rejected.
  Future<void> updateNoteType(NoteType noteType) => _changes.write((hlc) async {
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
            _db.isVisibleTemplate(_db.studyCardTemplates.id) &
            _db.studyCardTemplates.id.isInValues(templateIds).not(),
      );
    final cardsOfRemoved =
        await (_db.select(_db.studyCards)
              ..where(
                (c) =>
                    c.templateId.isInQuery(removedTemplates) &
                    _db.isVisibleCard(c.id),
              )
              ..limit(1))
            .get();
    if (cardsOfRemoved.isNotEmpty) {
      throw EntityInUseException(
        'Note type ${noteType.id} removes a template that has cards',
      );
    }

    if (current.name != noteType.name) {
      await (_db.update(
        _db.noteTypes,
      )..where((t) => t.id.equalsValue(noteType.id))).write(
        NoteTypesCompanion(name: Value(noteType.name), hlc: Value(hlc)),
      );
    }

    await (_db.update(_db.fieldDefinitions)..where(
          (f) =>
              f.noteTypeId.equalsValue(noteType.id) &
              _db.isVisibleFieldDefinition(f.id) &
              f.id.isInValues(fieldIds).not(),
        ))
        .write(
          FieldDefinitionsCompanion(
            deleted: const Value(true),
            hlc: Value(hlc),
          ),
        );
    await (_db.update(_db.studyCardTemplates)..where(
          (t) =>
              t.noteTypeId.equalsValue(noteType.id) &
              _db.isVisibleTemplate(t.id) &
              t.id.isInValues(templateIds).not(),
        ))
        .write(
          StudyCardTemplatesCompanion(
            deleted: const Value(true),
            hlc: Value(hlc),
          ),
        );
    await _writeParts(
      noteType,
      hlc,
      currentFields: {
        for (final f in await _liveFields([noteType.id])) f.id: f,
      },
      currentTemplates: {
        for (final t in await _liveTemplates([noteType.id])) t.id: t,
      },
    );
  });

  /// Deletes a note type that no notes use.
  Future<void> deleteNoteType(NoteTypeId id) => _changes.write((hlc) async {
    if (await _noteTypeRow(id) == null) throw _notFound(id);
    final notes =
        await (_db.select(_db.notes)
              ..where(
                (n) => n.noteTypeId.equalsValue(id) & _db.isVisibleNote(n.id),
              )
              ..limit(1))
            .get();
    if (notes.isNotEmpty) {
      throw EntityInUseException('Note type $id is used by notes');
    }
    await (_db.update(_db.noteTypes)..where((t) => t.id.equalsValue(id))).write(
      NoteTypesCompanion(deleted: const Value(true), hlc: Value(hlc)),
    );
  });

  Future<NoteTypeRow?> _noteTypeRow(NoteTypeId id) =>
      (_db.select(_db.noteTypes)
            ..where((t) => t.id.equalsValue(id) & _db.isVisibleNoteType(t.id)))
          .getSingleOrNull();

  /// Inserts or updates the fields and templates, with their list positions.
  /// Only parts that differ from [currentFields] and [currentTemplates] are
  /// written, so unchanged parts keep their timestamps.
  ///
  /// Uses an upsert rather than REPLACE, which would delete the old row and
  /// cascade to the notes' field values.
  Future<void> _writeParts(
    NoteType noteType,
    Hlc hlc, {
    Map<FieldDefinitionId, FieldDefinitionRow> currentFields = const {},
    Map<StudyCardTemplateId, StudyCardTemplateRow> currentTemplates = const {},
  }) => _db.batch((b) {
    bool fieldChanged(int i, FieldDefinition field) =>
        switch (currentFields[field.id]) {
          final current? =>
            current.position != i ||
                current.name != field.name ||
                current.type != field.type,
          null => true,
        };
    bool templateChanged(int i, StudyCardTemplate template) =>
        switch (currentTemplates[template.id]) {
          final current? =>
            current.position != i || current.name != template.name,
          null => true,
        };
    b.insertAllOnConflictUpdate(_db.fieldDefinitions, [
      for (final (i, field) in noteType.fields.indexed)
        if (fieldChanged(i, field))
          FieldDefinitionsCompanion.insert(
            id: field.id,
            noteTypeId: noteType.id,
            position: i,
            name: field.name,
            type: field.type,
            hlc: hlc,
            deleted: const Value(false),
          ),
    ]);
    b.insertAllOnConflictUpdate(_db.studyCardTemplates, [
      for (final (i, template) in noteType.templates.indexed)
        if (templateChanged(i, template))
          StudyCardTemplatesCompanion.insert(
            id: template.id,
            noteTypeId: noteType.id,
            position: i,
            name: template.name,
            hlc: hlc,
            deleted: const Value(false),
          ),
    ]);
  });

  Future<List<FieldDefinitionRow>> _liveFields(List<NoteTypeId> ids) =>
      (_db.select(_db.fieldDefinitions)
            ..where(
              (f) =>
                  f.noteTypeId.isInValues(ids) &
                  _db.isVisibleFieldDefinition(f.id),
            )
            ..orderBy([(f) => OrderingTerm(expression: f.position)]))
          .get();

  Future<List<StudyCardTemplateRow>> _liveTemplates(List<NoteTypeId> ids) =>
      (_db.select(_db.studyCardTemplates)
            ..where(
              (t) => t.noteTypeId.isInValues(ids) & _db.isVisibleTemplate(t.id),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .get();

  Future<List<NoteType>> _assemble(List<NoteTypeRow> rows) async {
    final ids = [for (final r in rows) r.id];
    final fields = await _liveFields(ids);
    final templates = await _liveTemplates(ids);
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
