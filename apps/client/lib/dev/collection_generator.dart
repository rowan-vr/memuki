import 'dart:math';

import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

import '../domain/collection.dart';
import '../domain/ids.dart';
import '../domain/note.dart';
import '../domain/note_type.dart';
import '../domain/review.dart';
import '../domain/study_card.dart';
import '../storage/repositories/media_repository.dart';
import '../storage/repositories/repositories.dart';

/// Where generated IDs and review history start.
final generatorEpoch = DateTime.utc(2026);

/// A media file of a [GeneratedCollection].
typedef GeneratedMedia = ({String name, List<int> bytes});

/// A collection generated from a seed: decks and tags in random trees, a
/// note type with two fields and two templates, notes with tags and a card
/// per template, review history with scheduling state, and media files.
///
/// The same seed and sizes always give the same entities, IDs included, so a
/// test failure can be reproduced from its seed. Used by tests and by
/// `tool/memuki.dart generate`; nothing in the app uses it.
class GeneratedCollection {
  GeneratedCollection._({
    required this.seed,
    required this.collection,
    required this.noteType,
    required this.decks,
    required this.tags,
    required this.notes,
    required this.noteTags,
    required this.cards,
    required this.reviews,
    required this.states,
    required this.media,
  });

  factory GeneratedCollection.generate({
    int seed = 0,
    int decks = 4,
    int tags = 4,
    int notes = 12,
    int maxReviews = 3,
    int media = 2,
  }) {
    final random = Random(seed);
    final ids = _IdSource(random);

    final collection = Collection(
      id: CollectionId.parse(ids.next()),
      name: 'Collection $seed',
    );
    final noteType = NoteType(
      id: NoteTypeId.parse(ids.next()),
      collectionId: collection.id,
      name: 'Basic',
      fields: [
        FieldDefinition(id: FieldDefinitionId.parse(ids.next()), name: 'Front'),
        FieldDefinition(id: FieldDefinitionId.parse(ids.next()), name: 'Back'),
      ],
      templates: [
        StudyCardTemplate(
          id: StudyCardTemplateId.parse(ids.next()),
          name: 'Recognition',
        ),
        StudyCardTemplate(
          id: StudyCardTemplateId.parse(ids.next()),
          name: 'Recall',
        ),
      ],
    );

    // Each deck or tag after the first may sit below an earlier one, so
    // parents always come before their children.
    T? parentOf<T>(List<T> earlier) => earlier.isEmpty || random.nextBool()
        ? null
        : earlier[random.nextInt(earlier.length)];

    final deckList = <Deck>[];
    for (var i = 0; i < decks; i++) {
      deckList.add(
        Deck(
          id: DeckId.parse(ids.next()),
          collectionId: collection.id,
          parentId: parentOf(deckList)?.id,
          name: 'Deck $i',
        ),
      );
    }
    final tagList = <Tag>[];
    for (var i = 0; i < tags; i++) {
      tagList.add(
        Tag(
          id: TagId.parse(ids.next()),
          collectionId: collection.id,
          parentId: parentOf(tagList)?.id,
          name: 'tag$i',
        ),
      );
    }

    final [front, back] = noteType.fields;
    final noteList = <Note>[];
    final noteTags = <NoteId, Set<TagId>>{};
    final cards = <StudyCard>[];
    final reviews = <ReviewEvent>[];
    final states = <SchedulingState>[];
    for (var i = 0; i < notes; i++) {
      final note = Note(
        id: NoteId.parse(ids.next()),
        collectionId: collection.id,
        noteTypeId: noteType.id,
        fields: {front.id: _word(random), back.id: 'meaning $i'},
        source: random.nextBool()
            ? SourceAttribution(
                kind: SourceKind.dictionary,
                reference: 'jmdict:$i',
              )
            : null,
      );
      noteList.add(note);
      noteTags[note.id] = {
        for (var t = random.nextInt(3); t > 0 && tagList.isNotEmpty; t--)
          tagList[random.nextInt(tagList.length)].id,
      };
      for (final template in noteType.templates) {
        final card = StudyCard(
          noteId: note.id,
          templateId: template.id,
          deckId: deckList[random.nextInt(deckList.length)].id,
        );
        cards.add(card);
        final history = [
          for (var r = random.nextInt(maxReviews + 1), day = 0; r > 0; r--)
            ReviewEvent(
              id: ReviewEventId.parse(ids.next()),
              studyCardId: card.id,
              kind: ReviewEventKind.review,
              at: generatorEpoch.add(
                Duration(days: day += 1 + random.nextInt(4)),
              ),
              grade: Grade.values[random.nextInt(Grade.values.length)],
              responseTime: Duration(milliseconds: 500 + random.nextInt(9500)),
              schedulerId: 'sm2',
              schedulerVersion: 1,
              configVersion: 1,
            ),
        ];
        reviews.addAll(history);
        states.add(
          history.isEmpty
              ? SchedulingState(
                  studyCardId: card.id,
                  state: StudyCardState.newCard,
                )
              : SchedulingState(
                  studyCardId: card.id,
                  state: StudyCardState.review,
                  due: history.last.at.add(Duration(days: history.length * 2)),
                  interval: Duration(days: history.length * 2),
                  ease: 2.5,
                  reviewCount: history.length,
                  lastEventId: history.last.id,
                ),
        );
      }
    }

    return GeneratedCollection._(
      seed: seed,
      collection: collection,
      noteType: noteType,
      decks: deckList,
      tags: tagList,
      notes: noteList,
      noteTags: noteTags,
      cards: cards,
      reviews: reviews,
      states: states,
      media: [
        for (var i = 0; i < media; i++)
          (
            name: 'audio$i.mp3',
            bytes: [
              for (var b = 64 + random.nextInt(192); b > 0; b--)
                random.nextInt(256),
            ],
          ),
      ],
    );
  }

