import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';

import 'runner.dart';
import 'session.dart';

List<Command<void>> editCommands() => [
  GroupCommand('collection', 'Create, rename, and delete collections.', [
    ActionCommand(
      'add',
      'Create a collection. Unless --empty, it gets a "Default" deck and a '
          '"Basic" note type (Front, Back; one template).',
      _addCollection,
      arguments: '<name>',
      options: (p) => p.addFlag('empty', negatable: false),
    ),
    ActionCommand('rename', 'Rename a collection.', (c, s) async {
      final id = await _collection(s, c.arg(0, 'collection'));
      final current = (await s.repos.collections.collection(id))!;
      await s.repos.collections.updateCollection(
        current.copyWith(name: c.arg(1, 'name')),
      );
    }, arguments: '<collection> <name>'),
    ActionCommand('delete', 'Delete a collection.', (c, s) async {
      await s.repos.collections.deleteCollection(
        await _collection(s, c.arg(0, 'collection')),
      );
      s.out.writeln('Deleted. Everything in it is hidden.');
    }, arguments: '<collection>'),
  ]),
  GroupCommand('deck', 'Create, rename, move, and delete decks.', [
    ActionCommand(
      'add',
      'Create a deck.',
      (c, s) async {
        final deck = Deck(
          id: DeckId.generate(),
          collectionId: await _collection(s, c.arg(0, 'collection')),
          parentId: await _optional(
            s,
            'decks',
            c.option('parent'),
            DeckId.parse,
          ),
          name: c.arg(1, 'name'),
        );
        await s.repos.collections.createDeck(deck);
        s.out.writeln('Created deck ${short(deck.id)}.');
      },
      arguments: '<collection> <name>',
      options: (p) => p.addOption('parent'),
    ),
    ActionCommand('rename', 'Rename a deck.', (c, s) async {
      final deck = await _deck(s, c.arg(0, 'deck'));
      await s.repos.collections.updateDeck(
        deck.copyWith(name: c.arg(1, 'name')),
      );
    }, arguments: '<deck> <name>'),
    ActionCommand(
      'move',
      'Move a deck below another one, or to the top without --parent.',
      (c, s) async {
        final deck = await _deck(s, c.arg(0, 'deck'));
        await s.repos.collections.updateDeck(
          deck.copyWith(
            parentId: await _optional(
              s,
              'decks',
              c.option('parent'),
              DeckId.parse,
            ),
          ),
        );
      },
      arguments: '<deck>',
      options: (p) => p.addOption('parent'),
    ),
    ActionCommand('delete', 'Delete a deck.', (c, s) async {
      final deck = await _deck(s, c.arg(0, 'deck'));
      await s.repos.collections.deleteDeck(deck.id);
      s.out.writeln(
        'Deleted. Its subdecks, cards, and notes left without cards are '
        'hidden.',
      );
    }, arguments: '<deck>'),
  ]),
  GroupCommand('tag', 'Create, rename, move, and delete tags.', [
    ActionCommand(
      'add',
      'Create a tag.',
      (c, s) async {
        final tag = Tag(
          id: TagId.generate(),
          collectionId: await _collection(s, c.arg(0, 'collection')),
          parentId: await _optional(s, 'tags', c.option('parent'), TagId.parse),
          name: c.arg(1, 'name'),
        );
        await s.repos.tags.createTag(tag);
        s.out.writeln('Created tag ${short(tag.id)}.');
      },
      arguments: '<collection> <name>',
      options: (p) => p.addOption('parent'),
    ),
    ActionCommand('rename', 'Rename a tag.', (c, s) async {
      final tag = await _tag(s, c.arg(0, 'tag'));
      await s.repos.tags.updateTag(tag.copyWith(name: c.arg(1, 'name')));
    }, arguments: '<tag> <name>'),
    ActionCommand(
      'move',
      'Move a tag below another one, or to the top without --parent.',
      (c, s) async {
        final tag = await _tag(s, c.arg(0, 'tag'));
        await s.repos.tags.updateTag(
          tag.copyWith(
            parentId: await _optional(
              s,
              'tags',
              c.option('parent'),
              TagId.parse,
            ),
          ),
        );
      },
      arguments: '<tag>',
      options: (p) => p.addOption('parent'),
    ),
    ActionCommand('delete', 'Delete a tag and the tags below it.', (
      c,
      s,
    ) async {
      await s.repos.tags.deleteTag((await _tag(s, c.arg(0, 'tag'))).id);
    }, arguments: '<tag>'),
  ]),
  GroupCommand('notetype', 'Create, rename, and delete note types.', [
    ActionCommand(
      'add',
      'Create a note type.',
      (c, s) async {
        final fields = c.argResults!['field'] as List<String>;
        final templates = c.argResults!['template'] as List<String>;
        final type = NoteType(
          id: NoteTypeId.generate(),
          collectionId: await _collection(s, c.arg(0, 'collection')),
          name: c.arg(1, 'name'),
          fields: [
            for (final f in fields.isEmpty ? ['Front', 'Back'] : fields)
              FieldDefinition(id: FieldDefinitionId.generate(), name: f),
          ],
          templates: [
            for (final t in templates.isEmpty ? ['Card 1'] : templates)
              StudyCardTemplate(id: StudyCardTemplateId.generate(), name: t),
          ],
        );
        await s.repos.noteTypes.createNoteType(type);
        s.out.writeln('Created note type ${short(type.id)}.');
      },
      arguments: '<collection> <name>',
      options: (p) => p
        ..addMultiOption('field', help: 'Default: Front, Back.')
        ..addMultiOption('template', help: 'Default: Card 1.'),
    ),
    ActionCommand('rename', 'Rename a note type.', (c, s) async {
      final type = await _noteType(s, c.arg(0, 'note type'));
      await s.repos.noteTypes.updateNoteType(
        type.copyWith(name: c.arg(1, 'name')),
      );
    }, arguments: '<note type> <name>'),
    ActionCommand('delete', 'Delete a note type that no notes use.', (
      c,
      s,
    ) async {
      final type = await _noteType(s, c.arg(0, 'note type'));
      await s.repos.noteTypes.deleteNoteType(type.id);
    }, arguments: '<note type>'),
  ]),
  GroupCommand('note', 'Create, edit, tag, and delete notes.', [
    ActionCommand(
      'add',
      'Create a note with a card for each template. Fields are given as '
          'Name=value.',
      _addNote,
      arguments: '<collection> <Field=value>...',
      options: (p) => p
        ..addOption('type', help: 'Needed if the collection has several.')
        ..addOption('deck', help: 'Needed if the collection has several.')
        ..addMultiOption('tag'),
    ),
    ActionCommand('edit', 'Change field values. Field= clears a field.', (
      c,
      s,
    ) async {
      final note = await _note(s, c.arg(0, 'note'));
      final type = (await s.repos.noteTypes.noteType(note.noteTypeId))!;
      final changes = _parseFields(type, c.argsFrom(1));
      final fields = {...note.fields, ...changes}
        ..removeWhere((_, value) => value.isEmpty);
      await s.repos.notes.updateNote(note.copyWith(fields: fields));
    }, arguments: '<note> <Field=value>...'),
    ActionCommand('delete', 'Delete a note; its cards are hidden.', (
      c,
      s,
    ) async {
      await s.repos.notes.deleteNote((await _note(s, c.arg(0, 'note'))).id);
    }, arguments: '<note>'),
    ActionCommand('tag', 'Add a tag to a note.', (c, s) async {
      final note = await _note(s, c.arg(0, 'note'));
      await s.repos.notes.addTag(note.id, (await _tag(s, c.arg(1, 'tag'))).id);
    }, arguments: '<note> <tag>'),
    ActionCommand('untag', 'Remove a tag from a note.', (c, s) async {
      final note = await _note(s, c.arg(0, 'note'));
      await s.repos.notes.removeTag(
        note.id,
        (await _tag(s, c.arg(1, 'tag'))).id,
      );
    }, arguments: '<note> <tag>'),
  ]),
  GroupCommand('card', 'Move and delete cards.', [
    ActionCommand('move', 'Move a card to another deck.', (c, s) async {
      final card = await _card(s, c.arg(0, 'card'));
      final deck = await _deck(s, c.arg(1, 'deck'));
      await s.repos.cards.moveCard(card, deck.id);
    }, arguments: '<card> <deck>'),
    ActionCommand('delete', 'Delete a card; its history is kept.', (
      c,
      s,
    ) async {
      await s.repos.cards.deleteCard(await _card(s, c.arg(0, 'card')));
    }, arguments: '<card>'),
  ]),
  ActionCommand(
    'review',
    'Record a review of a card. Its scheduling state is not updated: there '
        'is no scheduler yet (Phase 2).',
    (c, s) async {
      final card = await _card(s, c.arg(0, 'card'));
      final gradeName = c.arg(1, 'again|hard|good|easy');
      final grade = Grade.values.where((g) => g.name == gradeName).firstOrNull;
      if (grade == null) {
        throw UsageException('Unknown grade "$gradeName".', c.usage);
      }
      final now = DateTime.now();
      final event = ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: card,
        kind: ReviewEventKind.review,
        at: now.toUtc(),
        utcOffset: now.timeZoneOffset,
        grade: grade,
        schedulerId: 'manual',
        schedulerVersion: 0,
        configVersion: 0,
      );
      await s.repos.reviews.append(event);
      s.out.writeln('Recorded review ${short(event.id)}.');
    },
    arguments: '<card> <again|hard|good|easy>',
  ),
  GroupCommand('media', 'Add, list, and delete media files.', [
    ActionCommand(
      'add',
      'Add a file to a collection.',
      (c, s) async {
        final collection = await _collection(s, c.arg(0, 'collection'));
        final file = File(c.arg(1, 'file'));
        if (!file.existsSync()) throw ToolException('No file ${file.path}');
        final asset = await s.media.addMedia(
          collection,
          file.openRead(),
          name: file.uri.pathSegments.last,
          mimeType: c.option('type'),
        );
        s.out.writeln(
          'Added ${asset.hash} (${asset.mimeType}, ${asset.sizeBytes} bytes)\n'
          '${s.store.file(collection, asset.hash).path}',
        );
      },
      arguments: '<collection> <file>',
      options: (p) => p.addOption('type', help: 'MIME type if not detected.'),
    ),
    ActionCommand('list', 'List the media of a collection.', (c, s) async {
      final collection = await _collection(s, c.arg(0, 'collection'));
      s.table(
        ['hash', 'type', 'bytes', 'name'],
        [
          for (final a in await s.media.mediaOf(collection))
            [
              a.hash.value.substring(0, 16),
              a.mimeType,
              a.sizeBytes,
              a.originalName,
            ],
        ],
      );
    }, arguments: '<collection>'),
    ActionCommand(
      'delete',
      'Delete media; the file stays until tombstones are purged.',
      (c, s) async {
        final collection = await _collection(s, c.arg(0, 'collection'));
        final prefix = c.arg(1, 'hash').toLowerCase();
        final matches = [
          for (final a in await s.media.mediaOf(collection))
            if (a.hash.value.startsWith(prefix)) a,
        ];
        if (matches.length != 1) {
          throw ToolException(
            '"$prefix" matches ${matches.length} media files',
          );
        }
        await s.media.deleteMedia(collection, matches.single.hash);
      },
      arguments: '<collection> <hash>',
    ),
  ]),
];

