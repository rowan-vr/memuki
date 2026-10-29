/// Entity IDs are client-generated UUIDv7 strings in canonical lowercase form.
/// They sort by creation time to the millisecond; ordering of changes comes
/// from HLC timestamps, not IDs.
///
/// Each entity has its own extension type, so IDs of different entities cannot
/// be mixed up. They are plain strings at runtime.
library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _canonical = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

String _generate() => _uuid.v7();

String _parse(String value) {
  final lower = value.toLowerCase();
  if (!_canonical.hasMatch(lower)) {
    throw FormatException('Not a UUID', value);
  }
  return lower;
}

extension type const CollectionId._(String value) implements Object {
  CollectionId.generate() : this._(_generate());
  CollectionId.parse(String value) : this._(_parse(value));
}

extension type const DeckId._(String value) implements Object {
  DeckId.generate() : this._(_generate());
  DeckId.parse(String value) : this._(_parse(value));
}

extension type const NoteTypeId._(String value) implements Object {
  NoteTypeId.generate() : this._(_generate());
  NoteTypeId.parse(String value) : this._(_parse(value));
}

extension type const FieldDefinitionId._(String value) implements Object {
  FieldDefinitionId.generate() : this._(_generate());
  FieldDefinitionId.parse(String value) : this._(_parse(value));
}

extension type const CardTemplateId._(String value) implements Object {
  CardTemplateId.generate() : this._(_generate());
  CardTemplateId.parse(String value) : this._(_parse(value));
}

extension type const NoteId._(String value) implements Object {
  NoteId.generate() : this._(_generate());
  NoteId.parse(String value) : this._(_parse(value));
}

extension type const TagId._(String value) implements Object {
  TagId.generate() : this._(_generate());
  TagId.parse(String value) : this._(_parse(value));
}

extension type const ReviewEventId._(String value) implements Object {
  ReviewEventId.generate() : this._(_generate());
  ReviewEventId.parse(String value) : this._(_parse(value));
}

/// A card is identified by its note and card template. Its ID is derived from
/// that pair, so devices that create the same card independently produce the
/// same ID.
///
/// The derived ID is a UUIDv8 (RFC 9562) built from the first 16 bytes of
/// SHA-256 over both IDs' bytes.
extension type const CardId._(String value) implements Object {
  factory CardId.derive(NoteId note, CardTemplateId template) {
    final digest = sha256.convert([
      ...Uuid.parse(note.value),
      ...Uuid.parse(template.value),
    ]);
    final bytes = Uint8List.fromList(digest.bytes.sublist(0, 16));
    bytes[6] = (bytes[6] & 0x0f) | 0x80; // version 8
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 9562 variant
    return CardId._(Uuid.unparse(bytes));
  }

  CardId.parse(String value) : this._(_parse(value));
}

/// SHA-256 of a media file's contents, as 64 lowercase hex characters.
extension type const ContentHash._(String value) implements Object {
  factory ContentHash.of(List<int> bytes) =>
      ContentHash._(sha256.convert(bytes).toString());

  factory ContentHash.parse(String value) {
    final lower = value.toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(lower)) {
      throw FormatException('Not a SHA-256 hex digest', value);
    }
    return ContentHash._(lower);
  }
}
