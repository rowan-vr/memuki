import 'package:flutter/widgets.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/mark_kinds.dart';
import 'block_editing.dart';
import 'field_controller.dart';
import 'mark_editing.dart';
import 'marked_text_controller.dart';

/// A text editor in a field that the toolbar can work on.
abstract interface class InlineTarget {
  MarkedTextController get controller;

  /// Toggles [kind] over the selection, or puts it in at the cursor.
  void apply(MarkKind kind);

  /// Where blocks put in from the toolbox while editing here go first.
  BlockContainer? get container;
}

/// A place blocks can be put in: a field's top level, or the content of a
/// block. Blocks of kinds it does not [accepts] go to its [parent].
@immutable
class BlockContainer {
  const BlockContainer({
    required this.accepts,
    required this.insert,
    this.parent,
  });

  final bool Function(String key) accepts;

  /// Puts [mark] in at the cursor of [at], when that is one of its own text
  /// editors, or else at the end.
  final void Function(MarkNode mark, MarkedTextController? at) insert;

  final BlockContainer? parent;

  /// The innermost of this and its parents that accepts [key].
  BlockContainer? accepting(String key) {
    BlockContainer? c = this;
    while (c != null && !c.accepts(key)) {
      c = c.parent;
    }
    return c;
  }
}

/// Provides the [BlockContainer] that editors inside it put blocks in.
class BlockContainerScope extends InheritedWidget {
  const BlockContainerScope({
    super.key,
    required this.container,
    required super.child,
  });

  final BlockContainer container;

  /// The innermost container around [context], without depending on it, as
  /// it is only read when blocks are put in.
  static BlockContainer? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<BlockContainerScope>()?.container;

  @override
  bool updateShouldNotify(BlockContainerScope old) => false;
}

/// What the editors in one field share: its history, its registries, the
/// text editor last focused, and the block being dragged in.
class FieldSession {
  FieldSession({
    required this.field,
    required this.kinds,
    required this.editing,
    required this.blocks,
  });

  final FieldController field;
  final MarkKinds kinds;
  final Map<String, MarkEditing> editing;
  final Map<String, BlockEditing> blocks;

  /// The text editor last focused, which the toolbar works on.
  final active = ValueNotifier<InlineTarget?>(null);

  /// The key of the block being dragged from the toolbox.
  final dragging = ValueNotifier<String?>(null);

  /// The field's top level, where blocks go when no text editor has been
  /// focused.
  BlockContainer? root;

  /// Whether [mark] stands on lines of its own and is edited by a block
  /// editor.
  bool isBlock(MarkNode mark) => blocks[mark.key]?.block ?? false;

  /// A new block of [key], or null when its kind creates none.
  MarkNode? create(String key) => blocks[key]?.create?.call();

  /// Where a new block of [key] would go: into the innermost place around
  /// the focused text editor that accepts it.
  BlockContainer? targetFor(String key) =>
      (active.value?.container ?? root)?.accepting(key);

  /// Puts in a new block of [key] where [targetFor] says, at the cursor when
  /// the focused text editor is that place's own. Returns whether it went
  /// in.
  bool insert(String key) {
    final target = targetFor(key);
    final mark = create(key);
    if (target == null || mark == null) return false;
    final active = this.active.value;
    target.insert(
      mark,
      identical(active?.container, target) ? active?.controller : null,
    );
    return true;
  }

  /// Lets go of [target], going away, if it is the [active] one. After the
  /// frame, as the tree is locked while it is taken down.
  void release(InlineTarget target) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed && active.value == target) active.value = null;
      });

  var _disposed = false;

  void dispose() {
    _disposed = true;
    active.dispose();
    dragging.dispose();
  }
}

/// Provides the [FieldSession] of the field editor around it.
class FieldSessionScope extends InheritedWidget {
  const FieldSessionScope({
    super.key,
    required this.session,
    required super.child,
  });

  final FieldSession session;

  static FieldSession of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FieldSessionScope>()!.session;

  @override
  bool updateShouldNotify(FieldSessionScope old) => old.session != session;
}