Future<CollectionId> _collection(Session s, String input) async =>
    CollectionId.parse(
      await s.resolve('collections', input, label: 'collection'),
    );

Future<T?> _optional<T>(
  Session s,
  String table,
  String? input,
  T Function(String) parse,
) async => input == null ? null : parse(await s.resolve(table, input));

Future<Deck> _deck(Session s, String input) async {
  final id = DeckId.parse(await s.resolve('decks', input, label: 'deck'));
  return await s.repos.collections.deck(id) ??
      (throw ToolException('Deck $input is hidden or deleted'));
}

Future<Tag> _tag(Session s, String input) async {
  final id = TagId.parse(await s.resolve('tags', input, label: 'tag'));
  return await s.repos.tags.tag(id) ??
      (throw ToolException('Tag $input is hidden or deleted'));
}

Future<NoteType> _noteType(Session s, String input) async {
  final id = NoteTypeId.parse(
    await s.resolve('note_types', input, label: 'note type'),
  );
  return await s.repos.noteTypes.noteType(id) ??
      (throw ToolException('Note type $input is hidden or deleted'));
}

Future<Note> _note(Session s, String input) async {
  final id = NoteId.parse(await s.resolve('notes', input, label: 'note'));
  return await s.repos.notes.note(id) ??
      (throw ToolException('Note $input is hidden or deleted'));
}

