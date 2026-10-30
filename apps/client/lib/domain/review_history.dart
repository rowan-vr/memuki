import 'ids.dart';
import 'review.dart';

/// A card's review history, resolved into the events that are in effect.
///
/// An undo event cancels the event it refers to. An event is in effect
/// unless an undo that is itself in effect refers to it, so undoing an undo
/// restores the original event: a redo. An undo can only refer to an event
/// that already exists, so chains always end, and the result does not depend
/// on the order in which events from different devices arrive.
///
/// Undo and redo work as a stack: an undo cancels the latest action in
/// effect, and a redo cancels the latest undo of an action, as long as no
/// action was recorded after it. So a chain is never deeper than a redo of an
/// undo of an action.
final class ReviewHistory {
  ReviewHistory(Iterable<ReviewEvent> events)
    : events = List.unmodifiable(events) {
    for (final event in this.events) {
      _byId[event.id] = event;
      if (event.undoneEventId case final target?) {
        (_undos[target] ??= []).add(event);
      }
    }
  }

  /// The card's events in the order they happened.
  final List<ReviewEvent> events;

  final _byId = <ReviewEventId, ReviewEvent>{};
  final _undos = <ReviewEventId, List<ReviewEvent>>{};
  final _inEffect = <ReviewEventId, bool>{};

  /// Whether no undo in effect refers to [event].
  bool isInEffect(ReviewEvent event) =>
      _inEffect[event.id] ??= !(_undos[event.id] ?? const []).any(isInEffect);

  /// The reviews, burns, and unburns in effect, in order. Replaying them
  /// gives the card's scheduling state.
  late final List<ReviewEvent> actions = [
    for (final event in events)
      if (event.kind != ReviewEventKind.undo && isInEffect(event)) event,
  ];

  /// The event that an undo would cancel: the latest action in effect.
  ReviewEvent? get undoable => actions.lastOrNull;

  /// The event that a redo would cancel: the latest undo of an action that
  /// is in effect, if only undos and redos were recorded after it.
  ReviewEvent? get redoable {
    for (final event in events.reversed) {
      if (event.kind != ReviewEventKind.undo) return null;
      if (isInEffect(event) && !_isRedo(event)) return event;
    }
    return null;
  }

  bool _isRedo(ReviewEvent undo) =>
      _byId[undo.undoneEventId]?.kind == ReviewEventKind.undo;
}
