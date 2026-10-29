import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/note.dart';
import '../converters.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';
import 'visibility.dart';

/// Tags of a collection. Tags are attached to notes through
/// `NoteRepository`.
class TagRepository {
  TagRepository(this._db)
    : _changes = ChangeRecorder(_db),
      _tagTree = TreeQueries(_db, _db.tags, tagIdConverter);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;
  final TreeQueries<TagId> _tagTree;

  Future<Tag?> tag(TagId id) async {
    final row = await _tagRow(id);
    return row == null ? null : _tag(row);
  }

  /// All tags of a collection, by name. Callers build the tree from
  /// [Tag.parentId].
  Future<List<Tag>> tags(CollectionId collectionId) =>
      _tagsQuery(collectionId).map(_tag).get();

  Stream<List<Tag>> watchTags(CollectionId collectionId) =>
      _tagsQuery(collectionId).map(_tag).watch();

  /// The IDs of [id] and all tags below it.
  Future<Set<TagId>> tagSubtree(TagId id) => _tagTree.subtree(id);

  /// Creates a tag. Its name must be unique among its siblings, ignoring
  /// case.
  Future<void> createTag(Tag tag) => _changes.write((hlc) async {
    final collection =
        await (_db.select(_db.collections)..where(
              (c) =>
                  c.id.equalsValue(tag.collectionId) &
                  _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
    if (collection == null) {
      throw EntityNotFoundException(
        'Collection ${tag.collectionId} does not exist',
      );
    }
    if (tag.parentId case final parentId?) {
      await _requireParent(tag.collectionId, parentId);
    }
    await _requireUniqueName(tag);
    await _db
        .into(_db.tags)
        .insert(
          TagsCompanion.insert(
            id: tag.id,
            collectionId: tag.collectionId,
            parentId: Value(tag.parentId),
            name: tag.name,
            hlc: hlc,
          ),
        );
  });

  /// Renames or moves a tag. Moving a tag below itself or one of its
  /// descendants is rejected.
  Future<void> updateTag(Tag tag) => _changes.write((hlc) async {
    final current = await _tagRow(tag.id);
    if (current == null) throw _tagNotFound(tag.id);
    if (current.collectionId != tag.collectionId) {
      throw CrossCollectionException(
        'Tag ${tag.id} cannot move to another collection',
      );
    }
    final parentId = tag.parentId;
    if (parentId != null && parentId != current.parentId) {
      await _requireParent(tag.collectionId, parentId);
      if ((await _tagTree.ancestors(parentId)).contains(tag.id)) {
        throw ParentCycleException('Tag $parentId is below tag ${tag.id}');
      }
    }
    await _requireUniqueName(tag);
    await (_db.update(_db.tags)..where((t) => t.id.equalsValue(tag.id))).write(
      TagsCompanion(
        parentId: Value(parentId),
        name: Value(tag.name),
        hlc: Value(hlc),
      ),
    );
  });

  /// Deletes a tag. The tags below it are hidden with it, and all of them
  /// disappear from notes.
  Future<void> deleteTag(TagId id) => _changes.write((hlc) async {
    if (await _tagRow(id) == null) throw _tagNotFound(id);
    await (_db.update(_db.tags)..where((t) => t.id.equalsValue(id))).write(
      TagsCompanion(deleted: const Value(true), hlc: Value(hlc)),
    );
  });

  Future<TagRow?> _tagRow(TagId id) =>
      (_db.select(_db.tags)
            ..where((t) => t.id.equalsValue(id) & _db.isVisibleTag(t.id)))
          .getSingleOrNull();

  Future<void> _requireParent(CollectionId collectionId, TagId parentId) async {
    final parent = await _tagRow(parentId);
    if (parent == null) throw _tagNotFound(parentId);
    if (parent.collectionId != collectionId) {
      throw CrossCollectionException(
        'Parent tag $parentId is in another collection',
      );
    }
  }

  /// Compares in Dart because SQLite's NOCASE only folds ASCII.
  Future<void> _requireUniqueName(Tag tag) async {
    final parentId = tag.parentId;
    final siblings =
        await (_db.select(_db.tags)..where(
              (t) =>
                  t.collectionId.equalsValue(tag.collectionId) &
                  (parentId == null
                      ? t.parentId.isNull()
                      : t.parentId.equalsValue(parentId)) &
                  t.id.equalsValue(tag.id).not() &
                  _db.isVisibleTag(t.id),
            ))
            .get();
    final name = tag.name.toLowerCase();
    if (siblings.any((s) => s.name.toLowerCase() == name)) {
      throw DuplicateNameException(
        'A sibling of tag ${tag.id} is already named "${tag.name}"',
      );
    }
  }

  SimpleSelectStatement<$TagsTable, TagRow> _tagsQuery(
    CollectionId collectionId,
  ) => _db.select(_db.tags)
    ..where(
      (t) => t.collectionId.equalsValue(collectionId) & _db.isVisibleTag(t.id),
    )
    ..orderBy([(t) => OrderingTerm(expression: t.name)]);
}

Tag _tag(TagRow row) => Tag(
  id: row.id,
  collectionId: row.collectionId,
  parentId: row.parentId,
  name: row.name,
);

EntityNotFoundException _tagNotFound(TagId id) =>
    EntityNotFoundException('Tag $id does not exist');
