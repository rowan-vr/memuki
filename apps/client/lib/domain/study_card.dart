import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';

part 'study_card.freezed.dart';

/// A card generated from a note by one card template. Its identity is the
/// (note, template) pair; [id] is derived from it.
@freezed
abstract class StudyCard with _$StudyCard {
  StudyCard._();

  factory StudyCard({
    required NoteId noteId,
    required StudyCardTemplateId templateId,
    required DeckId deckId,
  }) = _StudyCard;

  StudyCardId get id => StudyCardId.derive(noteId, templateId);
}
