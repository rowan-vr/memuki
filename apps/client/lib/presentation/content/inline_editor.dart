import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/mark_kinds.dart';
import '../../domain/content/marked_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/panel.dart';
import '../theme/app_theme.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'field_editor_scope.dart';
import 'mark_editing.dart';
import 'marked_text_controller.dart';

/// Edits text with its marks, in a field editor: the text of a field, or of
/// a block in it, such as a list item.
///
/// Marks are applied to the selection from the field's toolbar, the
/// selection menu, or a shortcut, and toggled off the same way; a kind
/// without content is put in at the cursor. Annotations, such as ruby
/// readings, are drawn above their text. While the cursor is in or beside a
/// mark with arguments, they are edited in a popover under it. Undo works on
/// the whole field.
class InlineEditor extends StatefulWidget {
  const InlineEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.hint,
    this.style,
    this.onEnter,
  });

  final MarkedTextController controller;
  final FocusNode? focusNode;

  /// Whether it takes focus when it first shows, or when this turns true,
  /// such as for a new list item.
  final bool autofocus;

  /// Shown while there is no text.
  final String? hint;

  /// The body text style by default.
  final TextStyle? style;

  /// Called on Enter, which then does not start a new line, as in a list
  /// item.
  final VoidCallback? onEnter;

  @override
  State<InlineEditor> createState() => _InlineEditorState();
}

class _InlineEditorState extends State<InlineEditor> implements InlineTarget {
  final _stack = GlobalKey();
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  final _argumentFocus = FocusNode();

  /// The popover for the arguments of the mark at the selection, and where
  /// it is anchored: under the mark, in the editor's coordinates.
  final _link = LayerLink();
  final _popover = OverlayPortalController();
  MarkRange? _argumentMark;
  Offset _anchor = Offset.zero;
  var _placing = false;
  var _focusArguments = false;

  late FieldSession _session;

  MarkedTextController get _c => widget.controller;

  @override
  MarkedTextController get controller => widget.controller;

  @override
  BlockContainer? get container => BlockContainerScope.of(context);

  MarkKinds get _allKinds => _session.kinds;

  @override
  void initState() {
    super.initState();
    _c.addListener(_track);
    _focus.addListener(_focused);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _popover.show();
      // Asked for rather than left to the text field, which only takes focus
      // when nothing else has it.
      if (widget.autofocus) _focus.requestFocus();
      // The toolbar works on the first editor until another is focused.
      _session.active.value ??= this;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session = FieldSessionScope.of(context);
  }

