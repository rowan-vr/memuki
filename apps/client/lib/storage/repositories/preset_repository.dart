import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/invariants.dart';
import '../../domain/preset.dart';
import '../converters.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import '../sync/hlc.dart';
import 'repository_exceptions.dart';
import 'tree_queries.dart';
import 'visibility.dart';

/// Presets and their versions, and which preset applies to a deck.
class PresetRepository {
  PresetRepository(this._db) : _changes = ChangeRecorder(_db);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;

  Future<Preset?> preset(PresetId id) async {
    final row = await _presetRow(id);
    return row == null ? null : _preset(row);
  }

  /// All presets of a collection, by name.
  Future<List<Preset>> presets(CollectionId collectionId) async {
    final rows =
        await (_db.select(_db.presets)
              ..where(
                (p) =>
                    p.collectionId.equalsValue(collectionId) &
                    _db.isVisiblePreset(p.id),
              )
              ..orderBy([(p) => OrderingTerm(expression: p.name)]))
            .get();
    return [for (final row in rows) await _preset(row)];
  }

  /// The preset of the collection's root decks without their own.
  Future<Preset> defaultPreset(CollectionId collectionId) async {
    final collection =
        await (_db.select(_db.collections)..where(
              (c) =>
                  c.id.equalsValue(collectionId) &
                  _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
    if (collection == null) {
      throw EntityNotFoundException('Collection $collectionId does not exist');
    }
    return (await preset(collection.defaultPresetId))!;
  }

  /// The preset that applies to a deck: its own, else the nearest parent's,
  /// else the collection's default. Deleted presets are skipped.
  Future<Preset> effectivePreset(DeckId deckId) async {
    final deck =
        await (_db.select(
              _db.decks,
            )..where((d) => d.id.equalsValue(deckId) & _db.isVisibleDeck(d.id)))
            .getSingleOrNull();
    if (deck == null) {
      throw EntityNotFoundException('Deck $deckId does not exist');
    }
    final row = await _db
        .customSelect(
          'WITH RECURSIVE up(id, parent_id, preset_id, depth) AS ('
          ' SELECT id, parent_id, preset_id, 0 FROM decks WHERE id = ?1'
          ' UNION ALL'
          ' SELECT d.id, d.parent_id, d.preset_id, u.depth + 1'
          ' FROM decks d JOIN up u ON d.id = u.parent_id'
          ' WHERE u.depth < $maxTreeDepth'
          ') SELECT u.preset_id FROM up u'
          ' JOIN visible_presets p ON p.id = u.preset_id'
          ' ORDER BY u.depth LIMIT 1',
          variables: [Variable.withBlob(deckIdConverter.toSql(deckId))],
          readsFrom: {_db.decks, _db.presets},
        )
        .getSingleOrNull();
    if (row == null) return defaultPreset(deck.collectionId);
    return (await preset(
      presetIdConverter.fromSql(row.read<Uint8List>('preset_id')),
    ))!;
  }

  /// The settings of a version, including versions of deleted presets, so
  /// every review event can be replayed.
  Future<PresetVersion?> version(PresetVersionId id) async {
    final row = await (_db.select(
      _db.presetVersions,
    )..where((v) => v.id.equalsValue(id))).getSingleOrNull();
    return row == null ? null : _version(row);
  }

  /// Creates a preset with its first version.
  Future<void> createPreset(Preset preset) => _changes.write((hlc) async {
    final collection =
        await (_db.select(_db.collections)..where(
              (c) =>
                  c.id.equalsValue(preset.collectionId) &
                  _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
    if (collection == null) {
      throw EntityNotFoundException(
        'Collection ${preset.collectionId} does not exist',
      );
    }
    await insertPreset(_db, preset, hlc);
  });

  Future<void> renamePreset(PresetId id, String name) =>
      _changes.write((hlc) async {
        requireName(name, 'name');
        if (await _presetRow(id) == null) throw _notFound(id);
        await (_db.update(_db.presets)..where((p) => p.id.equalsValue(id)))
            .write(PresetsCompanion(name: Value(name), hlc: Value(hlc)));
      });

  /// Adds [version] to the preset and makes it current. Reviews recorded
  /// before keep the version they used.
  Future<void> updateSettings(
    PresetId id,
    PresetVersion version,
  ) => _changes.write((hlc) async {
    if (await _presetRow(id) == null) throw _notFound(id);
    await _insertVersion(_db, id, version, hlc);
    await (_db.update(_db.presets)..where((p) => p.id.equalsValue(id))).write(
      PresetsCompanion(currentVersionId: Value(version.id), hlc: Value(hlc)),
    );
  });

  /// Deletes a preset. Decks that used it use their parent's preset instead.
  /// The collection's default preset cannot be deleted.
  Future<void> deletePreset(PresetId id) => _changes.write((hlc) async {
    final row = await _presetRow(id);
    if (row == null) throw _notFound(id);
    final collection = await (_db.select(
      _db.collections,
    )..where((c) => c.id.equalsValue(row.collectionId))).getSingle();
    if (collection.defaultPresetId == id) {
      throw ProtectedEntityException(
        'Preset $id is the default of its collection',
      );
    }
    await (_db.update(_db.presets)..where((p) => p.id.equalsValue(id))).write(
      PresetsCompanion(deleted: const Value(true), hlc: Value(hlc)),
    );
  });

  Future<PresetRow?> _presetRow(PresetId id) =>
      (_db.select(_db.presets)
            ..where((p) => p.id.equalsValue(id) & _db.isVisiblePreset(p.id)))
          .getSingleOrNull();

  Future<Preset> _preset(PresetRow row) async => Preset(
    id: row.id,
    collectionId: row.collectionId,
    name: row.name,
    version: (await version(row.currentVersionId))!,
  );
}

/// Inserts a preset and its first version, stamped with [hlc]. Used by
/// [PresetRepository] and when a collection is created with its default
/// preset.
Future<void> insertPreset(MemukiDatabase db, Preset preset, Hlc hlc) async {
  await db
      .into(db.presets)
      .insert(
        PresetsCompanion.insert(
          id: preset.id,
          collectionId: preset.collectionId,
          name: preset.name,
          currentVersionId: preset.version.id,
          hlc: hlc,
        ),
      );
  await _insertVersion(db, preset.id, preset.version, hlc);
}

Future<void> _insertVersion(
  MemukiDatabase db,
  PresetId presetId,
  PresetVersion version,
  Hlc hlc,
) => db
    .into(db.presetVersions)
    .insert(
      PresetVersionsCompanion.insert(
        id: version.id,
        presetId: presetId,
        schedulerId: version.schedulerId,
        schedulerConfig: version.schedulerConfig,
        burnThresholdDays: Value(version.burnThreshold?.inDays),
        leechThreshold: Value(version.leechThreshold),
        newCardsPerDay: version.newCardsPerDay,
        reviewsPerDay: version.reviewsPerDay,
        newCardMix: version.newCardMix,
        newCardOrder: version.newCardOrder,
        buryNewSiblings: Value(version.buryNewSiblings),
        buryReviewSiblings: Value(version.buryReviewSiblings),
        buryLearningSiblings: Value(version.buryLearningSiblings),
        hlc: hlc,
      ),
    );

PresetVersion _version(PresetVersionRow row) => PresetVersion(
  id: row.id,
  schedulerId: row.schedulerId,
  schedulerConfig: row.schedulerConfig,
  burnThreshold: row.burnThresholdDays == null
      ? null
      : Duration(days: row.burnThresholdDays!),
  leechThreshold: row.leechThreshold,
  newCardsPerDay: row.newCardsPerDay,
  reviewsPerDay: row.reviewsPerDay,
  newCardMix: row.newCardMix,
  newCardOrder: row.newCardOrder,
  buryNewSiblings: row.buryNewSiblings,
  buryReviewSiblings: row.buryReviewSiblings,
  buryLearningSiblings: row.buryLearningSiblings,
);

EntityNotFoundException _notFound(PresetId id) =>
    EntityNotFoundException('Preset $id does not exist');
