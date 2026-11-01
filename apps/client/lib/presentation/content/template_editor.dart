import 'package:flutter/material.dart';

import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/template_layout.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/menu_chip.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'field_editor.dart';
import 'marked_text_controller.dart';

/// Edits a template by arranging its lines: the front and the back, each a
/// list of fields, conditions, and text, and the fields it requires.
///
/// A field is picked from [fields], the fields of the note type, and placed
/// in one of the [fieldRoles] or none. A condition holds lines shown only
/// when its field is filled. Text is edited with a [FieldEditor]. A line
/// that is none of these is kept and edited as source.
///
/// Each change is reported as a whole layout to [onChanged]. When [layout]
/// changes to one this editor did not report, it starts over from it.
class TemplateEditor extends StatefulWidget {
  const TemplateEditor({
    super.key,
    required this.layout,
    required this.fields,
    required this.onChanged,
  });

  final TemplateLayout layout;
  final List<String> fields;
  final ValueChanged<TemplateLayout> onChanged;

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  late _Lines _front;
  late _Lines _back;
  late TemplateLayout _reported;

  @override
  void initState() {
    super.initState();
    _load(widget.layout);
  }

  @override
  void didUpdateWidget(TemplateEditor old) {
    super.didUpdateWidget(old);
    if (widget.layout != _reported) {
      _front.dispose();
      _back.dispose();
      _load(widget.layout);
    }
  }

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  void _load(TemplateLayout layout) {
    _reported = layout;
    _front = _Lines.of(layout.front, _changed);
    _back = _Lines.of(layout.back, _changed);
  }

  void _changed() {
    setState(() {});
    _report(_reported.copyWith(front: _front.blocks, back: _back.blocks));
  }

  void _report(TemplateLayout layout) {
    if (layout == _reported) return;
    _reported = layout;
    widget.onChanged(layout);
  }

  void _toggleRequired(String name) => setState(() {
    final requires = [..._reported.requires];
    if (!requires.remove(name)) requires.add(name);
    _report(_reported.copyWith(requires: requires));
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final type = context.type;
    final colors = context.colors;
    final requirable = [
      ...widget.fields,
      for (final name in _reported.requires)
        if (!widget.fields.contains(name)) name,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Side(title: l10n.templateFront, lines: _front, fields: widget.fields),
        const SizedBox(height: Spacing.md),
        _Side(title: l10n.templateBack, lines: _back, fields: widget.fields),
        const SizedBox(height: Spacing.md),
        Text(l10n.templateRequires, style: type.label),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.templateRequiresHint,
          style: type.caption.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final name in requirable)
              _CheckChip(
                label: widget.fields.contains(name)
                    ? name
                    : l10n.templateMissingField(name),
                checked: _reported.requires.contains(name),
                onPressed: () => _toggleRequired(name),
              ),
          ],
        ),
      ],
    );
  }
}

/// The lines of a side or a condition, as the editor holds them, with the
/// controllers of the lines that edit text.
class _Lines {
  _Lines(this.items, this.onChanged);

  factory _Lines.of(List<TemplateBlock> blocks, VoidCallback onChanged) {
    final lines = _Lines([], onChanged);
    lines.items.addAll(blocks.map(lines._item));
    return lines;
  }

  final List<_Line> items;
  final VoidCallback onChanged;

  List<TemplateBlock> get blocks => [for (final i in items) i.block];

  _Line _item(TemplateBlock block) => switch (block) {
    FieldBlock() => _FieldLine(block),
    IfBlock(:final name, :final blocks) => _IfLine(
      name,
      _Lines.of(blocks, onChanged),
    ),
    TextBlock(:final content) => _TextLine(
      MarkedTextController(content)..addListener(onChanged),
    ),
    SourceBlock(:final content) => _SourceLine(
      TextEditingController(text: writeContent(content))
        ..addListener(onChanged),
    ),
  };

  void add(TemplateBlock block) {
    items.add(_item(block));
    onChanged();
  }

