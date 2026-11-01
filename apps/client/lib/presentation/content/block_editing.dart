import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/menu.dart';
import '../components/pressable.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'content_view.dart';

/// Called with content as it changes. Changes with the same non-null
/// [merge] one after another are one step of undo, such as typing a word.
typedef ContentChanged = void Function(
  List<ContentNode> nodes, {
  Object? merge,
});

/// Called with a mark as it changes; see [ContentChanged] for [merge].
typedef MarkChanged = void Function(MarkNode mark, {Object? merge});

/// Builds the editor of one block, such as a dictionary sense.
typedef BlockEditorBuilder = Widget Function(
  BuildContext context,
  BlockEditorContext block,
);

/// What is dragged out of the toolbox: a new block of [key].
@immutable
class ToolboxDrag {
  const ToolboxDrag(this.key);

  final String key;
}

/// How the field editor puts in and edits one kind of block: a mark that
/// stands on lines of its own, such as a list, or that belongs in one, such
/// as a sense's tags. The kind's meaning is in its `MarkKind`; marks within
/// text are edited by their `MarkEditing`.
///
/// Kinds [offered] that [create] blocks are in the toolbox, to drag into the
/// field or put in at the cursor. A kind without an [editor] is edited as
/// source.
@immutable
class BlockEditing {
  const BlockEditing({
    required this.label,
    this.icon,
    this.create,
    this.editor,
    this.block = true,
    this.topLevel = false,
    this.accepts = const {},
    this.offered = true,
  });

  /// Its name in the toolbox and over its editor.
  final String Function(AppLocalizations l10n) label;

  final IconData? icon;

  /// A new block of the kind, to put in.
  final MarkNode Function()? create;

  final BlockEditorBuilder? editor;

  /// Whether it stands on lines of its own. A kind that is not, such as a
  /// tag, stays in text, styled by its `MarkEditing`, except where a block
  /// edits it, as a sense does its tags.
  final bool block;

  /// Whether it may be put in at a field's top level.
  final bool topLevel;

  /// The kinds that may be put in it from the toolbox.
  final Set<String> accepts;

  /// Whether the toolbox offers it. A kind that only belongs inside one
  /// block, as a tag does in a sense, is put in by that block's editor.
  final bool offered;

  /// The entries for the built-in kinds.
  static final Map<String, BlockEditing> builtIn = {
    'sense': BlockEditing(
      label: (l10n) => l10n.editorSense,
      icon: MemukiIcons.sense,
      create: () => const MarkNode(
        'sense',
        content: [
          MarkNode('list', content: [MarkNode('item', content: [])]),
        ],
      ),
      editor: _sense,
      topLevel: true,
      accepts: const {'list', 'example'},
    ),
    'list': BlockEditing(
      label: (l10n) => l10n.editorList,
      icon: MemukiIcons.list,
      create: () =>
          const MarkNode('list', content: [MarkNode('item', content: [])]),
      editor: _list,
      topLevel: true,
    ),
    'example': BlockEditing(
      label: (l10n) => l10n.editorExample,
      icon: MemukiIcons.example,
      create: () => const MarkNode(
        'example',
        content: [MarkNode('translation', content: [])],
      ),
      editor: _example,
      topLevel: true,
    ),
    'tag': BlockEditing(
      label: (l10n) => l10n.editorTag,
      icon: MemukiIcons.tag,
      create: () => const MarkNode('tag', args: ['pos', ''], content: []),
      editor: (_, block) => _TagEditor(block: block),
      block: false,
      offered: false,
    ),
    'item': BlockEditing(
      label: (l10n) => l10n.editorItem,
      editor: (context, block) => _bulleted(
        context,
        block.content(block.mark.content ?? const [], block.changeContent),
      ),
    ),
    'translation': BlockEditing(
      label: (l10n) => l10n.editorTranslation,
      editor: (_, block) =>
          block.content(block.mark.content ?? const [], block.changeContent),
    ),
    'forms': BlockEditing(label: (_) => 'forms'),
  };

