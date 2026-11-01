import 'package:flutter/material.dart';

import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/template_layout.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/buttons.dart';
import '../components/check_chip.dart';
import '../components/icons.dart';
import '../components/menu.dart';
import '../components/panel.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_type.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'field_controller.dart';
import 'field_editor.dart';

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
              CheckChip(
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
      FieldController(content)..addListener(onChanged),
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

  /// Moves the line at [from] to [to], as a [ReorderableList] reports a
  /// drag.
  void reorder(int from, int to) {
    items.insert(to, items.removeAt(from));
    onChanged();
  }

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

  final FieldController controller;

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

/// A side of the card: its lines, and a button to add more.
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

/// [lines], one under another and reordered by dragging, then a button to
/// add a line. Conditions are offered only when [conditions] is set, so they
/// do not nest.
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
        ReorderableList(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lines.items.length,
          onReorderItem: lines.reorder,
          proxyDecorator: (child, _, _) => DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(Radii.sm),
              boxShadow: paperShadow(colors),
            ),
            child: child,
          ),
          itemBuilder: (context, i) {
            final line = lines.items[i];
            return Padding(
              key: line.key,
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _LineRow(
                index: i,
                line: line,
                lines: lines,
                fields: fields,
              ),
            );
          },
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Menu(
            items: [
              MenuItem(
                icon: MemukiIcons.field,
                label: l10n.templateAddField,
                description: l10n.templateAddFieldHint,
                onPressed: first == null
                    ? null
                    : () => lines.add(FieldBlock(first)),
              ),
              MenuItem(
                icon: MemukiIcons.text,
                label: l10n.templateAddText,
                description: l10n.templateAddTextHint,
                onPressed: () => lines.add(const TextBlock([])),
              ),
              if (conditions)
                MenuItem(
                  icon: MemukiIcons.condition,
                  label: l10n.templateAddCondition,
                  description: l10n.templateAddConditionHint,
                  onPressed: first == null
                      ? null
                      : () => lines.add(IfBlock(first, const [])),
                ),
            ],
            builder: (context, toggle) => QuietButton(
              icon: MemukiIcons.add,
              label: conditions
                  ? l10n.templateAddLine
                  : l10n.templateAddInCondition,
              onPressed: toggle,
            ),
          ),
        ),
      ],
    );
  }
}

/// One line: a handle to drag it, what it edits, and a menu to move or
/// remove it.
class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.index,
    required this.line,
    required this.lines,
    required this.fields,
  });

  final int index;
  final _Line line;
  final _Lines lines;
  final List<String> fields;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    final line = this.line;
    final Widget body = switch (line) {
      _FieldLine(:final field) => _Sentence(
        l10n.templateFieldAs('{field}', '{role}'),
        {
          'field': _FieldPicker(
            label: l10n.templateField,
            fields: fields,
            selected: field.name,
            onSelected: (name) {
              line.field = field.withName(name);
              lines.changed();
            },
          ),
          'role': MenuChip<String?>(
            semanticLabel: l10n.templateRole,
            tone: _roleTone(context, field.role),
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
        },
      ),
      _IfLine(:final name) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sentence(l10n.templateIfFilled('{field}'), {
            'field': _FieldPicker(
              label: l10n.templateConditionField,
              fields: fields,
              selected: name,
              onSelected: (name) {
                line.name = name;
                lines.changed();
              },
            ),
          }),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsetsDirectional.only(start: Spacing.sm),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: colors.border, width: 2),
              ),
            ),
            child: _LineList(
              lines: line.lines,
              fields: fields,
              conditions: false,
            ),
          ),
        ],
      ),
      _TextLine(:final controller) => FieldEditor(
        controller: controller,
        blocks: const {},
      ),
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
    final count = lines.items.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Semantics(
            label: l10n.templateDrag,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xs,
                  vertical: Spacing.xs + 2,
                ),
                child: Icon(
                  MemukiIcons.drag,
                  size: 18,
                  color: colors.textFaint,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(child: body),
        const SizedBox(width: Spacing.xs),
        Menu(
          items: [
            MenuItem(
              icon: MemukiIcons.moveUp,
              label: l10n.templateMoveUp,
              onPressed: index == 0 ? null : () => lines.move(line, -1),
            ),
            MenuItem(
              icon: MemukiIcons.moveDown,
              label: l10n.templateMoveDown,
              onPressed: index == count - 1 ? null : () => lines.move(line, 1),
            ),
            MenuItem(
              icon: MemukiIcons.delete,
              label: l10n.templateRemove,
              onPressed: () => lines.remove(line),
            ),
          ],
          builder: (context, toggle) => IconAction(
            icon: MemukiIcons.more,
            semanticLabel: l10n.templateLineMenu,
            onPressed: toggle,
          ),
        ),
      ],
    );
  }
}

/// [sentence] laid out with the controls in [parts] in place of the
/// `{name}` placeholders it holds, and its words as muted labels, wrapping
/// as a sentence does.
class _Sentence extends StatelessWidget {
  const _Sentence(this.sentence, this.parts);

  final String sentence;
  final Map<String, Widget> parts;

  static final _placeholder = RegExp(r'\{(\w+)\}');

  @override
  Widget build(BuildContext context) {
    final style = context.type.label.copyWith(color: context.colors.textMuted);
    final children = <Widget>[];
    var at = 0;
    for (final match in _placeholder.allMatches(sentence)) {
      final words = sentence.substring(at, match.start).trim();
      if (words.isNotEmpty) children.add(Text(words, style: style));
      children.add(parts[match.group(1)] ?? const SizedBox.shrink());
      at = match.end;
    }
    final rest = sentence.substring(at).trim();
    if (rest.isNotEmpty) children.add(Text(rest, style: style));
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// The tint of a role's picker, so roles are told apart at a glance. None
/// for no role, or one cards do not style.
ToneColors? _roleTone(BuildContext context, String? role) {
  final accent = switch (role) {
    'prompt' => MemukiAccent.coral,
    'reading' => MemukiAccent.blue,
    'answer' => MemukiAccent.green,
    'example' => MemukiAccent.mustard,
    _ => null,
  };
  return accent == null ? null : context.colors.swatches[accent];
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
