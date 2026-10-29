import 'package:drift/drift.dart';

import '../database.dart';

/// Checks against the views in `views.drift`, which decide whether a row is
/// visible from its own tombstone and those of its parents.
extension Visibility on MemukiDatabase {
  Expression<bool> isVisibleCollection(Expression<Uint8List> id) =>
      _isIn(id, visibleCollections, visibleCollections.id);

  Expression<bool> isVisibleDeck(Expression<Uint8List> id) =>
      _isIn(id, visibleDecks, visibleDecks.id);

  Expression<bool> isVisibleTag(Expression<Uint8List> id) =>
      _isIn(id, visibleTags, visibleTags.id);

  Expression<bool> isVisibleNoteType(Expression<Uint8List> id) =>
      _isIn(id, visibleNoteTypes, visibleNoteTypes.id);

  Expression<bool> isVisibleFieldDefinition(Expression<Uint8List> id) =>
      _isIn(id, visibleFieldDefinitions, visibleFieldDefinitions.id);

  Expression<bool> isVisibleTemplate(Expression<Uint8List> id) =>
      _isIn(id, visibleStudyCardTemplates, visibleStudyCardTemplates.id);

  Expression<bool> isVisibleNote(Expression<Uint8List> id) =>
      _isIn(id, visibleNotes, visibleNotes.id);

  Expression<bool> isVisibleCard(Expression<Uint8List> id) =>
      _isIn(id, visibleStudyCards, visibleStudyCards.id);

  Expression<bool> _isIn<V extends HasResultSet, R>(
    Expression<Uint8List> id,
    ResultSetImplementation<V, R> view,
    Expression<Uint8List> column,
  ) => id.isInQuery(selectOnly<V, R>(view)..addColumns([column]));
}