Future<StudyCardId> _card(Session s, String input) async =>
    StudyCardId.parse(await s.resolve('study_cards', input, label: 'card'));

/// Parses `Name=value` arguments against [type]'s fields, ignoring case.
Map<FieldDefinitionId, String> _parseFields(NoteType type, List<String> args) {
  final fields = <FieldDefinitionId, String>{};
  for (final arg in args) {
    final split = arg.indexOf('=');
    if (split < 1) throw ToolException('Expected Field=value, got "$arg"');
    final name = arg.substring(0, split).toLowerCase();
    final field = type.fields.where((f) => f.name.toLowerCase() == name);
    if (field.isEmpty) {
      throw ToolException(
        '${type.name} has no field "${arg.substring(0, split)}"; it has '
        '${type.fields.map((f) => f.name).join(', ')}',
      );
    }
    fields[field.single.id] = arg.substring(split + 1);
  }
  return fields;
}

Future<void> _addCollection(ActionCommand c, Session s) async {
  final collection = Collection(
    id: CollectionId.generate(),
    name: c.arg(0, 'name'),
  );
  await s.repos.collections.createCollection(collection);
  if (!c.flag('empty')) {
    await s.repos.collections.createDeck(
      Deck(id: DeckId.generate(), collectionId: collection.id, name: 'Default'),
    );
    await s.repos.noteTypes.createNoteType(
      NoteType(
        id: NoteTypeId.generate(),
        collectionId: collection.id,
        name: 'Basic',
        fields: [
          FieldDefinition(id: FieldDefinitionId.generate(), name: 'Front'),
          FieldDefinition(id: FieldDefinitionId.generate(), name: 'Back'),
        ],
        templates: [
          StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'Card 1'),
        ],
      ),
    );
  }
  s.out.writeln('Created collection ${short(collection.id)}.');
}