  @override
  void didUpdateWidget(InlineEditor old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_track);
      widget.controller.addListener(_track);
      _track();
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_focused);
      _focus.addListener(_focused);
    }
    // An editor kept for content that moved, such as a new list item put
    // in before the last, takes focus as a new one would.
    if (widget.autofocus && !old.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  void _focused() {
    if (_focus.hasFocus) _session.active.value = this;
  }

  /// Places the popover once the field has laid out the change.
  void _track() {
    if (_placing) return;
    _placing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _placing = false;
      if (mounted) _place();
    });
  }

  bool _hasArguments(MarkRange range) =>
      _allKinds[range.key ?? '']?.args.isNotEmpty ?? false;

  void _place() {
    final mark =
        _c.atomAtSelection(_hasArguments) ?? _c.markAtSelection(_hasArguments);
    var anchor = _anchor;
    final root = _stack.currentContext?.findRenderObject() as RenderBox?;
    final editable = root == null ? null : _editableIn(root);
    if (mark != null && root != null && editable != null) {
      final boxes = editable.getBoxesForSelection(
        TextSelection(baseOffset: mark.start, extentOffset: mark.end),
      );
      if (boxes.isNotEmpty) {
        // Under the part of the mark on its last line.
        final last = boxes.last;
        final onLine = boxes.where((b) => (b.top - last.top).abs() < 1);
        final left = onLine.map((b) => b.left).reduce((a, b) => a < b ? a : b);
        final at = editable.localToGlobal(
          Offset(left, last.bottom),
          ancestor: root,
        );
        final room = root.size.width - _popoverWidth(root.size.width);
        anchor = Offset(at.dx.clamp(0, room < 0 ? 0 : room), at.dy);
      }
    }
    if (mark == _argumentMark && anchor == _anchor && !_focusArguments) {
      return;
    }
    setState(() {
      _argumentMark = mark;
      _anchor = anchor;
    });
    if (_focusArguments && mark != null) {
      _focusArguments = false;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _argumentFocus.requestFocus(),
      );
    }
  }

  static double _popoverWidth(double fieldWidth) =>
      fieldWidth < 360 ? fieldWidth : 360;

  /// The kinds offered, in registry order: those that belong in fields,
  /// stay in text, and whose entry offers them.
  List<MarkKind> get _kinds => offeredKinds(_session);

  @override
  void dispose() {
    _c.removeListener(_track);
    _focus.removeListener(_focused);
    _session.release(this);
    _ownFocus?.dispose();
    _argumentFocus.dispose();
    super.dispose();
  }

  /// Toggles [kind] over the selection, or puts it in at the cursor when it
  /// takes no content. A new mark with arguments starts with them empty, and
  /// the first of them is focused to fill in.
  @override
  void apply(MarkKind kind) {
    final mark = ContentNode.mark(
      kind.key,
      args: [for (final _ in kind.args) ''],
    ) as MarkNode;
    final atom = kind.content == MarkContent.forbidden;
    final adding = atom || !_c.isMarked(kind.key);
    if (adding && kind.args.isNotEmpty && (atom || !_c.selection.isCollapsed)) {
      _focusArguments = true;
    } else {
      _focus.requestFocus();
    }
    if (atom) {
      _c.insert(mark);
    } else {
      _c.toggle(mark);
    }
  }

  Map<ShortcutActivator, VoidCallback> get _shortcuts {
    final byKey = {for (final k in _kinds) k.key: k};
    final apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    SingleActivator primary(
      LogicalKeyboardKey key, {
      bool shift = false,
      bool alt = false,
    }) => SingleActivator(
      key,
      control: !apple,
      meta: apple,
      shift: shift,
      alt: alt,
    );
    final field = _session.field;
    return {
      for (final MapEntry(:key, value: editing) in _c.editing.entries)
        if ((byKey[key], editing.shortcut) case (final kind?, final shortcut?))
          primary(shortcut.key, shift: shortcut.shift, alt: shortcut.alt): () =>
              apply(kind),
      primary(LogicalKeyboardKey.keyZ): field.undo,
      primary(LogicalKeyboardKey.keyZ, shift: true): field.redo,
      if (!apple) primary(LogicalKeyboardKey.keyY): field.redo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final kinds = _kinds;
    // Room above each line for readings, most of it above the text.
    final style = (widget.style ?? type.body).copyWith(
      height: 2.3,
      leadingDistribution: TextLeadingDistribution.proportional,
    );
    return CallbackShortcuts(
      bindings: _shortcuts,
      child: OverlayPortal(
        controller: _popover,
        overlayChildBuilder: _buildPopover,
        child: CompositedTransformTarget(
          link: _link,
          child: Stack(
            key: _stack,
            children: [
              TextField(
                controller: _c,
                focusNode: _focus,
                minLines: 1,
                maxLines: null,
                // An action other than a new line makes Enter call
                // onEditingComplete instead; the text still wraps.
                textInputAction: widget.onEnter == null
                    ? null
                    : TextInputAction.next,
                onEditingComplete: widget.onEnter,
                style: style,
                strutStyle: StrutStyle.fromTextStyle(style),
                decoration: InputDecoration.collapsed(
                  hintText: widget.hint,
                  hintStyle: style.copyWith(color: context.colors.textFaint),
                ),
                contextMenuBuilder: (context, state) =>
                    AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: state.contextMenuAnchors,
                      buttonItems: [
                        ...state.contextMenuButtonItems,
                        for (final kind in kinds)
                          if (kind.content == MarkContent.forbidden ||
                              !_c.selection.isCollapsed)
                            ContextMenuButtonItem(
                              label: markLabel(
                                context,
                                _c.editing[kind.key],
                                kind.key,
                              ),
                              onPressed: () {
                                state.hideToolbar();
                                apply(kind);
                              },
                            ),
                      ],
                    ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _AnnotationsPainter(
                      controller: _c,
                      stack: _stack,
                      annotation: annotationStyle(context),
                      base: style,
                      direction: Directionality.of(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The arguments of [_argumentMark], under it, over whatever follows.
  Widget _buildPopover(BuildContext context) {
    final mark = _argumentMark;
    final root = _stack.currentContext?.findRenderObject() as RenderBox?;
    if (mark == null || root == null || !root.hasSize) {
      return const SizedBox.shrink();
    }
    final kind = _allKinds[mark.key!]!;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        offset: _anchor + const Offset(0, Spacing.xs),
        child: TextFieldTapRegion(
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape):
                  _focus.requestFocus,
            },
            child: SizedBox(
              width: _popoverWidth(root.size.width),
              child: Panel(
                padding: const EdgeInsets.all(Spacing.sm),
                // A new row for each mark, so its fields start from its
                // values.
                child: _ArgumentRow(
                  key: ValueKey((mark.start, mark.key)),
                  controller: _c,
                  range: mark,
                  kind: kind,
                  editing: _c.editing[kind.key],
                  focusNode: _argumentFocus,
                  onDone: _focus.requestFocus,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The kinds [session] offers in text, in registry order: those that belong
/// in fields and the field allows, are not blocks, and whose entry offers
/// them.
List<MarkKind> offeredKinds(FieldSession session) => [
  for (final kind in session.kinds.all)
    if (kind.scopes.contains(MarkScope.field) &&
        session.allows(kind.key) &&
        !session.blocks.containsKey(kind.key) &&
        (session.editing[kind.key]?.offered ?? true))
      kind,
];

/// The label of [key] in [editing], or the key.
String markLabel(BuildContext context, MarkEditing? editing, String key) =>
    editing?.label?.call(AppLocalizations.of(context)) ?? key;

/// The arguments of a mark, with a button to take the mark off.
class _ArgumentRow extends StatefulWidget {
  const _ArgumentRow({
    super.key,
    required this.controller,
    required this.range,
    required this.kind,
    required this.editing,
    required this.focusNode,
    required this.onDone,
  });

  final MarkedTextController controller;
  final MarkRange range;
  final MarkKind kind;
  final MarkEditing? editing;
  final FocusNode focusNode;

  /// Called when the arguments are submitted, to return to the text.
  final VoidCallback onDone;

  @override
  State<_ArgumentRow> createState() => _ArgumentRowState();
}

class _ArgumentRowState extends State<_ArgumentRow> {
  late final _values = [
    for (final (i, _) in widget.kind.args.indexed)
      (widget.range.node as MarkNode).args.elementAtOrNull(i) ?? '',
  ];

  /// Text fields for the arguments without an editor of their own.
  late final _fields = {
    for (final (i, arg) in widget.kind.args.indexed)
      if (widget.editing?.argumentEditors[arg.name] == null)
        i: TextEditingController(text: _values[i]),
  };

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

  /// The range as it is now; edits replace it.
  MarkRange? get _current => widget.controller.ranges
      .where((r) => r.start == widget.range.start && r.key == widget.range.key)
      .lastOrNull;

  void _changed(int i, String value) {
    setState(() => _values[i] = value);
    final range = _current;
    if (range == null) return;
    widget.controller.replace(
      range,
      (range.node as MarkNode).copyWith(args: [..._values]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final l10n = AppLocalizations.of(context);
    final editing = widget.editing;
    return Row(
      children: [
        for (final (i, arg) in widget.kind.args.indexed) ...[
          Text(
            editing?.argumentLabels[arg.name]?.call(l10n) ?? arg.name,
            style: type.label.copyWith(color: colors.textMuted),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: switch (editing?.argumentEditors[arg.name]) {
              final build? => build(
                context,
                ArgumentEditing(
                  value: _values[i],
                  onChanged: (value) => _changed(i, value),
                  onDone: widget.onDone,
                  focusNode: i == 0 ? widget.focusNode : null,
                ),
              ),
              null => TextField(
                controller: _fields[i],
                focusNode: i == 0 ? widget.focusNode : null,
                style: type.body,
                onChanged: (value) => _changed(i, value),
                onSubmitted: (_) => widget.onDone(),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: arg.description,
                  filled: true,
                  fillColor: colors.surfaceSunken,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.sm),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            },
          ),
          const SizedBox(width: Spacing.sm),
        ],
        TextButton(
          onPressed: () {
            if (_current case final range?) widget.controller.remove(range);
          },
          child: Text(l10n.editorRemoveMark),
        ),
      ],
    );
  }
}

/// Paints each mark's annotation, such as a ruby's reading, centred above
/// its text, finding the text's place through the field's [RenderEditable].
class _AnnotationsPainter extends CustomPainter {
  _AnnotationsPainter({
    required this.controller,
    required this.stack,
    required this.annotation,
    required this.base,
    required this.direction,
  }) : super(repaint: controller);

  final MarkedTextController controller;
  final GlobalKey stack;
  final TextStyle annotation;
  final TextStyle base;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final root = stack.currentContext?.findRenderObject() as RenderBox?;
    final editable = root == null ? null : _editableIn(root);
    if (root == null || editable == null || !editable.hasSize) return;
    // Where the glyphs start below the top of a line.
    final metrics = (TextPainter(
      text: TextSpan(text: 'あ', style: base),
      textDirection: direction,
    )..layout());
    final line = metrics.computeLineMetrics().first;
    final glyphTop = line.baseline - line.unscaledAscent;
    metrics.dispose();
    for (final r in controller.ranges) {
      final text = controller.annotationOf(r);
      if (text == null) continue;
      final boxes = editable.getBoxesForSelection(
        TextSelection(baseOffset: r.start, extentOffset: r.end),
      );
      if (boxes.isEmpty) continue;
      // Over the part of the text on its first line.
      final first = boxes.first;
      final onLine = boxes.where((b) => (b.top - first.top).abs() < 1);
      final left = onLine.map((b) => b.left).reduce((a, b) => a < b ? a : b);
      final right = onLine.map((b) => b.right).reduce((a, b) => a > b ? a : b);
      final origin = editable.localToGlobal(
        Offset(left, first.top),
        ancestor: root,
      );
      final painter = TextPainter(
        text: TextSpan(text: text, style: annotation),
        textDirection: direction,
      )..layout();
      painter
        ..paint(
          canvas,
          Offset(
            origin.dx + (right - left - painter.width) / 2,
            origin.dy + glyphTop - painter.height - 1,
          ),
        )
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_AnnotationsPainter old) =>
      old.annotation != annotation ||
      old.base != base ||
      old.direction != direction;
}

/// The text field's [RenderEditable] under [root].
RenderEditable? _editableIn(RenderObject root) {
  RenderEditable? found;
  void visit(RenderObject o) {
    if (found != null) return;
    if (o is RenderEditable) {
      found = o;
    } else {
      o.visitChildren(visit);
    }
  }

  visit(root);
  return found;
}
