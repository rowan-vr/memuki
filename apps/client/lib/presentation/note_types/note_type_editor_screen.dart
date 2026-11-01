import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/content/card_renderer.dart';
import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/field_references.dart';
import '../../domain/content/mark_kinds.dart';
import '../../domain/content/template_layout.dart';
import '../../domain/ids.dart';
import '../../domain/note_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../storage/providers.dart';
import '../../storage/repositories/repository_exceptions.dart';
import '../components/buttons.dart';
import '../components/check_chip.dart';
import '../components/dialogs.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../content/block_editing.dart';
import '../content/card_view.dart';
import '../content/inline_editor.dart' show markLabel;
import '../content/mark_editing.dart';
import '../content/template_editor.dart';
import '../routing/router.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'note_types_screen.dart';

/// The issues that keep a template from being read as a card: what stands
/// at its top level, and how often.
const _structural = {
  MarkIssueKind.missing,
  MarkIssueKind.loose,
  MarkIssueKind.repeated,
  MarkIssueKind.misplaced,
};

/// Edits a note type: its name, its fields and how each is checked, and its
/// cards. Changes are kept in a draft until saved, and saving waits until
/// every card's template is sound.
class NoteTypeEditorScreen extends ConsumerStatefulWidget {
  const NoteTypeEditorScreen({super.key, required this.id});

  final NoteTypeId id;

  @override
  ConsumerState<NoteTypeEditorScreen> createState() =>
      _NoteTypeEditorScreenState();
}

class _NoteTypeEditorScreenState extends ConsumerState<NoteTypeEditorScreen> {
  final _name = TextEditingController();
  NoteType? _saved;
  NoteType? _draft;

