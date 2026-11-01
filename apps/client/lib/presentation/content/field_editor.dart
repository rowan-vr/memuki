import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/mark_kinds.dart';
import '../../domain/content/marked_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'mark_editing.dart';
import 'marked_text_controller.dart';

/// Edits a field's content in its rendered form.
///
/// Marks are applied to the selection from the toolbar, the selection menu,
/// or a shortcut, and toggled off the same way; a kind without content is
/// put in at the cursor. Annotations, such as ruby readings, are drawn above
/// their text. While the cursor is in or beside a mark with arguments, they
/// are edited in a popover under it. How each kind is shown and applied
/// comes from the controller's [MarkedTextController.editing].
class FieldEditor extends StatefulWidget {
  const FieldEditor({
    super.key,
    required this.controller,
    this.kinds,
    this.focusNode,
  });

  final MarkedTextController controller;

  /// The kinds that can be applied: those of [MarkKinds.builtIn] that belong
  /// in fields, by default.
  final MarkKinds? kinds;

  final FocusNode? focusNode;

  @override
  State<FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> {
  final _stack = GlobalKey();
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  final _argumentFocus = FocusNode();

  /// The popover for the arguments of the mark at the selection, and where
  /// it is anchored: under the mark, in the field's coordinates.
  final _link = LayerLink();
  final _popover = OverlayPortalController();
  MarkRange? _argumentMark;
  Offset _anchor = Offset.zero;
  var _placing = false;
  var _focusArguments = false;

  MarkedTextController get _c => widget.controller;

  MarkKinds get _allKinds => widget.kinds ?? MarkKinds.builtIn;

  @override
  void initState() {
    super.initState();
    _c.addListener(_track);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _popover.show();
    });
  }

  @override
  void didUpdateWidget(FieldEditor old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_track);
      widget.controller.addListener(_track);
      _track();
    }
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

  /// Whether [range] has a popover: its arguments, or its source when it is
  /// kept whole.
  bool _hasPopover(MarkRange range) =>
      _c.isWhole(range) || _hasArguments(range);

  bool _hasArguments(MarkRange range) =>
      _allKinds[range.key ?? '']?.args.isNotEmpty ?? false;

  void _place() {
    final mark =
        _c.atomAtSelection(_hasPopover) ?? _c.markAtSelection(_hasArguments);
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

  /// The kinds offered, in registry order.
  List<MarkKind> get _kinds => [
    for (final kind in (widget.kinds ?? MarkKinds.builtIn).all)
      if (kind.scopes.contains(MarkScope.field) &&
          (_c.editing[kind.key]?.offered ?? true))
        kind,
  ];

  @override
  void dispose() {
    _c.removeListener(_track);
    _ownFocus?.dispose();
    _argumentFocus.dispose();
    super.dispose();
  }

  /// Toggles [kind] over the selection, or puts it in at the cursor when it
  /// takes no content. A new mark with arguments starts with them empty, and
  /// the first of them is focused to fill in.
  void _apply(MarkKind kind) {
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
    return {
      for (final MapEntry(:key, value: editing) in _c.editing.entries)
        if ((byKey[key], editing.shortcut) case (final kind?, final shortcut?))
          primary(shortcut.key, shift: shortcut.shift, alt: shortcut.alt): () =>
              _apply(kind),
      primary(LogicalKeyboardKey.keyZ): _c.undo,
      primary(LogicalKeyboardKey.keyZ, shift: true): _c.redo,
      if (!apple) primary(LogicalKeyboardKey.keyY): _c.redo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final kinds = _kinds;
    // Room above each line for readings, most of it above the text.
    final style = type.body.copyWith(
      height: 2.3,
      leadingDistribution: TextLeadingDistribution.proportional,
    );
    return CallbackShortcuts(
      bindings: _shortcuts,
      child: TextFieldTapRegion(
        child: ListenableBuilder(
          listenable: _c,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Toolbar(controller: _c, kinds: kinds, onApply: _apply),
              const SizedBox(height: Spacing.xs),
              OverlayPortal(
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
                        style: style,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colors.surfaceSunken,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Spacing.md,
                            vertical: Spacing.sm,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Radii.sm),
                            borderSide: BorderSide.none,
                          ),
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
                                      label: _label(
                                        context,
                                        _c.editing[kind.key],
                                        kind.key,
                                      ),
                                      onPressed: () {
                                        state.hideToolbar();
                                        _apply(kind);
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
                child: _c.isWhole(mark)
                    ? _SourceRow(
                        key: ValueKey((mark.start, mark.key, 'source')),
                        controller: _c,
                        range: mark,
                        focusNode: _argumentFocus,
                      )
                    : _ArgumentRow(
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

/// The label of [kind] in [editing], or its key.
String _label(BuildContext context, MarkEditing? editing, String key) =>
    editing?.label?.call(AppLocalizations.of(context)) ?? key;

/// Buttons for the marks, lit while the selection has them, then undo and
/// redo.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
    required this.kinds,
    required this.onApply,
  });

  final MarkedTextController controller;
  final List<MarkKind> kinds;
  final ValueChanged<MarkKind> onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final kind in kinds)
          if (controller.editing[kind.key] case final editing)
            _ToolButton(
              label: _label(context, editing, kind.key),
              icon: editing?.icon,
              glyph: editing?.glyph ?? kind.key,
              active: controller.isMarked(kind.key),
              onPressed: () => onApply(kind),
            ),
        const SizedBox(width: Spacing.sm),
        _ToolButton(
          label: l10n.editorUndo,
          icon: MemukiIcons.undo,
          onPressed: controller.canUndo ? controller.undo : null,
        ),
        _ToolButton(
          label: l10n.editorRedo,
          icon: MemukiIcons.redo,
          onPressed: controller.canRedo ? controller.redo : null,
        ),
      ],
    );
  }
}

