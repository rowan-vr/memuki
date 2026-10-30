import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/mark_kinds.dart';
import '../../domain/content/marked_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'marked_text_controller.dart';

/// Edits a field's content in its rendered form.
///
/// Marks are applied to the selection from the toolbar, the selection menu,
/// or a shortcut, and toggled off the same way. Ruby readings are drawn
/// above their base text. While the cursor is in a mark with arguments,
/// such as a ruby's reading, they are edited below the field.
class FieldEditor extends StatefulWidget {
  const FieldEditor({
    super.key,
    required this.controller,
    this.kinds,
    this.focusNode,
  });

  final MarkedTextController controller;

  /// The kinds that can be applied: those of [MarkKinds.builtIn] that belong
  /// in fields and take content, by default.
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

  void _place() {
    final mark = _c.markAtSelection(
      (r) => _allKinds[r.key!]?.args.isNotEmpty ?? false,
    );
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
          kind.content == MarkContent.required)
        kind,
  ];

  @override
  void dispose() {
    _c.removeListener(_track);
    _ownFocus?.dispose();
    _argumentFocus.dispose();
    super.dispose();
  }

  /// Toggles [kind] over the selection. A new mark with arguments starts
  /// with them empty, and the first of them is focused to fill in.
  void _apply(MarkKind kind) {
    final adding = !_c.isMarked(kind.key);
    final mark = ContentNode.mark(
      kind.key,
      args: [for (final _ in kind.args) ''],
    ) as MarkNode;
    if (adding && kind.args.isNotEmpty && !_c.selection.isCollapsed) {
      _focusArguments = true;
    } else {
      _focus.requestFocus();
    }
    _c.toggle(mark);
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
      for (final (activator, key) in [
        (primary(LogicalKeyboardKey.keyB), 'em'),
        (primary(LogicalKeyboardKey.equal), 'sub'),
        (primary(LogicalKeyboardKey.equal, shift: true), 'sup'),
        (primary(LogicalKeyboardKey.keyR, alt: true), 'ruby'),
        (primary(LogicalKeyboardKey.keyL, alt: true), 'lang'),
      ])
        if (byKey[key] case final kind?) activator: () => _apply(kind),
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
                                if (!_c.selection.isCollapsed)
                                  for (final kind in kinds)
                                    ContextMenuButtonItem(
                                      label: _label(context, kind.key),
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
                            painter: _ReadingsPainter(
                              controller: _c,
                              stack: _stack,
                              reading: rubyReadingStyle(context),
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
                child: _ArgumentRow(
                  // A new row for each mark, so its fields start from its
                  // values.
                  key: ValueKey((mark.start, mark.key)),
                  controller: _c,
                  range: mark,
                  kind: kind,
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

/// The label of the built-in kind [key], or the key itself.
String _label(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  return switch (key) {
    'ruby' => l10n.editorRuby,
    'em' => l10n.editorEmphasis,
    'sub' => l10n.editorSubscript,
    'sup' => l10n.editorSuperscript,
    'lang' => l10n.editorLanguage,
    _ => key,
  };
}

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
          _ToolButton(
            label: _label(context, kind.key),
            icon: switch (kind.key) {
              'em' => MemukiIcons.emphasis,
              'sub' => MemukiIcons.subscript,
              'sup' => MemukiIcons.superscript,
              'lang' => MemukiIcons.language,
              _ => null,
            },
            glyph: switch (kind.key) {
              'ruby' => 'あ',
              _ => kind.key,
            },
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
    required this.focusNode,
    required this.onDone,
  });

  final MarkedTextController controller;
  final MarkRange range;
  final MarkKind kind;
  final FocusNode focusNode;

  /// Called when the arguments are submitted, to return to the text.
  final VoidCallback onDone;

  @override
  State<_ArgumentRow> createState() => _ArgumentRowState();
}

class _ArgumentRowState extends State<_ArgumentRow> {
  late final _fields = [
    for (final (i, _) in widget.kind.args.indexed)
      TextEditingController(
        text: (widget.range.node as MarkNode).args.elementAtOrNull(i) ?? '',
      ),
  ];

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  /// The range as it is now; edits replace it.
  MarkRange? get _current => widget.controller.ranges
      .where((r) => r.start == widget.range.start && r.key == widget.range.key)
      .lastOrNull;

  void _changed() {
    final range = _current;
    if (range == null) return;
    widget.controller.replace(
      range,
      (range.node as MarkNode).copyWith(
        args: [for (final f in _fields) f.text],
      ),
    );
  }

  String _argumentLabel(BuildContext context, MarkArgument arg) {
    final l10n = AppLocalizations.of(context);
    return switch ((widget.kind.key, arg.name)) {
      ('ruby', 'reading') => l10n.editorReading,
      ('lang', 'tag') => l10n.editorLanguageTag,
      _ => arg.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        for (final (i, arg) in widget.kind.args.indexed) ...[
          Text(
            _argumentLabel(context, arg),
            style: type.label.copyWith(color: colors.textMuted),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: TextField(
              controller: _fields[i],
              focusNode: i == 0 ? widget.focusNode : null,
              style: type.body,
              onChanged: (_) => _changed(),
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

/// Paints each ruby's reading centred above its base text, finding the
/// text's place through the field's [RenderEditable].
class _ReadingsPainter extends CustomPainter {
  _ReadingsPainter({
    required this.controller,
    required this.stack,
    required this.reading,
    required this.base,
    required this.direction,
  }) : super(repaint: controller);

  final MarkedTextController controller;
  final GlobalKey stack;
  final TextStyle reading;
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
      if (r.key != 'ruby' || r.end > controller.text.length) continue;
      final text = (r.node as MarkNode).args.firstOrNull ?? '';
      if (text.isEmpty) continue;
      final boxes = editable.getBoxesForSelection(
        TextSelection(baseOffset: r.start, extentOffset: r.end),
      );
      if (boxes.isEmpty) continue;
      // Over the part of the base text on its first line.
      final first = boxes.first;
      final onLine = boxes.where((b) => (b.top - first.top).abs() < 1);
      final left = onLine.map((b) => b.left).reduce((a, b) => a < b ? a : b);
      final right = onLine.map((b) => b.right).reduce((a, b) => a > b ? a : b);
      final origin = editable.localToGlobal(
        Offset(left, first.top),
        ancestor: root,
      );
      final painter = TextPainter(
        text: TextSpan(text: text, style: reading),
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
  bool shouldRepaint(_ReadingsPainter old) =>
      old.reading != reading || old.base != base || old.direction != direction;
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
