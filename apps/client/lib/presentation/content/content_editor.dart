import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/marked_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'block_editing.dart';
import 'content_view.dart';
import 'field_editor_scope.dart';
import 'inline_editor.dart';
import 'marked_text_controller.dart';

/// Edits content in a field editor as text, with its marks, and blocks
/// between, each in the editor its `BlockEditing` gives it. Blocks of
/// [accepts] dragged from the toolbox can be dropped between the parts, or
/// put in at the cursor.
///
/// Whitespace beside a block only lays out the source, so it is not shown,
/// and blocks are written on lines of their own.
class ContentEditor extends StatefulWidget {
  const ContentEditor({
    super.key,
    required this.nodes,
    required this.onChanged,
    this.accepts = const {},
    this.text = true,
    this.hint,
    this.autofocus = false,
    this.style,
    this.onEnter,
    this.kept = const {},
  });

  final List<ContentNode> nodes;
  final ContentChanged onChanged;

  /// The kinds of block that may be put in.
  final Set<String> accepts;

  /// Whether there is a line to type on after the last block, or when there
  /// is nothing.
  final bool text;

  final String? hint;
  final bool autofocus;
  final TextStyle? style;

  /// Called on Enter, which then does not start a new line.
  final VoidCallback? onEnter;

  /// The kinds of block that cannot be removed, such as a sense's list.
  final Set<String> kept;

  @override
  State<ContentEditor> createState() => _ContentEditorState();
}

/// A part of the content: a run of text, or a block. Each has an [id] that
/// lasts while it does, to keep its editor.
sealed class _Part {
  _Part(this.id);

  final int id;
}

class _TextPart extends _Part {
  _TextPart(super.id, this.controller);

  final MarkedTextController controller;
}

class _BlockPart extends _Part {
  _BlockPart(super.id, this.mark);

  MarkNode mark;
}

class _ContentEditorState extends State<ContentEditor> {
  late FieldSession _session;
  var _parts = <_Part>[];
  var _nextId = 0;

  /// The content as last written to [ContentEditor.onChanged] or read from
  /// [ContentEditor.nodes], to tell changes from elsewhere, such as undo,
  /// from the editor's own.
  List<ContentNode>? _known;