  /// Why the last save or delete failed.
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final noteType = await ref
        .read(noteTypeRepositoryProvider)
        .noteType(widget.id);
    if (!mounted || noteType == null) return;
    setState(() {
      _saved = noteType;
      _draft = noteType;
      _name.text = noteType.name;
    });
  }

  bool get _dirty => _draft != _saved || _name.text != _saved?.name;

  void _change(NoteType draft) => setState(() {
    _draft = draft;
    _error = null;
  });

  /// What keeps the draft from being saved, explained.
  List<String> _problems(AppLocalizations l10n) {
    final draft = _draft!;
    final name = _name.text.trim();
    final others = switch (ref.watch(noteTypesProvider(draft.collectionId))) {
      AsyncData(:final value) => value.where((t) => t.id != draft.id),
      _ => const <NoteType>[],
    };
    return [
      if (name.isEmpty)
        l10n.noteTypeNameEmpty
      else if (others.any((t) => t.name == name))
        l10n.noteTypeNameTaken,
      for (final template in draft.templates) ...[
        if (draft.missingFields(template) case final missing
            when missing.isNotEmpty)
          l10n.noteTypeMissingFields(template.name, missing.join(', ')),
        if (MarkKinds.builtIn
            .check(parseContent(template.source).nodes, MarkScope.template)
            .any((issue) => _structural.contains(issue.kind)))
          l10n.noteTypeCardProblem(template.name),
      ],
    ];
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final noteType = _draft!.copyWith(name: _name.text.trim());
    setState(() => _busy = true);
    try {
      await ref.read(noteTypeRepositoryProvider).updateNoteType(noteType);
      if (!mounted) return;
      setState(() {
        _saved = noteType;
        _draft = noteType;
        _name.text = noteType.name;
      });
    } on EntityInUseException {
      if (mounted) setState(() => _error = l10n.noteTypeCardStudied);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirm(
      context,
      title: l10n.noteTypeDeleteTitle(_saved!.name),
      message: l10n.noteTypeDeleteBody,
      confirm: l10n.noteTypeDeleteConfirm,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(noteTypeRepositoryProvider).deleteNoteType(widget.id);
      if (mounted) const NoteTypesRoute().go(context);
    } on EntityInUseException {
      if (mounted) setState(() => _error = l10n.noteTypeInUse);
    }
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    final discard = await confirm(
      context,
      title: l10n.noteTypeDiscardTitle,
      message: l10n.noteTypeDiscardBody,
      confirm: l10n.noteTypeDiscard,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = _draft;
    if (draft == null) {
      return Screen(
        title: l10n.settingsNoteTypes,
        body: const SizedBox.shrink(),
      );
    }
    final problems = _problems(l10n);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Screen(
        title: _saved!.name,
        actions: [
          IconAction(
            icon: MemukiIcons.delete,
            semanticLabel: l10n.noteTypeDelete,
            onPressed: _busy ? null : _delete,
          ),
          Button(
            label: l10n.commonSave,
            onPressed: _dirty && problems.isEmpty && !_busy ? _save : null,
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if ([?_error, ...problems] case final shown
                        when shown.isNotEmpty) ...[
                      _Problems(problems: shown),
                      const SizedBox(height: Spacing.lg),
                    ],
                    _TextInput(controller: _name, label: l10n.noteTypeName),
                    const SizedBox(height: Spacing.xl),
                    SectionHeader(title: l10n.noteTypeFields),
                    _Fields(draft: draft, onChanged: _change),
                    const SizedBox(height: Spacing.xl),
                    SectionHeader(title: l10n.noteTypeCards),
                    _Cards(draft: draft, onChanged: _change),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Why the draft cannot be saved, or why saving failed.
class _Problems extends StatelessWidget {
  const _Problems({required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, problem) in problems.indexed) ...[
            if (i > 0) const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(MemukiIcons.warning, size: 18, color: colors.danger),
                const SizedBox(width: Spacing.sm),
                Expanded(child: Text(problem, style: context.type.body)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A one-line text field in the look of the app's inputs.
class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    this.hint,
    this.error,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? error;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    style: context.type.body,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: error,
      isDense: true,
      filled: true,
      fillColor: context.colors.surfaceSunken,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

/// A name that is put into the draft only when it is done: on enter or when
/// focus leaves, and only when [validate] finds nothing wrong with it. Until
/// then it shows what is wrong, and a wrong name goes back to [name].
class _NameInput extends StatefulWidget {
  const _NameInput({
    required this.name,
    required this.label,
    required this.validate,
    required this.onCommit,
  });

  final String name;
  final String label;
  final String? Function(String name) validate;
  final ValueChanged<String> onCommit;

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  late final _controller = TextEditingController(text: widget.name);
  final _focus = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_NameInput old) {
    super.didUpdateWidget(old);
    if (widget.name != old.name && !_focus.hasFocus) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final name = _controller.text.trim();
    if (name == widget.name) return;
    if (widget.validate(name) != null) {
      setState(() => _error = null);
      _controller.text = widget.name;
      return;
    }
    widget.onCommit(name);
  }

  @override
  Widget build(BuildContext context) => _TextInput(
    controller: _controller,
    focusNode: _focus,
    label: widget.label,
    error: _error,
    onChanged: (text) {
      final name = text.trim();
      setState(
        () => _error = name == widget.name ? null : widget.validate(name),
      );
    },
    onSubmitted: (_) => _commit(),
  );
}

/// The smallest numbered name made by [name] that none of [taken] has.
String _freeName(String Function(int number) name, Iterable<String> taken) {
  final names = taken.toSet();
  var number = names.length + 1;
  while (names.contains(name(number))) {
    number++;
  }
  return name(number);
}

/// The fields of [draft], in order, to reorder, rename, set up, and remove.
class _Fields extends StatelessWidget {
  const _Fields({required this.draft, required this.onChanged});

  final NoteType draft;
  final ValueChanged<NoteType> onChanged;

  void _reorder(int from, int to) {
    final fields = [...draft.fields];
    final field = fields.removeAt(from);
    fields.insert(to, field);
    onChanged(draft.copyWith(fields: fields));
  }

  void _add(AppLocalizations l10n) {
    final name = _freeName(
      l10n.noteTypeDefaultField,
      draft.fields.map((f) => f.name),
    );
    onChanged(
      draft.copyWith(
        fields: [
          ...draft.fields,
          FieldDefinition(id: FieldDefinitionId.generate(), name: name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: _reorder,
          children: [
            for (final (i, field) in draft.fields.indexed)
              Padding(
                key: ValueKey(field.id),
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: _FieldCard(
                  index: i,
                  draft: draft,
                  field: field,
                  onChanged: onChanged,
                ),
              ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: QuietButton(
            label: l10n.noteTypeAddField,
            icon: MemukiIcons.add,
            onPressed: () => _add(l10n),
          ),
        ),
      ],
    );
  }
}

/// One field: its name, and folded under it, its language and checks.
class _FieldCard extends StatefulWidget {
  const _FieldCard({
    required this.index,
    required this.draft,
    required this.field,
    required this.onChanged,
  });

  final int index;
  final NoteType draft;
  final FieldDefinition field;
  final ValueChanged<NoteType> onChanged;

  @override
  State<_FieldCard> createState() => _FieldCardState();
}

class _FieldCardState extends State<_FieldCard> {
  late final _language = TextEditingController(
    text: widget.field.language ?? '',
  );
  bool _open = false;

  @override
  void dispose() {
    _language.dispose();
    super.dispose();
  }

  NoteType get _draft => widget.draft;
  FieldDefinition get _field => widget.field;

  void _set(FieldDefinition field) => widget.onChanged(
    _draft.copyWith(
      fields: [for (final f in _draft.fields) f.id == field.id ? field : f],
    ),
  );

  String? _validate(AppLocalizations l10n, String name) {
    if (name.isEmpty) return l10n.noteTypeNameEmpty;
    if (_draft.fields.any((f) => f.id != _field.id && f.name == name)) {
      return l10n.noteTypeNameTaken;
    }
    return null;
  }

  Future<void> _remove(AppLocalizations l10n) async {
    final used = _draft.templatesUsing(_field.id);
    final ok = await confirm(
      context,
      title: l10n.noteTypeRemoveFieldTitle(_field.name),
      message: used.isEmpty
          ? l10n.noteTypeRemoveFieldUnused
          : l10n.noteTypeRemoveFieldUsed(used.map((t) => t.name).join(', ')),
      confirm: l10n.noteTypeRemove,
    );
    if (ok) widget.onChanged(_draft.removeField(_field.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xs),
                  child: Icon(
                    MemukiIcons.drag,
                    size: 18,
                    color: colors.textFaint,
                    semanticLabel: l10n.templateDrag,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: _NameInput(
                  name: _field.name,
                  label: l10n.noteTypeFieldName,
                  validate: (name) => _validate(l10n, name),
                  onCommit: (name) =>
                      widget.onChanged(_draft.renameField(_field.id, name)),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              IconAction(
                icon: _open ? MemukiIcons.close : MemukiIcons.settings,
                semanticLabel: l10n.noteTypeFieldSettings,
                onPressed: () => setState(() => _open = !_open),
              ),
              IconAction(
                icon: MemukiIcons.delete,
                semanticLabel: l10n.noteTypeRemoveField,
                onPressed: _draft.fields.length > 1
                    ? () => _remove(l10n)
                    : null,
              ),
            ],
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xl,
                Spacing.sm,
                Spacing.sm,
                Spacing.xs,
              ),
              child: _FieldSettings(
                draft: _draft,
                field: _field,
                language: _language,
                onField: _set,
                onChanged: widget.onChanged,
              ),
            ),
        ],
      ),
    );
  }
}

/// A field's language, whether it must be filled, whether notes are checked
/// for duplicates by it, and the marks its values may have.
class _FieldSettings extends StatelessWidget {
  const _FieldSettings({
    required this.draft,
    required this.field,
    required this.language,
    required this.onField,
    required this.onChanged,
  });

  final NoteType draft;
  final FieldDefinition field;
  final TextEditingController language;
  final ValueChanged<FieldDefinition> onField;
  final ValueChanged<NoteType> onChanged;

  void _toggleMark(String key, Set<String> offerable) {
    final allowed = {...field.allowedMarks ?? offerable};
    if (!allowed.remove(key)) allowed.add(key);
    onField(
      field.copyWith(
        allowedMarks: allowed.containsAll(offerable) ? null : allowed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final marks = _offerableMarks(context);
    final checking = draft.duplicateCheck == field.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TextInput(
          controller: language,
          label: l10n.noteTypeFieldLanguage,
          hint: l10n.noteTypeFieldLanguageHint,
          onChanged: (text) {
            final tag = text.trim();
            onField(field.copyWith(language: tag.isEmpty ? null : tag));
          },
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            CheckChip(
              label: l10n.noteTypeFieldRequired,
              checked: field.isRequired,
              onPressed: () =>
                  onField(field.copyWith(isRequired: !field.isRequired)),
            ),
            CheckChip(
              label: l10n.noteTypeFieldDuplicates,
              checked: checking,
              onPressed: () => onChanged(
                draft.copyWith(duplicateCheck: checking ? null : field.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(l10n.noteTypeFieldMarks, style: context.type.label),
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.xs,
          runSpacing: Spacing.xs,
          children: [
            CheckChip(
              label: l10n.noteTypeFieldAllMarks,
              checked: field.allowedMarks == null,
              onPressed: () => onField(
                field.copyWith(
                  allowedMarks: field.allowedMarks == null ? const {} : null,
                ),
              ),
            ),
            for (final MapEntry(:key, value: label) in marks.entries)
              CheckChip(
                label: label,
                checked: field.allows(key),
                onPressed: () => _toggleMark(key, marks.keys.toSet()),
              ),
          ],
        ),
      ],
    );
  }
}

/// The labels of the marks the field editor offers, by key: those within
/// text from its toolbar, then the blocks in its toolbox.
Map<String, String> _offerableMarks(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return {
    for (final kind in MarkKinds.builtIn.all)
      if (kind.scopes.contains(MarkScope.field) &&
          !BlockEditing.builtIn.containsKey(kind.key) &&
          (MarkEditing.builtIn[kind.key]?.offered ?? true))
        kind.key: markLabel(context, MarkEditing.builtIn[kind.key], kind.key),
    for (final MapEntry(:key, :value) in BlockEditing.builtIn.entries)
      if (value.offered && value.create != null) key: value.label(l10n),
  };
}

/// The cards of [draft], one at a time, picked from a row of buttons, with its
/// template and a preview.
class _Cards extends StatefulWidget {
  const _Cards({required this.draft, required this.onChanged});

  final NoteType draft;
  final ValueChanged<NoteType> onChanged;

  @override
  State<_Cards> createState() => _CardsState();
}

class _CardsState extends State<_Cards> {
  StudyCardTemplateId? _picked;

  NoteType get _draft => widget.draft;

  /// The card being edited: the one picked, or the first when it is gone.
  StudyCardTemplate get _current =>
      _draft.templates.where((t) => t.id == _picked).firstOrNull ??
      _draft.templates.first;

  void _set(StudyCardTemplate template) => widget.onChanged(
    _draft.copyWith(
      templates: [
        for (final t in _draft.templates) t.id == template.id ? template : t,
      ],
    ),
  );

  void _add(AppLocalizations l10n) {
    final template = StudyCardTemplate(
      id: StudyCardTemplateId.generate(),
      name: _freeName(
        l10n.noteTypeDefaultCard,
        _draft.templates.map((t) => t.name),
      ),
      source: basicTemplateSource([for (final f in _draft.fields) f.name]),
    );
    _picked = template.id;
    widget.onChanged(
      _draft.copyWith(templates: [..._draft.templates, template]),
    );
  }

  void _remove(StudyCardTemplate template) => widget.onChanged(
    _draft.copyWith(
      templates: [
        for (final t in _draft.templates)
          if (t.id != template.id) t,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedChoice(
              choices: [for (final t in _draft.templates) Choice(t.id, t.name)],
              selected: current.id,
              onSelected: (id) => setState(() => _picked = id),
            ),
            QuietButton(
              label: l10n.noteTypeAddCard,
              icon: MemukiIcons.add,
              onPressed: () => _add(l10n),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        _CardEditor(
          key: ValueKey(current.id),
          draft: _draft,
          template: current,
          onChanged: _set,
          onRemove: _draft.templates.length > 1 ? () => _remove(current) : null,
        ),
      ],
    );
  }
}

enum _Mode { visual, source }

enum _Side { front, back }

/// One card: its name, its template arranged or as source, and how it looks
/// with each field showing its own name.
class _CardEditor extends StatefulWidget {
  const _CardEditor({
    super.key,
    required this.draft,
    required this.template,
    required this.onChanged,
    required this.onRemove,
  });

  final NoteType draft;
  final StudyCardTemplate template;
  final ValueChanged<StudyCardTemplate> onChanged;
  final VoidCallback? onRemove;

  @override
  State<_CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<_CardEditor> {
  late final _source = TextEditingController(text: widget.template.source);
  late TemplateLayout? _layout = _read(widget.template.source);
  late _Mode _mode = _layout == null ? _Mode.source : _Mode.visual;
  _Side _side = _Side.front;

  /// The source this editor last wrote or read.
  late String _known = widget.template.source;

  static TemplateLayout? _read(String source) =>
      TemplateLayout.read(parseContent(source).nodes);

  @override
  void didUpdateWidget(_CardEditor old) {
    super.didUpdateWidget(old);
    // Renaming or removing a field rewrites the template from outside.
    if (widget.template.source != _known) {
      _known = widget.template.source;
      _source.text = _known;
      _layout = _read(_known);
    }
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  void _write(String source) {
    _known = source;
    widget.onChanged(widget.template.copyWith(source: source));
  }

  void _arranged(TemplateLayout layout) {
    _layout = layout;
    final source = layout.write();
    _source.text = source;
    _write(source);
  }

  void _typed(String source) {
    _layout = _read(source);
    _write(source);
    setState(() {});
  }

  String? _validate(AppLocalizations l10n, String name) {
    if (name.isEmpty) return l10n.noteTypeNameEmpty;
    final others = widget.draft.templates.where(
      (t) => t.id != widget.template.id,
    );
    return others.any((t) => t.name == name) ? l10n.noteTypeNameTaken : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final fields = [for (final f in widget.draft.fields) f.name];
    final visual = _mode == _Mode.visual && _layout != null;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _NameInput(
                  name: widget.template.name,
                  label: l10n.noteTypeCardName,
                  validate: (name) => _validate(l10n, name),
                  onCommit: (name) =>
                      widget.onChanged(widget.template.copyWith(name: name)),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              IconAction(
                icon: MemukiIcons.delete,
                semanticLabel: l10n.noteTypeRemoveCard,
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedChoice(
              choices: [
                Choice(_Mode.visual, l10n.noteTypeVisual),
                Choice(_Mode.source, l10n.templateSource),
              ],
              selected: _mode,
              onSelected: (mode) => setState(() => _mode = mode),
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (_mode == _Mode.visual && _layout == null) ...[
            Text(
              l10n.noteTypeNotArrangeable,
              style: context.type.body.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          if (visual)
            TemplateEditor(
              layout: _layout!,
              fields: fields,
              onChanged: _arranged,
            )
          else
            TextField(
              controller: _source,
              onChanged: _typed,
              minLines: 3,
              maxLines: null,
              style: context.type.body.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: const [MemukiType.bodyFamily],
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceSunken,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.sm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(l10n.noteTypePreview, style: context.type.heading),
              ),
              SegmentedChoice(
                choices: [
                  Choice(_Side.front, l10n.templateFront),
                  Choice(_Side.back, l10n.templateBack),
                ],
                selected: _side,
                onSelected: (side) => setState(() => _side = side),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          CardView(
            card: renderCard(parseContent(_known).nodes, {
              for (final name in fields) name: [TextNode(name)],
            }),
            revealed: _side == _Side.back,
          ),
        ],
      ),
    );
  }
}