  /// Reports a change made to one of the lines.
  void changed() => onChanged();

  void move(_Line line, int by) {
    final from = items.indexOf(line);
    final to = from + by;
    if (to < 0 || to >= items.length) return;
    items
      ..removeAt(from)
      ..insert(to, line);
    onChanged();
  }

  void remove(_Line line) {
    items.remove(line);
    line.dispose();
    onChanged();
  }

  void dispose() {
    for (final item in items) {
      item.dispose();
    }
  }
}

sealed class _Line {
  final key = UniqueKey();

  TemplateBlock get block;

  void dispose() {}
}

class _FieldLine extends _Line {
  _FieldLine(this.field);

  FieldBlock field;

  @override
  TemplateBlock get block => field;
}

class _IfLine extends _Line {
  _IfLine(this.name, this.lines);

  String name;
  final _Lines lines;

  @override
  TemplateBlock get block => IfBlock(name, lines.blocks);

  @override
  void dispose() => lines.dispose();
}

class _TextLine extends _Line {
  _TextLine(this.controller);

  final MarkedTextController controller;

  @override
  TemplateBlock get block => TextBlock(controller.nodes);

  @override
  void dispose() => controller.dispose();
}

class _SourceLine extends _Line {
  _SourceLine(this.controller);

  final TextEditingController controller;

  @override
  TemplateBlock get block => SourceBlock(parseContent(controller.text).nodes);

  @override
  void dispose() => controller.dispose();
}

/// A side of the card: its lines, and buttons to add more.
class _Side extends StatelessWidget {
  const _Side({required this.title, required this.lines, required this.fields});

  final String title;
  final _Lines lines;
  final List<String> fields;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(title, style: type.heading)),
          const SizedBox(height: Spacing.sm),
          _LineList(lines: lines, fields: fields, conditions: true),
        ],
      ),
    );
  }
}

/// [lines], one under another, then buttons to add a line. Conditions are
/// offered only when [conditions] is set, so they do not nest.
class _LineList extends StatelessWidget {
  const _LineList({
    required this.lines,
    required this.fields,
    required this.conditions,
  });

  final _Lines lines;
  final List<String> fields;
  final bool conditions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final first = fields.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lines.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Text(
              l10n.templateEmptySide,
              style: context.type.body.copyWith(color: colors.textFaint),
            ),
          ),
        for (final (i, line) in lines.items.indexed)
          Padding(
            key: line.key,
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _LineRow(
              line: line,
              lines: lines,
              fields: fields,
              first: i == 0,
              last: i == lines.items.length - 1,
            ),
          ),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            QuietButton(
              icon: MemukiIcons.field,
              label: l10n.templateAddField,
              onPressed: first == null
                  ? null
                  : () => lines.add(FieldBlock(first)),
            ),
            QuietButton(
              icon: MemukiIcons.text,
              label: l10n.templateAddText,
              onPressed: () => lines.add(const TextBlock([])),
            ),
            if (conditions)
              QuietButton(
                icon: MemukiIcons.condition,
                label: l10n.templateAddCondition,
                onPressed: first == null
                    ? null
                    : () => lines.add(IfBlock(first, const [])),
              ),
          ],
        ),
      ],
    );
  }
}

