import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'note.freezed.dart';

/// A label on notes within one collection. Tags are entities with stable IDs,
/// so renaming one is a single change. Tags can be nested through [parentId],
/// like decks.
///
/// Names are unique among tags with the same parent, ignoring case;
/// repositories enforce this.
@freezed
abstract class Tag with _$Tag {
  Tag._() {
    requireName(name, 'name');
    if (parentId == id) {
      throw ArgumentError.value(
        parentId,
        'parentId',
        'must not be the tag itself',
      );
    }
  }

  factory Tag({
    required TagId id,
    required CollectionId collectionId,
    TagId? parentId,
    required String name,
  }) = _Tag;
}

/// A tag on a note. Membership is its own synced row rather than a list on
/// the note, so tags added on different devices merge and a removal is
/// recorded on its own.
@freezed
abstract class NoteTag with _$NoteTag {
  factory NoteTag({required NoteId noteId, required TagId tagId}) = _NoteTag;
}

/// Where a note came from.
enum SourceKind { manual, dictionary, import }

/// Where a note came from, with an optional reference into the source, such as
/// a dictionary entry or an imported note's original ID.
@freezed
abstract class SourceAttribution with _$SourceAttribution {
  factory SourceAttribution({required SourceKind kind, String? reference}) =
      _SourceAttribution;
}

/// A note: field values for one note type. Cards are generated from it, one
/// per card template.
///
/// [fields] is keyed by field definition ID, so renaming or reordering fields
/// does not affect existing notes. Fields without a value are absent. Tags are
/// attached through [NoteTag].
@freezed
abstract class Note with _$Note {
  factory Note({
    required NoteId id,
    required CollectionId collectionId,
    required NoteTypeId noteTypeId,
    required Map<FieldDefinitionId, String> fields,
    SourceAttribution? source,
  }) = _Note;
}