  /// Set while the parts are being changed to match the content, so that
  /// their changes are not taken for edits.
  var _syncing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = FieldSessionScope.of(context);
    if (_known == null) {
      _session = session;
      _load(widget.nodes);
    }
  }

  @override
  void didUpdateWidget(ContentEditor old) {
    super.didUpdateWidget(old);
    if (!listEquals(widget.nodes, _known)) _sync(widget.nodes);
  }

  @override
  void dispose() {
    _disposeParts(_parts);
    super.dispose();
  }

  void _disposeParts(Iterable<_Part> parts) {
    for (final p in parts) {
      if (p case _TextPart(:final controller)) controller.dispose();
    }
  }

  /// [nodes] as runs of text and the blocks between them, with the
  /// whitespace beside blocks left out.
  List<(List<ContentNode>?, MarkNode?)> _split(List<ContentNode> nodes) {
    final out = <(List<ContentNode>?, MarkNode?)>[];
    var run = <ContentNode>[];
    void flush({required bool beforeBlock}) {
      final trimmed = _trimmed(run, start: out.isNotEmpty, end: beforeBlock);
      if (trimmed.isNotEmpty) out.add((trimmed, null));
      run = [];
    }

    for (final node in nodes) {
      if (node is MarkNode && _session.isBlock(node)) {
        flush(beforeBlock: true);
        out.add((null, node));
      } else {
        run.add(node);
      }
    }
    flush(beforeBlock: false);
    if (widget.text && (out.isEmpty || out.last.$2 != null)) {
      out.add((const [], null));
    }
    return out;
  }

  /// [run] without the whitespace at its [start] or [end].
  static List<ContentNode> _trimmed(
    List<ContentNode> run, {
    required bool start,
    required bool end,
  }) {
    final out = [...run];
    if (out.firstOrNull case TextNode(:final text) when start) {
      final t = text.trimLeft();
      t.isEmpty ? out.removeAt(0) : out[0] = ContentNode.text(t);
    }
    if (out.lastOrNull case TextNode(:final text) when end) {
      final t = text.trimRight();
      t.isEmpty ? out.removeLast() : out[out.length - 1] = ContentNode.text(t);
    }
    return out;
  }

  _TextPart _textPart(List<ContentNode> nodes) {
    final controller = MarkedTextController(nodes, editing: _session.editing);
    final part = _TextPart(_nextId++, controller);
    var last = controller.nodes;
    controller.addListener(() {
      if (_syncing) return;
      final now = controller.nodes;
      if (listEquals(now, last)) return;
      last = now;
      _emit(merge: (controller, controller.steps));
    });
    return part;
  }

  void _load(List<ContentNode> nodes) {
    _known = nodes;
    _parts = [
      for (final (text, block) in _split(nodes))
        if (block != null) _BlockPart(_nextId++, block) else _textPart(text!),
    ];
  }

  /// Matches the parts to [nodes]: in place when they have the same shape,
  /// so that editors keep their focus, or else afresh.
  void _sync(List<ContentNode> nodes) {
    final split = _split(nodes);
    final sameShape =
        split.length == _parts.length &&
        [
          for (final (i, (_, block)) in split.indexed)
            (block == null) == (_parts[i] is _TextPart),
        ].every((same) => same);
    if (!sameShape) {
      final old = _parts;
      setState(() => _load(nodes));
      _disposeParts(old);
      return;
    }
    _syncing = true;
    for (final (i, (text, block)) in split.indexed) {
      switch (_parts[i]) {
        case _TextPart(:final controller):
          if (!listEquals(controller.nodes, text)) controller.reset(text!);
        case final _BlockPart part:
          part.mark = block!;
      }
    }
    _syncing = false;
    _known = nodes;
  }

  /// The content of the parts, with blocks on lines of their own.
  List<ContentNode> get _nodes {
    final out = <ContentNode>[];
    void add(ContentNode node) {
      if ((out.lastOrNull, node) case (
        TextNode(text: final a),
        TextNode(text: final b),
      )) {
        out.last = ContentNode.text(a + b);
      } else {
        out.add(node);
      }
    }

    var afterBlock = false;
    for (final part in _parts) {
      switch (part) {
        case _TextPart(:final controller):
          final nodes = controller.nodes;
          if (nodes.isEmpty) continue;
          if (afterBlock) add(const ContentNode.text('\n'));
          nodes.forEach(add);
          afterBlock = false;
        case _BlockPart(:final mark):
          if (out.isNotEmpty) add(const ContentNode.text('\n'));
          add(mark);
          afterBlock = true;
      }
    }
    return out;
  }

  void _emit({Object? merge}) {
    final nodes = _nodes;
    _known = nodes;
    widget.onChanged(nodes, merge: merge);
  }

  /// Changes the parts' order or number, then writes the content.
  void _restructure(void Function(List<_Part> parts) change) {
    final before = {..._parts};
    final parts = [..._parts];
    change(parts);
    setState(() => _parts = parts);
    _disposeParts(before.difference({...parts}));
    _emit();
  }

  /// Puts [mark] in at [index] of the parts.
  void _insertAt(int index, MarkNode mark) =>
      _restructure((parts) => parts.insert(index, _BlockPart(_nextId++, mark)));

  /// Puts [mark] in at the cursor of [at], one of the parts' editors,
  /// splitting its text there, or at the end.
  void _insert(MarkNode mark, MarkedTextController? at) {
    final index = _parts.indexWhere(
      (p) => p is _TextPart && p.controller == at,
    );
    if (index < 0 || at == null) {
      final trailing =
          _parts.lastOrNull is _TextPart &&
          (_parts.last as _TextPart).controller.text.isEmpty;
      _insertAt(trailing ? _parts.length - 1 : _parts.length, mark);
      return;
    }
    final offset = at.selection.isValid ? at.selection.start : at.text.length;
    final (before, after) = MarkedText(at.text, at.ranges).splitAt(offset);
    _restructure((parts) {
      parts.removeAt(index);
      parts.insertAll(index, [
        if (before.text.isNotEmpty) _textPart(before.toNodes()),
        _BlockPart(_nextId++, mark),
        if (after.text.isNotEmpty) _textPart(after.toNodes()),
      ]);
      if (widget.text && parts.last is _BlockPart) parts.add(_textPart([]));
    });
  }

  void _changeBlock(_BlockPart part, MarkNode mark, {Object? merge}) {
    part.mark = mark;
    _emit(merge: merge);
  }

  void _remove(_Part part) => _restructure((parts) {
    final i = parts.indexOf(part);
    parts.removeAt(i);
    // Join the text that was on either side of it.
    if ((i > 0 ? parts[i - 1] : null, parts.elementAtOrNull(i)) case (
      _TextPart(controller: final a),
      _TextPart(controller: final b),
    )) {
      parts[i - 1] = _textPart([
        ...a.nodes,
        if (a.text.isNotEmpty && b.text.isNotEmpty)
          const ContentNode.text('\n'),
        ...b.nodes,
      ]);
      parts.removeAt(i);
    }
    if (widget.text && (parts.isEmpty || parts.last is _BlockPart)) {
      parts.add(_textPart([]));
    }
  });

  BlockContainer _container(BlockContainer? parent) => BlockContainer(
    accepts: widget.accepts.contains,
    insert: _insert,
    parent: parent,
  );

  @override
  Widget build(BuildContext context) {
    final parent = BlockContainerScope.of(context);
    final container = _container(parent);
    if (parent == null) _session.root = container;
    final first = _parts.indexWhere((p) => p is _TextPart);
    return BlockContainerScope(
      container: container,
      child: ValueListenableBuilder(
        valueListenable: _session.dragging,
        builder: (context, dragging, _) {
          final dropping =
              dragging != null && widget.accepts.contains(dragging);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, part) in _parts.indexed) ...[
                if (dropping) _DropZone(onDrop: (mark) => _insertAt(i, mark)),
                switch (part) {
                  _TextPart(:final controller) => InlineEditor(
                    key: ValueKey(part.id),
                    controller: controller,
                    hint: widget.hint,
                    style: widget.style,
                    autofocus: widget.autofocus && i == first,
                    onEnter: widget.onEnter,
                  ),
                  _BlockPart() => _BlockFrame(
                    key: ValueKey(part.id),
                    mark: part.mark,
                    onRemove: widget.kept.contains(part.mark.key)
                        ? null
                        : () => _remove(part),
                    child: _blockEditor(
                      context,
                      part.mark,
                      onChanged: (mark, {merge}) =>
                          _changeBlock(part, mark, merge: merge),
                      onRemove: () => _remove(part),
                    ),
                  ),
                },
              ],
              if (dropping)
                _DropZone(onDrop: (mark) => _insertAt(_parts.length, mark)),
            ],
          );
        },
      ),
    );
  }

  /// The editor of [mark] from its entry, or its source when the entry has
  /// none.
  Widget _blockEditor(
    BuildContext context,
    MarkNode mark, {
    Key? key,
    required MarkChanged onChanged,
    required VoidCallback onRemove,
  }) {
    final build = _session.blocks[mark.key]?.editor;
    if (build == null) {
      return _SourceEditor(key: key, mark: mark, onChanged: onChanged);
    }
    return KeyedSubtree(
      key: key,
      child: Builder(
        builder: (context) => build(
          context,
          BlockEditorContext(
            mark: mark,
            onChanged: onChanged,
            onRemove: onRemove,
            create: _session.create,
            contentBuilder:
                (
                  nodes,
                  onChanged, {
                  key,
                  accepts = const {},
                  text = true,
                  hint,
                  autofocus = false,
                  style,
                  onEnter,
                  kept = const {},
                }) => ContentEditor(
                  key: key,
                  nodes: nodes,
                  onChanged: onChanged,
                  accepts: accepts,
                  text: text,
                  hint: hint,
                  autofocus: autofocus,
                  style: style,
                  onEnter: onEnter,
                  kept: kept,
                ),
            childBuilder:
                (mark, {key, required onChanged, required onRemove}) =>
                    _blockEditor(
                      context,
                      mark,
                      key: key,
                      onChanged: onChanged,
                      onRemove: onRemove,
                    ),
          ),
        ),
      ),
    );
  }
}