  /// A meaning of a word: its tags in a row, with a button to add one, then
  /// its glosses, which stay, and its examples.
  static Widget _sense(BuildContext context, BlockEditorContext block) {
    final content = block.mark.content ?? const [];
    bool isTag(ContentNode n) => n is MarkNode && n.key == 'tag';
    final tags = [
      for (final n in content)
        if (isTag(n)) n as MarkNode,
    ];
    final rest = [
      for (final n in content)
        if (!isTag(n)) n,
    ];
    void changed(
      List<ContentNode> tags,
      List<ContentNode> rest, {
      Object? merge,
    }) => block.changeContent([...tags, ...rest], merge: merge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TagRow(
          onAdd: () {
            if (block.create('tag') case final tag?) {
              changed([...tags, tag], rest);
            }
          },
          children: [
            for (final (i, tag) in tags.indexed)
              block.child(
                tag,
                key: ValueKey(('tag', i)),
                onChanged: (tag, {merge}) =>
                    changed([...tags]..[i] = tag, rest, merge: merge),
                onRemove: () => changed([...tags]..removeAt(i), rest),
              ),
          ],
        ),
        block.content(
          rest,
          (rest, {merge}) => changed(tags, rest, merge: merge),
          accepts: const {'list', 'example'},
          text: false,
          kept: const {'list'},
        ),
      ],
    );
  }

  /// Items, each edited in place, with a button to add one at the end. Enter
  /// in an item starts the next.
  static Widget _list(BuildContext context, BlockEditorContext block) {
    final l10n = AppLocalizations.of(context);
    final items = block.mark.content ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, node) in items.indexed)
          if (node case MarkNode(key: 'item', :final content))
            _bulleted(
              context,
              block.content(
                content ?? const [],
                (content, {merge}) => block.changeContent(
                  [...items]..[i] = node.copyWith(content: content),
                  merge: merge,
                ),
                key: ValueKey(('item', i)),
                autofocus: content?.isEmpty ?? true,
                onEnter: () => block.changeContent(
                  [...items]
                    ..insert(i + 1, const MarkNode('item', content: [])),
                ),
              ),
              onRemove: () => block.changeContent([...items]..removeAt(i)),
              removeLabel: l10n.editorRemoveItem,
            )
          else if (node case TextNode(:final text) when text.trim().isEmpty)
            const SizedBox.shrink()
          else
            ContentView([node]),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: QuietButton(
            label: l10n.editorAddItem,
            icon: MemukiIcons.add,
            onPressed: () => block.changeContent([
              ...items,
              const MarkNode('item', content: []),
            ]),
          ),
        ),
      ],
    );
  }

  /// A sentence and, under it, its translation.
  static Widget _example(BuildContext context, BlockEditorContext block) {
    final l10n = AppLocalizations.of(context);
    final content = block.mark.content ?? const [];
    final at = content.indexWhere(
      (n) => n is MarkNode && n.key == 'translation',
    );
    final sentence = at < 0 ? content : content.sublist(0, at);
    final translation = at < 0 ? null : content[at] as MarkNode;
    final after = at < 0 ? const <ContentNode>[] : content.sublist(at + 1);
    void changed(
      List<ContentNode> sentence,
      List<ContentNode>? translated, {
      Object? merge,
    }) => block.changeContent([
      ...sentence,
      if (translated != null)
        (translation ?? const MarkNode('translation')).copyWith(
          content: translated,
        ),
      ...after,
    ], merge: merge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        block.content(
          sentence,
          (sentence, {merge}) =>
              changed(sentence, translation?.content, merge: merge),
          key: const ValueKey('sentence'),
          hint: l10n.editorSentence,
          autofocus: sentence.isEmpty,
        ),
        block.content(
          translation?.content ?? const [],
          (translated, {merge}) => changed(sentence, translated, merge: merge),
          key: const ValueKey('translation'),
          hint: l10n.editorTranslation,
          style: context.type.caption.copyWith(color: context.colors.textMuted),
        ),
      ],
    );
  }

  /// [child] after a bullet, with a button to remove it when [onRemove] is
  /// given.
  static Widget _bulleted(
    BuildContext context,
    Widget child, {
    VoidCallback? onRemove,
    String? removeLabel,
  }) {
    final colors = context.colors;
    return Row(
      children: [
        Text('•', style: context.type.body.copyWith(color: colors.textMuted)),
        const SizedBox(width: Spacing.sm),
        Expanded(child: child),
        if (onRemove != null)
          IconButton(
            tooltip: removeLabel,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            color: colors.textFaint,
            icon: const Icon(MemukiIcons.close),
            onPressed: onRemove,
          ),
      ],
    );
  }
}

/// What a [BlockEditorBuilder] edits: one mark, with ways to change and
/// remove it and to build editors for the content inside it.
@immutable
class BlockEditorContext {
  const BlockEditorContext({
    required this.mark,
    required this.onChanged,
    required this.onRemove,
    required this.contentBuilder,
    required this.childBuilder,
    required this.create,
  });

  final MarkNode mark;
  final MarkChanged onChanged;
  final VoidCallback onRemove;

  final Widget Function(
    List<ContentNode> nodes,
    ContentChanged onChanged, {
    Key? key,
    Set<String> accepts,
    bool text,
    String? hint,
    bool autofocus,
    TextStyle? style,
    VoidCallback? onEnter,
    Set<String> kept,
  })
  contentBuilder;

  final Widget Function(
    MarkNode mark, {
    Key? key,
    required MarkChanged onChanged,
    required VoidCallback onRemove,
  })
  childBuilder;

  /// A new block of [key], as its entry creates one, or null when it has no
  /// entry that does.
  final MarkNode? Function(String key) create;

  /// Changes the mark's content.
  void changeContent(List<ContentNode> content, {Object? merge}) =>
      onChanged(mark.copyWith(content: content), merge: merge);

