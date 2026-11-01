import 'package:freezed_annotation/freezed_annotation.dart';

import 'content/card_renderer.dart';
import 'content/content_node.dart';
import 'content/content_parser.dart';
import 'content/content_writer.dart';
import 'content/field_references.dart';
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
    if (language case final language? when language.trim().isEmpty) {
      throw ArgumentError.value(language, 'language', 'must not be empty');
    }
  }

  factory FieldDefinition({
    required FieldDefinitionId id,
    required String name,
    @Default(FieldType.text) FieldType type,

    /// The language of its values, as a BCP 47 tag such as ja; a `lang`
    /// mark overrides it for a span. Null when it is not set.
    String? language,

    /// Whether a note must fill it.
    @Default(false) bool isRequired,

    /// The kinds of mark its values may hold, or null for all. Marks inside
    /// one it allows, such as a list's items, go with it.
    Set<String>? allowedMarks,
  }) = _FieldDefinition;

  /// Whether a note's [value] leaves it unfilled although it is required.
  bool isMissing(List<ContentNode> value) =>
      isRequired && isEmptyContent(value);

  /// Whether its values may hold marks of [key].
  bool allows(String key) => allowedMarks?.contains(key) ?? true;

  /// The kinds of mark in [value] it does not allow. They are kept, so that
  /// nothing is lost, but are flagged where the value is edited.
  Set<String> disallowedMarks(List<ContentNode> value) {
    final out = <String>{};
    void visit(List<ContentNode> nodes) {
      for (final node in nodes) {
        if (node is! MarkNode) continue;
        if (allows(node.key)) continue;
        out.add(node.key);
        if (node.content case final content?) visit(content);
      }
    }

    if (allowedMarks != null) visit(value);
    return out;
  }
}

/// A card template of a note type. Each template generates one card per note.
/// Its position in [NoteType.templates] is its order.
@freezed
abstract class StudyCardTemplate with _$StudyCardTemplate {
  StudyCardTemplate._() {
    requireName(name, 'name');
  }

  factory StudyCardTemplate({
    required StudyCardTemplateId id,
    required String name,

    /// What the card shows, in the content format: a `front` and a `back`
    /// that place the note's fields by name.
    @Default(StudyCardTemplate.blank) String source,
  }) = _StudyCardTemplate;

  /// A card with nothing on either side.
  static const blank = '{front |}\n{back |}';

  /// The fields it refers to, by name.
  Set<String> get fieldNames => fieldReferences(parseContent(source).nodes);
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
    if (duplicateCheck case final id? when field(id) == null) {
      throw ArgumentError.value(id, 'duplicateCheck', 'must be one of fields');
    }
  }

  /// Templates name fields that may be missing: after a rename merged from
  /// another device, say. They are kept, and editors flag them.
  factory NoteType({
    required NoteTypeId id,
    required CollectionId collectionId,
    required String name,
    required List<FieldDefinition> fields,
    required List<StudyCardTemplate> templates,

    /// The field whose plain text is compared across notes, to warn of
    /// duplicates. Null when none is.
    FieldDefinitionId? duplicateCheck,
  }) = _NoteType;

  /// The field with [id], or null if this note type has no such field.
  FieldDefinition? field(FieldDefinitionId id) {
    for (final f in fields) {
      if (f.id == id) return f;
    }
    return null;
  }

  /// The fields [template] names that this note type does not have.
  Set<String> missingFields(StudyCardTemplate template) => {
    for (final name in template.fieldNames)
      if (!fields.any((f) => f.name == name)) name,
  };

  /// The templates that name the field [id].
  List<StudyCardTemplate> templatesUsing(FieldDefinitionId id) {
    final name = field(id)?.name;
    return [
      for (final t in templates)
        if (t.fieldNames.contains(name)) t,
    ];
  }

  /// This note type with the field [id] named [name], and its templates
  /// naming it so.
  NoteType renameField(FieldDefinitionId id, String name) {
    final old = field(id);
    if (old == null || old.name == name) return this;
    return copyWith(
      fields: [for (final f in fields) f.id == id ? f.copyWith(name: name) : f],
      templates: _rewrite(
        old.name,
        (nodes) => renameFieldReferences(nodes, old.name, name),
      ),
    );
  }

  /// This note type without the field [id], and its templates without what
  /// they placed of it. Notes keep their values for it, hidden.
  NoteType removeField(FieldDefinitionId id) {
    final old = field(id);
    if (old == null) return this;
    return copyWith(
      fields: [
        for (final f in fields)
          if (f.id != id) f,
      ],
      templates: _rewrite(
        old.name,
        (nodes) => removeFieldReferences(nodes, old.name),
      ),
      duplicateCheck: duplicateCheck == id ? null : duplicateCheck,
    );
  }

  /// The templates, with those that name the field [name] changed by
  /// [change]. The others keep their source as written.
  List<StudyCardTemplate> _rewrite(
    String name,
    List<ContentNode> Function(List<ContentNode> nodes) change,
  ) => [
    for (final t in templates)
      t.fieldNames.contains(name)
          ? t.copyWith(
              source: writeContent(change(parseContent(t.source).nodes)),
            )
          : t,
  ];
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
