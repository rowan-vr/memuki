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
  }

  factory Collection({required CollectionId id, required String name}) =
      _Collection;
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
  }) = _Deck;
}
