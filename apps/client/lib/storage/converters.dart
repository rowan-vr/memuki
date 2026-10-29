import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/ids.dart';

/// Stores an entity ID as its 16 UUID bytes.
///
/// IDs are extension types over their canonical string, so [T] is a `String`
/// at runtime.
class IdConverter<T extends Object> extends TypeConverter<T, Uint8List> {
  const IdConverter(this._parse);

  final T Function(String) _parse;

  @override
  T fromSql(Uint8List fromDb) => _parse(Uuid.unparse(fromDb));

  @override
  Uint8List toSql(T value) => Uint8List.fromList(Uuid.parse(value as String));
}

/// Stores a [ContentHash] as its 32 digest bytes.
class ContentHashConverter extends TypeConverter<ContentHash, Uint8List> {
  const ContentHashConverter();

  @override
  ContentHash fromSql(Uint8List fromDb) => ContentHash.parse(
    fromDb.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
  );

  @override
  Uint8List toSql(ContentHash value) => Uint8List.fromList([
    for (var i = 0; i < value.value.length; i += 2)
      int.parse(value.value.substring(i, i + 2), radix: 16),
  ]);
}

/// Stores a UTC [DateTime] as milliseconds since the Unix epoch.
class UtcMillisConverter extends TypeConverter<DateTime, int> {
  const UtcMillisConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

/// Stores a [Duration] as whole milliseconds.
class DurationMillisConverter extends TypeConverter<Duration, int> {
  const DurationMillisConverter();

  @override
  Duration fromSql(int fromDb) => Duration(milliseconds: fromDb);

  @override
  int toSql(Duration value) => value.inMilliseconds;
}

const collectionIdConverter = IdConverter<CollectionId>(CollectionId.parse);
const deckIdConverter = IdConverter<DeckId>(DeckId.parse);
const noteTypeIdConverter = IdConverter<NoteTypeId>(NoteTypeId.parse);
const fieldDefinitionIdConverter = IdConverter<FieldDefinitionId>(
  FieldDefinitionId.parse,
);
const studyCardTemplateIdConverter = IdConverter<StudyCardTemplateId>(
  StudyCardTemplateId.parse,
);
const noteIdConverter = IdConverter<NoteId>(NoteId.parse);
const tagIdConverter = IdConverter<TagId>(TagId.parse);
const studyCardIdConverter = IdConverter<StudyCardId>(StudyCardId.parse);
const reviewEventIdConverter = IdConverter<ReviewEventId>(ReviewEventId.parse);