/// One line: what it edits, then buttons to move and remove it.
class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.lines,
    required this.fields,
    required this.first,
    required this.last,
  });

  final _Line line;
  final _Lines lines;
  final List<String> fields;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    final line = this.line;
    final Widget body = switch (line) {
      _FieldLine(:final field) => Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FieldPicker(
            label: l10n.templateField,
            fields: fields,
            selected: field.name,
            onSelected: (name) {
              line.field = field.withName(name);
              lines.changed();
            },
          ),
          MenuChip<String?>(
            semanticLabel: l10n.templateRole,
            choices: [
              Choice(null, l10n.templateNoRole),
              for (final role in fieldRoles)
                Choice(role, _roleLabel(l10n, role)),
              if (field.role case final role? when !fieldRoles.contains(role))
                Choice(role, role),
            ],
            selected: field.role,
            onSelected: (role) {
              line.field = field.withRole(role);
              lines.changed();
            },
          ),
        ],
      ),
      _IfLine(:final name) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.templateConditionField,
                style: type.label.copyWith(color: colors.textMuted),
              ),
              _FieldPicker(
                label: l10n.templateConditionField,
                fields: fields,
                selected: name,
                onSelected: (name) {
                  line.name = name;
                  lines.changed();
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.only(left: Spacing.md),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: colors.border, width: 2)),
            ),
            child: _LineList(
              lines: line.lines,
              fields: fields,
              conditions: false,
            ),
          ),
        ],
      ),
      _TextLine(:final controller) => FieldEditor(controller: controller),
      _SourceLine(:final controller) => TextField(
        controller: controller,
        minLines: 1,
        maxLines: null,
        style: type.body.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const [MemukiType.bodyFamily],
        ),
        decoration: InputDecoration(
          labelText: l10n.templateSource,
          isDense: true,
          filled: true,
          fillColor: colors.surfaceSunken,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Radii.sm),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.xs + 2,
            right: Spacing.sm,
          ),
          child: Icon(
            switch (line) {
              _FieldLine() => MemukiIcons.field,
              _IfLine() => MemukiIcons.condition,
              _TextLine() => MemukiIcons.text,
              _SourceLine() => MemukiIcons.source,
            },
            size: 18,
            color: colors.textMuted,
          ),
        ),
        Expanded(child: body),
        const SizedBox(width: Spacing.xs),
        IconAction(
          icon: MemukiIcons.moveUp,
          semanticLabel: l10n.templateMoveUp,
          onPressed: first ? null : () => lines.move(line, -1),
        ),
        IconAction(
          icon: MemukiIcons.moveDown,
          semanticLabel: l10n.templateMoveDown,
          onPressed: last ? null : () => lines.move(line, 1),
        ),
        IconAction(
          icon: MemukiIcons.delete,
          semanticLabel: l10n.templateRemove,
          onPressed: () => lines.remove(line),
        ),
      ],
    );
  }
}

String _roleLabel(AppLocalizations l10n, String role) => switch (role) {
  'prompt' => l10n.templateRolePrompt,
  'reading' => l10n.templateRoleReading,
  'answer' => l10n.templateRoleAnswer,
  'example' => l10n.templateRoleExample,
  _ => role,
};

/// Picks one of [fields]. A name the note type does not have stays picked,
/// marked as missing, until another is picked.
class _FieldPicker extends StatelessWidget {
  const _FieldPicker({
    required this.label,
    required this.fields,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> fields;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuChip<String>(
      semanticLabel: label,
      choices: [
        for (final name in fields) Choice(name, name),
        if (!fields.contains(selected))
          Choice(selected, l10n.templateMissingField(selected)),
      ],
      selected: selected,
      onSelected: onSelected,
    );
  }
}

/// A field that can be required: its name, with a check when it is.
class _CheckChip extends StatelessWidget {
  const _CheckChip({
    required this.label,
    required this.checked,
    required this.onPressed,
  });

  final String label;
  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.sm);
    return Semantics(
      checked: checked,
      child: Pressable(
        onPressed: onPressed,
        borderRadius: radius,
        builder: (context, state) => AnimatedContainer(
          duration: Motion.quick,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm + 2,
            vertical: context.layout.dense(Spacing.xs + 2),
          ),
          decoration: BoxDecoration(
            color: checked
                ? colors.accent.soft
                : state.hovered || state.pressed
                ? colors.border
                : colors.surfaceSunken,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                checked ? MemukiIcons.check : MemukiIcons.add,
                size: 16,
                color: checked ? colors.accent.onSoft : colors.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                label,
                style: context.type.label.copyWith(
                  color: checked ? colors.accent.onSoft : colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