  final int seed;
  final Collection collection;
  final NoteType noteType;

  /// Parents before their children.
  final List<Deck> decks;

  /// Parents before their children.
  final List<Tag> tags;
  final List<Note> notes;
  final Map<NoteId, Set<TagId>> noteTags;
  final List<StudyCard> cards;

  /// In the order they happened for each card.
  final List<ReviewEvent> reviews;
  final List<SchedulingState> states;
  final List<GeneratedMedia> media;

  CollectionId get id => collection.id;

  /// Writes the whole collection through the repositories.
  Future<void> writeTo(Repositories repos, MediaRepository mediaRepo) async {
    await repos.collections.createCollection(collection);
    await repos.noteTypes.createNoteType(noteType);
    for (final deck in decks) {
      await repos.collections.createDeck(deck);
    }
    for (final tag in tags) {
      await repos.tags.createTag(tag);
    }
    for (final note in notes) {
      await repos.notes.createNote(note);
      for (final tagId in noteTags[note.id]!) {
        await repos.notes.addTag(note.id, tagId);
      }
    }
    for (final card in cards) {
      await repos.cards.createCard(card);
    }
    for (final event in reviews) {
      await repos.reviews.append(event);
    }
    for (final state in states) {
      await repos.cards.saveSchedulingState(state);
    }
    for (final file in media) {
      await mediaRepo.addMedia(id, Stream.value(file.bytes), name: file.name);
    }
  }
}

/// UUIDv7 strings from a seeded random source, a millisecond apart.
class _IdSource {
  _IdSource(this._random);

  static const _uuid = Uuid();

  final Random _random;
  var _millis = generatorEpoch.millisecondsSinceEpoch;

  String next() => _uuid.v7(
    config: V7Options(_millis++, [
      for (var i = 0; i < 10; i++) _random.nextInt(256),
    ]),
  );
}

const _kana = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわん';

String _word(Random random) => String.fromCharCodes([
  for (var i = 1 + random.nextInt(4); i > 0; i--)
    _kana.codeUnitAt(random.nextInt(_kana.length)),
]);
