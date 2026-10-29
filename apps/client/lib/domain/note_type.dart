import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'note_type.freezed.dart';

/// How a field's value is stored and edited. More types are added as they are
/// needed; the rich-text representation is decided in Phase 3.
enum FieldType { text }

/// A field of a note type. Its position in [NoteType.fields] is its order.
@freezed
abstract class FieldDefinition with _$FieldDefinition {
  FieldDefinition._() {
    requireName(name, 'name');
  }

  factory FieldDefinition({
    required FieldDefinitionId id,
    required String name,
    @Default(FieldType.text) FieldType type,
  }) = _FieldDefinition;
}

/// A card template of a note type. Each template generates one card per note.
/// Its position in [NoteType.templates] is its order; its layout is defined in
/// Phase 3.
@freezed
abstract class StudyCardTemplate with _$StudyCardTemplate {
  StudyCardTemplate._() {
    requireName(name, 'name');
  }

  factory StudyCardTemplate({
    required StudyCardTemplateId id,
    required String name,
  }) = _StudyCardTemplate;
}

/// The structure of a kind of note: its fields and the cards it generates.
/// Note types belong to one collection.
@freezed
abstract class NoteType with _$NoteType {
  NoteType._() {
    requireName(name, 'name');
    _requireUnique(fields, (f) => f.id, (f) => f.name, 'fields');
    _requireUnique(templates, (t) => t.id, (t) => t.name, 'templates');
    if (fields.isEmpty) {
      throw ArgumentError.value(fields, 'fields', 'must not be empty');
    }
    if (templates.isEmpty) {
      throw ArgumentError.value(templates, 'templates', 'must not be empty');
    }
  }

  factory NoteType({
    required NoteTypeId id,
    required CollectionId collectionId,
    required String name,
    required List<FieldDefinition> fields,
    required List<StudyCardTemplate> templates,
  }) = _NoteType;

  /// The field with [id], or null if this note type has no such field.
  FieldDefinition? field(FieldDefinitionId id) {
    for (final f in fields) {
      if (f.id == id) return f;
    }
    return null;
  }
}

void _requireUnique<T>(
  List<T> items,
  Object Function(T) id,
  String Function(T) name,
  String argument,
) {
  if (items.map(id).toSet().length != items.length) {
    throw ArgumentError.value(items, argument, 'must have unique IDs');
  }
  if (items.map(name).toSet().length != items.length) {
    throw ArgumentError.value(items, argument, 'must have unique names');
  }
}