  /// An editor of [nodes]: text with its marks, and the blocks between,
  /// with room to drop blocks of [accepts] from the toolbox. With [text]
  /// false, there is no line to type on when there is nothing but blocks.
  /// With [onEnter], Enter calls it rather than starting a new line. Blocks
  /// of [kept] have no button to remove them.
  Widget content(
    List<ContentNode> nodes,
    ContentChanged onChanged, {
    Key? key,
    Set<String> accepts = const {},
    bool text = true,
    String? hint,
    bool autofocus = false,
    TextStyle? style,
    VoidCallback? onEnter,
    Set<String> kept = const {},
  }) => contentBuilder(
    nodes,
    onChanged,
    key: key,
    accepts: accepts,
    text: text,
    hint: hint,
    autofocus: autofocus,
    style: style,
    onEnter: onEnter,
    kept: kept,
  );

  /// The editor of [mark] from its own entry, without the frame around a
  /// block, as a sense shows its tags.
  Widget child(
    MarkNode mark, {
    Key? key,
    required MarkChanged onChanged,
    required VoidCallback onRemove,
  }) => childBuilder(mark, key: key, onChanged: onChanged, onRemove: onRemove);
}

/// A sense's tags, side by side, with a button to add one under them, which
/// stands in for them while there are none.
class _TagRow extends StatelessWidget {
  const _TagRow({required this.onAdd, required this.children});

  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(Radii.xs);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.xs,
        children: [
          if (children.isNotEmpty)
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
          Pressable(
            onPressed: onAdd,
            semanticLabel: l10n.editorAddTag,
            borderRadius: radius,
            builder: (context, state) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs + 2,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: state.hovered ? colors.surfaceSunken : null,
                borderRadius: radius,
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MemukiIcons.tag, size: 14, color: colors.textFaint),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    l10n.editorAddTag,
                    style: context.type.caption.copyWith(
                      color: colors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tag as it renders; pressed, its category and label to edit. Its code,
/// which a dictionary gives, is kept but not shown. A new tag, without a
/// label, starts open.
class _TagEditor extends StatefulWidget {
  const _TagEditor({required this.block});

  final BlockEditorContext block;

  @override
  State<_TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<_TagEditor> {
  MarkNode get _mark => widget.block.mark;

  late var _open = _label.isEmpty;
  late final _labelField = TextEditingController(text: _label);

  String get _label => [
    for (final n in _mark.content ?? const <ContentNode>[])
      if (n is TextNode) n.text,
  ].join();

  static const _categories = ['pos', 'misc', 'field', 'dialect'];

  @override
  void didUpdateWidget(_TagEditor old) {
    super.didUpdateWidget(old);
    // Follow changes from elsewhere, such as undo.
    if (_labelField.text != _label) _labelField.text = _label;
  }

  @override
  void dispose() {
    _labelField.dispose();
    super.dispose();
  }

  void _setArg(int i, String value) {
    final args = [..._mark.args];
    while (args.length <= i) {
      args.add('');
    }
    args[i] = value;
    widget.block.onChanged(_mark.copyWith(args: args), merge: (this, i));
  }

  void _setLabel(String value) => widget.block.onChanged(
    _mark.copyWith(content: [if (value.isNotEmpty) ContentNode.text(value)]),
    merge: (this, 'label'),
  );

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return Pressable(
        onPressed: () => setState(() => _open = true),
        semanticLabel: _label,
        borderRadius: BorderRadius.circular(Radii.xs),
        builder: (context, _) => ContentView([_mark]),
      );
    }
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    InputDecoration field(String label) => InputDecoration(
      isDense: true,
      labelText: label,
      filled: true,
      fillColor: colors.surfaceSunken,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide.none,
      ),
    );
    final category = _mark.args.firstOrNull ?? '';
    return Container(
      padding: const EdgeInsets.all(Spacing.xs),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Wrap(
        spacing: Spacing.xs,
        runSpacing: Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          MenuChip<String>(
            semanticLabel: l10n.editorTagCategory,
            choices: [
              for (final c in _categories) Choice(c, _categoryLabel(l10n, c)),
              if (!_categories.contains(category)) Choice(category, category),
            ],
            selected: category,
            onSelected: (c) => _setArg(0, c),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _labelField,
              autofocus: _label.isEmpty,
              style: type.body,
              decoration: field(l10n.editorTagLabel),
              onChanged: _setLabel,
              onSubmitted: (_) => setState(() => _open = false),
            ),
          ),
          IconButton(
            tooltip: l10n.editorDone,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            icon: const Icon(MemukiIcons.check),
            onPressed: () => setState(() => _open = false),
          ),
          IconButton(
            tooltip: l10n.editorRemoveMark,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            color: colors.textFaint,
            icon: const Icon(MemukiIcons.delete),
            onPressed: widget.block.onRemove,
          ),
        ],
      ),
    );
  }

  static String _categoryLabel(AppLocalizations l10n, String category) =>
      switch (category) {
        'pos' => l10n.editorTagPos,
        'misc' => l10n.editorTagMisc,
        'field' => l10n.editorTagField,
        'dialect' => l10n.editorTagDialect,
        _ => category,
      };
}
