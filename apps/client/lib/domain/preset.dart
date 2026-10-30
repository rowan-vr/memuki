import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'preset.freezed.dart';

/// Scheduling settings shared by decks. A deck without a preset of its own
/// uses its parent's; a root deck without one uses the collection's default
/// preset.
///
/// Settings are versioned: editing them adds a [PresetVersion] and makes it
/// current, and review events record the version they used.
@freezed
abstract class Preset with _$Preset {
  Preset._() {
    requireName(name, 'name');
  }

  factory Preset({
    required PresetId id,
    required CollectionId collectionId,
    required String name,
    required PresetVersion version,
  }) = _Preset;
}

/// Where new cards go among the day's reviews. Learning cards that are due
/// always come first.
enum NewCardMix {
  /// New cards are spread evenly among the reviews.
  mixed,

  /// New cards come after all due reviews.
  reviewsFirst,

  /// New cards come before the due reviews.
  newFirst,
}

/// The order in which new cards are introduced.
enum NewCardOrder {
  /// Oldest note first, and a note's cards in template order.
  created,

  /// Shuffled, in the same order for the whole study day.
  random,
}

/// How long studying a learning or relearning card keeps the note's other
/// new and review cards out of the queue.
enum LearningSiblingBury {
  /// For the rest of the study day, like studying a new or review card.
  day,

  /// For the rest of the study session in which it was studied.
  session,

  /// Not at all.
  never,
}

/// One immutable version of a preset's settings.
@freezed
abstract class PresetVersion with _$PresetVersion {
  PresetVersion._() {
    if (burnThreshold case final threshold?
        when threshold < const Duration(days: 1) ||
            threshold.inMicroseconds % Duration.microsecondsPerDay != 0) {
      throw ArgumentError.value(
        burnThreshold,
        'burnThreshold',
        'must be whole days, at least one',
      );
    }
    if (leechThreshold case final threshold? when threshold < 1) {
      throw ArgumentError.value(
        threshold,
        'leechThreshold',
        'must be positive',
      );
    }
    if (newCardsPerDay < 0 || reviewsPerDay < 0) {
      throw ArgumentError('Daily limits must not be negative');
    }
  }

  factory PresetVersion({
    required PresetVersionId id,
    @Default('memuki.steps-sm2') String schedulerId,

    /// The scheduler's own settings, decoded by the scheduler.
    @Default(<String, Object?>{}) Map<String, Object?> schedulerConfig,

    /// Graduated cards whose next interval reaches this are burned. Null
    /// disables burning.
    @Default(Duration(days: 365)) Duration? burnThreshold,

    /// Lapses at which a card becomes a leech. Null disables leeches.
    @Default(8) int? leechThreshold,
    @Default(50) int newCardsPerDay,

    /// The limit on cards in review falling due; learning and relearning
    /// cards are not limited.
    @Default(500) int reviewsPerDay,
    @Default(NewCardMix.mixed) NewCardMix newCardMix,
    @Default(NewCardOrder.created) NewCardOrder newCardOrder,

    /// Whether studying a new or review card keeps the note's other new cards
    /// out of the day's queue.
    @Default(true) bool buryNewSiblings,

    /// Whether studying a new or review card keeps the note's other review
    /// cards out of the day's queue.
    @Default(true) bool buryReviewSiblings,

    /// How long studying a learning card buries its siblings.
    @Default(LearningSiblingBury.session)
    LearningSiblingBury buryLearningSiblings,
  }) = _PresetVersion;
}