/// A square toolbar button showing [icon], or [glyph] when there is none.
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    this.icon,
    this.glyph,
    this.active = false,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final String? glyph;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: label,
      child: Pressable(
        onPressed: onPressed,
        selected: active,
        semanticLabel: label,
        borderRadius: BorderRadius.circular(Radii.xs),
        builder: (context, state) {
          final color = onPressed == null
              ? colors.textFaint
              : active
              ? colors.accent.onSoft
              : colors.textMuted;
          return AnimatedContainer(
            duration: Motion.enabled(context) ? Motion.quick : Duration.zero,
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? colors.accent.soft
                  : state.hovered || state.pressed
                  ? colors.surfaceSunken
                  : null,
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
            child: icon != null
                ? Icon(icon, size: 18, color: color)
                : Text(
                    glyph ?? '',
                    style: context.type.label.copyWith(color: color),
                  ),
          );
        },
      ),
    );
  }
}

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

/// The source of a mark kept whole, such as a dictionary sense, with a
/// button to remove it. Source that reads as one mark replaces it; anything
/// else waits until it does.
class _SourceRow extends StatefulWidget {
  const _SourceRow({
    super.key,
    required this.controller,
    required this.range,
    required this.focusNode,
  });

  final MarkedTextController controller;
  final MarkRange range;
  final FocusNode focusNode;

  @override
  State<_SourceRow> createState() => _SourceRowState();
}

class _SourceRowState extends State<_SourceRow> {
  late final _source = TextEditingController(
    text: writeContent([widget.range.node]),
  );

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  /// The range as it is now; edits replace it.
  MarkRange? get _current => widget.controller.ranges
      .where((r) => r.atom && r.start == widget.range.start)
      .lastOrNull;

  void _changed(String source) {
    final range = _current;
    final parsed = parseContent(source);
    if (range == null || parsed.problems.isNotEmpty) return;
    if (parsed.nodes case [final MarkNode mark]) {
      widget.controller.replace(range, mark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _source,
          focusNode: widget.focusNode,
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
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () {
              if (_current case final range?) widget.controller.remove(range);
            },
            child: Text(l10n.editorRemoveMark),
          ),
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
