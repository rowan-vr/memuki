import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'study_card.freezed.dart';

/// A card generated from a note by one card template. Its identity is the
/// (note, template) pair; [id] is derived from it.
@freezed
abstract class StudyCard with _$StudyCard {
  StudyCard._() {
    requireUtc(buriedUntil, 'buriedUntil');
  }

  factory StudyCard({
    required NoteId noteId,
    required StudyCardTemplateId templateId,
    required DeckId deckId,

    /// A suspended card keeps its scheduling state but is left out of every
    /// queue until it is unsuspended.
    @Default(false) bool suspended,

    /// A buried card is left out of queues until this time.
    DateTime? buriedUntil,
  }) = _StudyCard;

  StudyCardId get id => StudyCardId.derive(noteId, templateId);
}
