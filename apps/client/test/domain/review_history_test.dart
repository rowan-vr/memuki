import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/review_history.dart';

void main() {
  final cardId = StudyCardId.derive(
    NoteId.generate(),
    StudyCardTemplateId.generate(),
  );
  var minute = 0;

  ReviewEvent event({ReviewEventKind? kind, ReviewEvent? undoes}) =>
      ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: cardId,
        kind:
            kind ??
            (undoes == null ? ReviewEventKind.review : ReviewEventKind.undo),
        at: DateTime.utc(2026, 10, 29, 12, minute++),
        utcOffset: Duration.zero,
        stateBefore: StudyCardState.newCard,
        grade: kind == null && undoes == null ? Grade.good : null,
        undoneEventId: undoes?.id,
        schedulerId: 'test.fake',
        schedulerVersion: 1,
        presetVersionId: PresetVersionId.generate(),
      );

  test('without undos every action is in effect', () {
    final review = event();
    final burn = event(kind: ReviewEventKind.burn);
    final history = ReviewHistory([review, burn]);
    expect(history.actions, [review, burn]);
    expect(history.undoable, burn);
    expect(history.redoable, isNull);
  });

  test('an empty history has nothing to undo or redo', () {
    final history = ReviewHistory([]);
    expect(history.actions, isEmpty);
    expect(history.undoable, isNull);
    expect(history.redoable, isNull);
  });

  test('each level of undo toggles the event', () {
    final review = event();
    final undo = event(undoes: review);
    final redo = event(undoes: undo);
    final undoRedo = event(undoes: redo);
    expect(ReviewHistory([review, undo]).actions, isEmpty);
    expect(ReviewHistory([review, undo, redo]).actions, [review]);
    expect(ReviewHistory([review, undo, redo, undoRedo]).actions, isEmpty);
  });

  test('undo and redo walk back and forth through the history', () {
    final r1 = event();
    final r2 = event();
    final u1 = event(undoes: r2);
    final u2 = event(undoes: r1);
    final u3 = event(undoes: u2);
    final u4 = event(undoes: u1);
    final u5 = event(undoes: r2);

    var history = ReviewHistory([r1, r2, u1]);
    expect(history.actions, [r1]);
    expect(history.undoable, r1);
    expect(history.redoable, u1);

    history = ReviewHistory([r1, r2, u1, u2]);
    expect(history.actions, isEmpty);
    expect(history.undoable, isNull);
    expect(history.redoable, u2);

    history = ReviewHistory([r1, r2, u1, u2, u3]);
    expect(history.actions, [r1]);
    expect(history.redoable, u1);

    history = ReviewHistory([r1, r2, u1, u2, u3, u4]);
    expect(history.actions, [r1, r2]);
    expect(history.undoable, r2);
    expect(history.redoable, isNull);

    // Undoing again after a redo refers to the action itself.
    history = ReviewHistory([r1, r2, u1, u2, u3, u4, u5]);
    expect(history.actions, [r1]);
    expect(history.redoable, u5);
  });

  test('a new action ends what can be redone', () {
    final r1 = event();
    final undo = event(undoes: r1);
    final r2 = event();
    final history = ReviewHistory([r1, undo, r2]);
    expect(history.actions, [r2]);
    expect(history.undoable, r2);
    expect(history.redoable, isNull);
  });

  test('redos are not redone', () {
    final review = event();
    final undo = event(undoes: review);
    final redo = event(undoes: undo);
    expect(ReviewHistory([review, undo, redo]).redoable, isNull);
  });

  test('the result does not depend on the order of the events', () {
    final review = event();
    final undo = event(undoes: review);
    final redo = event(undoes: undo);
    expect(ReviewHistory([redo, undo, review]).actions, [review]);
  });
}