Future<void> _addNote(ActionCommand c, Session s) async {
  final collection = await _collection(s, c.arg(0, 'collection'));
  final types = await s.repos.noteTypes.noteTypes(collection);
  final type = switch (c.option('type')) {
    final name? => await _noteType(s, name),
    null when types.length == 1 => types.single,
    null => throw ToolException(
      'Pass --type: ${types.map((t) => t.name).join(', ')}',
    ),
  };
  final decks = await s.repos.collections.decks(collection);
  final deck = switch (c.option('deck')) {
    final name? => await _deck(s, name),
    null when decks.length == 1 => decks.single,
    null => throw ToolException(
      'Pass --deck: ${decks.map((d) => d.name).join(', ')}',
    ),
  };
  final note = Note(
    id: NoteId.generate(),
    collectionId: collection,
    noteTypeId: type.id,
    fields: _parseFields(type, c.argsFrom(1)),
    source: SourceAttribution(kind: SourceKind.manual),
  );
  await s.repos.notes.createNote(note);
  for (final template in type.templates) {
    await s.repos.cards.createCard(
      StudyCard(noteId: note.id, templateId: template.id, deckId: deck.id),
    );
  }
  for (final tag in c.argResults!['tag'] as List<String>) {
    await s.repos.notes.addTag(note.id, (await _tag(s, tag)).id);
  }
  s.out.writeln(
    'Created note ${short(note.id)} with ${type.templates.length} '
    '${type.templates.length == 1 ? 'card' : 'cards'} in '
    '${deck.name}.',
  );
}
