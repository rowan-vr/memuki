import 'package:flutter/foundation.dart';

import '../../domain/content/content_node.dart';

/// The content of a field being edited, with one history of undo for all of
/// it: the text wherever it is, and the blocks put in, changed, and taken out.
class FieldController extends ChangeNotifier {
  FieldController(List<ContentNode> nodes) : _nodes = nodes {
    _history.add(nodes);
  }

  List<ContentNode> _nodes;

  /// The content being edited.
  List<ContentNode> get nodes => _nodes;

  /// Replaces the content, as one step of undo.
  set nodes(List<ContentNode> nodes) => edit(nodes);

  /// States to undo to; [_at] is the current one.
  final _history = <List<ContentNode>>[];
  var _at = 0;

  /// What the last edit said it continues, so that typing a word is one
  /// step of undo.
  Object? _lastMerge;

  static const _historyLimit = 200;

  /// Changes the content. An edit with the same non-null [merge] as the one
  /// before it joins its step of undo.
  void edit(List<ContentNode> nodes, {Object? merge}) {
    if (listEquals(nodes, _nodes)) return;
    _nodes = nodes;
    _history.removeRange(_at + 1, _history.length);
    if (merge != null && merge == _lastMerge && _at > 0) {
      _history[_at] = nodes;
    } else {
      _history.add(nodes);
      if (_history.length > _historyLimit) _history.removeAt(0);
      _at = _history.length - 1;
    }
    _lastMerge = merge;
    notifyListeners();
  }

  bool get canUndo => _at > 0;
  bool get canRedo => _at < _history.length - 1;

  void undo() {
    if (!canUndo) return;
    _at--;
    _restore();
  }

  void redo() {
    if (!canRedo) return;
    _at++;
    _restore();
  }

  void _restore() {
    _nodes = _history[_at];
    _lastMerge = null;
    notifyListeners();
  }
}