/// Where a block being dragged from the toolbox can be dropped, lit while
/// it is over it.
class _DropZone extends StatelessWidget {
  const _DropZone({required this.onDrop});

  final ValueChanged<MarkNode> onDrop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final session = FieldSessionScope.of(context);
    return DragTarget<ToolboxDrag>(
      onAcceptWithDetails: (details) {
        if (session.create(details.data.key) case final mark?) onDrop(mark);
      },
      builder: (context, candidates, _) => SizedBox(
        height: Spacing.md,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: candidates.isEmpty ? 1 : 3,
            decoration: BoxDecoration(
              color: candidates.isEmpty ? colors.border : colors.accent.base,
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
          ),
        ),
      ),
    );
  }
}

/// A block in the editor: its name and, unless it is kept, a button to
/// remove it, over its editor.
class _BlockFrame extends StatelessWidget {
  const _BlockFrame({
    super.key,
    required this.mark,
    required this.onRemove,
    required this.child,
  });

  final MarkNode mark;
  final VoidCallback? onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final l10n = AppLocalizations.of(context);
    final entry = FieldSessionScope.of(context).blocks[mark.key];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      padding: const EdgeInsetsDirectional.fromSTEB(
        Spacing.sm,
        Spacing.xs,
        Spacing.xs,
        Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (entry?.icon case final icon?) ...[
                Icon(icon, size: 14, color: colors.textFaint),
                const SizedBox(width: Spacing.xs),
              ],
              Expanded(
                child: Text(
                  entry?.label(l10n) ?? mark.key,
                  style: type.caption.copyWith(color: colors.textFaint),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: l10n.editorRemoveMark,
                  visualDensity: VisualDensity.compact,
                  iconSize: 16,
                  color: colors.textFaint,
                  icon: const Icon(MemukiIcons.close),
                  onPressed: onRemove,
                )
              else
                // As tall as the button, so headers match.
                SizedBox(
                  height:
                      kMinInteractiveDimension +
                      VisualDensity.compact.baseSizeAdjustment.dy,
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// A block whose kind has no editor, as it renders; pressed, its source.
/// Source that reads as one mark replaces it; anything else waits until it
/// does.
class _SourceEditor extends StatefulWidget {
  const _SourceEditor({super.key, required this.mark, required this.onChanged});

  final MarkNode mark;
  final MarkChanged onChanged;

  @override
  State<_SourceEditor> createState() => _SourceEditorState();
}

class _SourceEditorState extends State<_SourceEditor> {
  TextEditingController? _source;

  @override
  void dispose() {
    _source?.dispose();
    super.dispose();
  }

  void _changed(String source) {
    final parsed = parseContent(source);
    if (parsed.problems.isNotEmpty) return;
    if (parsed.nodes case [final MarkNode mark]) {
      widget.onChanged(mark, merge: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final l10n = AppLocalizations.of(context);
    final source = _source;
    if (source == null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(
          () => _source = TextEditingController(
            text: writeContent([widget.mark]),
          ),
        ),
        child: ContentView([widget.mark], style: type.body),
      );
    }
    return TextField(
      controller: source,
      autofocus: true,
      minLines: 2,
      maxLines: 8,
      onChanged: _changed,
      style: type.body.copyWith(
        fontFamily: 'monospace',
        fontFamilyFallback: const [MemukiType.bodyFamily],
      ),
      decoration: InputDecoration(
        labelText: l10n.editorSource,
        isDense: true,
        filled: true,
        fillColor: colors.surfaceSunken,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
