import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'collection.freezed.dart';

// Entities validate their own invariants in a private `._()` constructor. The
// generated class calls it after its fields are set, so construction and
// `copyWith` both reject invalid values. Invariants that need other entities
// (such as a parent deck being in the same collection) are enforced by
// repositories.

/// A user's top-level container. Collections are the unit of sync and sharing.
@freezed
abstract class Collection with _$Collection {
  Collection._() {
    requireName(name, 'name');
    if (dayStart.isNegative ||
        dayStart >= const Duration(days: 1) ||
        dayStart.inMicroseconds % Duration.microsecondsPerMinute != 0) {
      throw ArgumentError.value(
        dayStart,
        'dayStart',
        'must be whole minutes within one day',
      );
    }
  }

  factory Collection({
    required CollectionId id,
    required String name,

    /// The local time of day at which a study day starts.
    @Default(Duration(hours: 3)) Duration dayStart,
  }) = _Collection;
}

/// A deck within a collection. Decks can be nested through [parentId].
@freezed
abstract class Deck with _$Deck {
  Deck._() {
    requireName(name, 'name');
    if (parentId == id) {
      throw ArgumentError.value(
        parentId,
        'parentId',
        'must not be the deck itself',
      );
    }
  }

  factory Deck({
    required DeckId id,
    required CollectionId collectionId,
    DeckId? parentId,
    required String name,

    /// The deck's own preset, or null to use its parent's (for a root deck,
    /// the collection's default preset).
    PresetId? presetId,
  }) = _Deck;
}
