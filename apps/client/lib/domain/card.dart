import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';

part 'card.freezed.dart';

/// A card generated from a note by one card template. Its identity is the
/// (note, template) pair; [id] is derived from it.
@freezed
abstract class Card with _$Card {
  Card._();

  factory Card({
    required NoteId noteId,
    required CardTemplateId templateId,
    required DeckId deckId,
  }) = _Card;

  CardId get id => CardId.derive(noteId, templateId);
}
