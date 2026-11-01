import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/content/mark_kinds.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../components/pressable.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'block_editing.dart';
import 'content_editor.dart';
import 'field_controller.dart';
import 'field_editor_scope.dart';
import 'inline_editor.dart';
import 'mark_editing.dart';

/// Edits a field's content in its rendered form.
///
/// The toolbar applies marks within text, such as emphasis, to the text
/// editor last focused. The toolbox holds blocks, such as a dictionary sense
/// or a list, to drag into the field or put in at the cursor; each is edited
/// in place, by its [BlockEditing]. Undo and redo cover the whole field.
class FieldEditor extends StatefulWidget {
  const FieldEditor({
    super.key,
    required this.controller,
    this.kinds,
    this.editing,
    this.blocks,
  });

  final FieldController controller;

  /// The kinds that can be applied: those of [MarkKinds.builtIn] that belong
  /// in fields, by default.
  final MarkKinds? kinds;

  /// How marks within text are shown and applied: [MarkEditing.builtIn] by
  /// default.
  final Map<String, MarkEditing>? editing;

  /// How blocks are put in and edited: [BlockEditing.builtIn] by default.
  /// Empty, there is no toolbox, and blocks are shown as text.
  final Map<String, BlockEditing>? blocks;

  @override
  State<FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> {
  late FieldSession _session = _newSession();

  FieldSession _newSession() => FieldSession(
    field: widget.controller,
    kinds: widget.kinds ?? MarkKinds.builtIn,
    editing: widget.editing ?? MarkEditing.builtIn,
    blocks: widget.blocks ?? BlockEditing.builtIn,
  );

  @override
  void didUpdateWidget(FieldEditor old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller ||
        old.kinds != widget.kinds ||
        old.editing != widget.editing ||
        old.blocks != widget.blocks) {
      final previous = _session;
      _session = _newSession();
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  /// The kinds of block that may stand at the top level.
  Set<String> get _topLevel => {
    for (final MapEntry(:key, :value) in _session.blocks.entries)
      if (value.topLevel) key,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final field = widget.controller;
    return FieldSessionScope(
      session: _session,
      child: TextFieldTapRegion(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Toolbar(session: _session),
            if (_session.blocks.values.any(_inToolbox)) ...[
              const SizedBox(height: Spacing.xs),
              _Toolbox(session: _session),
            ],
            const SizedBox(height: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: ListenableBuilder(
                listenable: field,
                builder: (context, _) => ContentEditor(
                  // A new editor for a new session, whose parts start over.
                  key: ObjectKey(_session),
                  nodes: field.nodes,
                  onChanged: field.edit,
                  accepts: _topLevel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Whether the toolbox offers [entry].
bool _inToolbox(BlockEditing entry) => entry.offered && entry.create != null;

/// Buttons for the marks within text, lit while the selection in the text
/// editor last focused has them, then undo and redo.
class _Toolbar extends StatefulWidget {
  const _Toolbar({required this.session});

  final FieldSession session;

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  InlineTarget? _target;

  FieldSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(_Toolbar old) {
    super.didUpdateWidget(old);
    if (old.session != widget.session) {
      _unlisten(old.session);
      _listen();
    }
  }

  @override
  void dispose() {
    _unlisten(_session);
    super.dispose();
  }

  void _listen() {
    _session.field.addListener(_changed);
    _session.active.addListener(_retarget);
    _retarget();
  }

  void _unlisten(FieldSession session) {
    session.field.removeListener(_changed);
    session.active.removeListener(_retarget);
    _target?.controller.removeListener(_changed);
  }

  void _retarget() {
    _target?.controller.removeListener(_changed);
    _target = _session.active.value;
    _target?.controller.addListener(_changed);
    _changed();
  }

  /// Rebuilds, after the frame when the change came while building, as
  /// undo resets the text editors below.
  void _changed() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final field = _session.field;
    final target = _target;
    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final kind in offeredKinds(_session))
          if (_session.editing[kind.key] case final editing)
            _ToolButton(
              label: markLabel(context, editing, kind.key),
              icon: editing?.icon,
              glyph: editing?.glyph ?? kind.key,
              active: target?.controller.isMarked(kind.key) ?? false,
              onPressed: target == null ? null : () => target.apply(kind),
            ),
        const SizedBox(width: Spacing.sm),
        _ToolButton(
          label: l10n.editorUndo,
          icon: MemukiIcons.undo,
          onPressed: field.canUndo ? field.undo : null,
        ),
        _ToolButton(
          label: l10n.editorRedo,
          icon: MemukiIcons.redo,
          onPressed: field.canRedo ? field.redo : null,
        ),
      ],
    );
  }
}

/// The blocks that can be put in, to drag into the field or press to put in
/// at the cursor. Those that cannot go in where the cursor is are dimmed.
class _Toolbox extends StatelessWidget {
  const _Toolbox({required this.session});

  final FieldSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // Touch screens drag after a long press, so that a drag can scroll.
    final touch =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return ValueListenableBuilder(
      valueListenable: session.active,
      builder: (context, _, _) => Wrap(
        spacing: Spacing.xs,
        runSpacing: Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.editorToolbox,
            style: context.type.caption.copyWith(color: colors.textFaint),
          ),
          for (final MapEntry(:key, value: entry) in session.blocks.entries)
            if (_inToolbox(entry))
              _ToolboxItem(
                drag: ToolboxDrag(key),
                label: entry.label(l10n),
                icon: entry.icon,
                hint: l10n.editorToolboxHint,
                touch: touch,
                enabled: session.targetFor(key) != null,
                onPressed: () => session.insert(key),
                onDragStarted: () => session.dragging.value = key,
                onDragEnded: () => session.dragging.value = null,
              ),
        ],
      ),
    );
  }
}

class _ToolboxItem extends StatelessWidget {
  const _ToolboxItem({
    required this.drag,
    required this.label,
    required this.icon,
    required this.hint,
    required this.touch,
    required this.enabled,
    required this.onPressed,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ToolboxDrag drag;
  final String label;
  final IconData? icon;
  final String hint;
  final bool touch;
  final bool enabled;
  final VoidCallback onPressed;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget chip({bool lifted = false}) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: lifted ? colors.surface : colors.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.xs),
        border: lifted ? Border.all(color: colors.accent.base) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: colors.textMuted),
            const SizedBox(width: Spacing.xs),
          ],
          Text(label, style: context.type.label.copyWith(color: colors.text)),
        ],
      ),
    );
    final button = Pressable(
      onPressed: enabled ? onPressed : null,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(Radii.xs),
      builder: (context, _) =>
          Opacity(opacity: enabled ? 1 : 0.5, child: chip()),
    );
    final feedback = Material(
      type: MaterialType.transparency,
      child: chip(lifted: true),
    );
    final dragged = Opacity(opacity: 0.4, child: chip());
    return Tooltip(
      message: hint,
      child: touch
          ? LongPressDraggable<ToolboxDrag>(
              data: drag,
              feedback: feedback,
              childWhenDragging: dragged,
              onDragStarted: onDragStarted,
              onDragEnd: (_) => onDragEnded(),
              child: button,
            )
          : Draggable<ToolboxDrag>(
              data: drag,
              feedback: feedback,
              childWhenDragging: dragged,
              onDragStarted: onDragStarted,
              onDragEnd: (_) => onDragEnded(),
              child: button,
            ),
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
