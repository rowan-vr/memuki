import 'package:flutter/material.dart';

import '../../domain/content/card_renderer.dart';
import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/mark_kinds.dart';
import '../../domain/content/template_layout.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../components/rows.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../content/card_view.dart';
import '../content/content_view.dart';
import '../content/field_controller.dart';
import '../content/field_editor.dart';
import '../content/template_editor.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'content_warnings.dart';

/// Japanese and other text in monospaced source falls back to the body face.
const _monoFallback = [MemukiType.bodyFamily];

/// A debug-only page for trying the content format: source in, a preview,
/// the plain text, the canonical source, and any problems out, next to the
/// list of registered mark kinds.
///
/// A field is previewed as the card renderer shows it, and a template as the
/// card it makes from sample fields. It is a development tool, so its text
/// is not localized.
class ContentPlaygroundScreen extends StatefulWidget {
  const ContentPlaygroundScreen({super.key, this.kinds});

  /// The kinds to use; the built-in ones by default.
  final MarkKinds? kinds;

  @override
  State<ContentPlaygroundScreen> createState() =>
      _ContentPlaygroundScreenState();
}

const _samples = {
  MarkScope.field:
      '今日は{ruby てんき | 天気}が{em | いい}です。H{sub | 2}O, '
      '{lang zh-Hans | {ruby "nǐ hǎo" | 你好}}',
  MarkScope.template: '''
{# The word in front; its reading and meaning behind.}
{front |
  {field Word role=prompt}
}
{back |
  {field Reading role=reading}
  {field Meaning role=answer}
  {if Example | {field Example role=example}}
}
{requires Word}''',
};

/// The note a template is previewed with.
const _sampleFields = {
  'Word': '{ruby ねこ | 猫}',
  'Reading': 'ねこ',
  'Meaning': 'cat',
  'Example': '{ruby ねこ | 猫}が{em | 好き}です。',
};

class _ContentPlaygroundScreenState extends State<ContentPlaygroundScreen> {
  /// Fields and templates each keep their own source.
  final _sources = {
    for (final MapEntry(:key, :value) in _samples.entries)
      key: TextEditingController(text: value),
  };
  final _filter = TextEditingController();
  var _scope = MarkScope.field;
  final _open = <String>{};

  /// The field in the rich editor, while it is shown; it writes the field's
  /// source as it changes.
  FieldController? _rich;

  /// The template in the visual editor, while it is shown; it writes the
  /// template's source as it changes.
  TemplateLayout? _arranged;

  /// Whether the visual editor was asked for, but the template's top level
  /// does not fit it.
  var _unarrangeable = false;

  MarkKinds get _kinds => widget.kinds ?? MarkKinds.builtIn;

  @override
  void dispose() {
    for (final source in _sources.values) {
      source.dispose();
    }
    _filter.dispose();
    _rich?.dispose();
    super.dispose();
  }

  void _try(MarkKind kind) => setState(() {
    _scope = kind.scopes.first;
    _sources[_scope]!.text = kind.example;
    if (_scope == MarkScope.field) {
      _rich?.nodes = parseContent(kind.example).nodes;
    } else if (_arranged != null) {
      _arrange(visual: true);
    }
  });

  void _setVisual(bool visual) => setState(() => _arrange(visual: visual));

  void _arrange({required bool visual}) {
    _arranged = visual
        ? TemplateLayout.read(
            parseContent(_sources[MarkScope.template]!.text).nodes,
          )
        : null;
    _unarrangeable = visual && _arranged == null;
  }

  void _templateChanged(TemplateLayout layout) => setState(() {
    _arranged = layout;
    _sources[MarkScope.template]!.text = layout.write();
  });

  void _setRich(bool rich) => setState(() {
    _rich?.dispose();
    _rich = rich
        ? (FieldController(parseContent(_sources[MarkScope.field]!.text).nodes)
            ..addListener(_richChanged))
        : null;
  });

  void _richChanged() {
    final source = writeContent(_rich!.nodes);
    final field = _sources[MarkScope.field]!;
    if (field.text != source) field.text = source;
  }

  /// The kinds whose key or description contains the filter.
  List<MarkKind> _matching() {
    final query = _filter.text.trim().toLowerCase();
    return [
      for (final kind in _kinds.all)
        if (kind.key.toLowerCase().contains(query) ||
            kind.description.toLowerCase().contains(query))
          kind,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final playground = [
      _Playground(
        source: _sources[_scope]!,
        scope: _scope,
        kinds: _kinds,
        onScope: (scope) => setState(() => _scope = scope),
        rich: _scope == MarkScope.field ? _rich : null,
        onRich: _setRich,
        arranged: _scope == MarkScope.template ? _arranged : null,
        unarrangeable: _scope == MarkScope.template && _unarrangeable,
        onVisual: _setVisual,
        onTemplate: _templateChanged,
      ),
    ];
    final matching = _matching();
    final kinds = [
      SectionHeader(title: 'Mark kinds (${_kinds.all.length})'),
      TextField(
        controller: _filter,
        onChanged: (_) => setState(() {}),
        style: context.type.body,
        decoration: InputDecoration(
          hintText: 'Filter by key or description',
          prefixIcon: const Icon(MemukiIcons.search, size: 18),
          isDense: true,
          filled: true,
          fillColor: context.colors.surfaceSunken,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Radii.sm),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: Spacing.sm),
      if (matching.isEmpty)
        Text(
          'No kinds match.',
          style: context.type.body.copyWith(color: context.colors.textFaint),
        )
      else
        RowGroup(
          children: [
            for (final kind in matching)
              _KindRow(
                key: ValueKey(kind.key),
                kind: kind,
                open: _open.contains(kind.key),
                onToggle: () => setState(() {
                  if (!_open.remove(kind.key)) _open.add(kind.key);
                }),
                onTry: () => _try(kind),
              ),
          ],
        ),
    ];
    return Screen(
      title: 'Content format',
      body: LayoutBuilder(
        builder: (context, constraints) {
          const padding = EdgeInsets.all(Spacing.lg);
          if (constraints.maxWidth < 900) {
            return ListView(
              padding: padding,
              children: [
                ...playground,
                const SizedBox(height: Spacing.xl),
                ...kinds,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ListView(padding: padding, children: playground),
              ),
              Expanded(
                flex: 2,
                child: ListView(padding: padding, children: kinds),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Playground extends StatelessWidget {
  const _Playground({
    required this.source,
    required this.scope,
    required this.kinds,
    required this.onScope,
    required this.rich,
    required this.onRich,
    required this.arranged,
    required this.unarrangeable,
    required this.onVisual,
    required this.onTemplate,
  });

  final TextEditingController source;
  final MarkScope scope;
  final MarkKinds kinds;
  final ValueChanged<MarkScope> onScope;

  /// The rich editor's controller while a field is edited in it.
  final FieldController? rich;
  final ValueChanged<bool> onRich;

  /// The template's layout while it is edited visually.
  final TemplateLayout? arranged;
  final bool unarrangeable;
  final ValueChanged<bool> onVisual;
  final ValueChanged<TemplateLayout> onTemplate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return ListenableBuilder(
      listenable: source,
      builder: (context, _) {
        final parsed = parseContent(source.text);
        final warnings = contentWarnings(
          source.text,
          parsed,
          kinds.check(parsed.nodes, scope),
          kinds,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The choices move under the heading when there is no room.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: Spacing.sm,
              children: [
                Text('Source', style: type.heading),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    if (scope == MarkScope.field)
                      SegmentedChoice(
                        choices: const [
                          Choice(true, 'Rich'),
                          Choice(false, 'Source'),
                        ],
                        selected: rich != null,
                        onSelected: onRich,
                      )
                    else
                      SegmentedChoice(
                        choices: const [
                          Choice(true, 'Visual'),
                          Choice(false, 'Source'),
                        ],
                        selected: arranged != null,
                        onSelected: onVisual,
                      ),
                    SegmentedChoice(
                      choices: const [
                        Choice(MarkScope.field, 'Field'),
                        Choice(MarkScope.template, 'Template'),
                      ],
                      selected: scope,
                      onSelected: onScope,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            AnimatedSize(
              duration: Motion.enabled(context)
                  ? Motion.standard
                  : Duration.zero,
              curve: Motion.settle,
              alignment: Alignment.topCenter,
              child: warnings.isEmpty
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: WarningBanner(warnings),
                    ),
            ),
            if (unarrangeable)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: Text(
                  'This template can only be arranged visually once it has '
                  'one front and one back, with nothing else outside them '
                  'but requires and comments.',
                  style: type.caption.copyWith(color: colors.textMuted),
                ),
              ),
            if (rich case final rich?)
              FieldEditor(controller: rich, kinds: kinds)
            else if (arranged case final arranged?)
              TemplateEditor(
                layout: arranged,
                fields: _sampleFields.keys.toList(),
                onChanged: onTemplate,
              )
            else
              TextField(
                controller: source,
                minLines: 3,
                maxLines: 10,
                style: type.body.copyWith(
                  fontFamily: 'monospace',
                  fontFamilyFallback: _monoFallback,
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
            Text('Preview', style: type.heading),
            const SizedBox(height: Spacing.sm),
            _Preview(nodes: parsed.nodes, scope: scope),
            const SizedBox(height: Spacing.lg),
            _Output(label: 'Plain text', value: kinds.plainText(parsed.nodes)),
            _Output(
              label: 'Canonical source',
              value: writeContent(parsed.nodes),
              mono: true,
            ),
          ],
        );
      },
    );
  }
}

/// A labelled, selectable result.
class _Output extends StatelessWidget {
  const _Output({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: type.label.copyWith(color: colors.textMuted)),
          const SizedBox(height: Spacing.xs),
          SelectableText(
            value.trim().isEmpty ? '(empty)' : value,
            style: type.body.copyWith(
              fontFamily: mono ? 'monospace' : null,
              color: value.trim().isEmpty ? colors.textFaint : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The field as the card renderer shows it, or the card the template makes
/// from [_sampleFields], front or back.
class _Preview extends StatefulWidget {
  const _Preview({required this.nodes, required this.scope});

  final List<ContentNode> nodes;
  final MarkScope scope;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  var _revealed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    if (widget.scope == MarkScope.field) {
      return Panel(
        child: widget.nodes.isEmpty
            ? Text(
                '(empty)',
                style: type.body.copyWith(color: colors.textFaint),
              )
            : ContentView(widget.nodes),
      );
    }
    final fields = {
      for (final MapEntry(:key, :value) in _sampleFields.entries)
        key: parseContent(value).nodes,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedChoice(
            choices: const [Choice(false, 'Front'), Choice(true, 'Back')],
            selected: _revealed,
            onSelected: (revealed) => setState(() => _revealed = revealed),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        CardView(card: renderCard(widget.nodes, fields), revealed: _revealed),
        const SizedBox(height: Spacing.sm),
        Text(
          'Sample fields: ${_sampleFields.keys.join(', ')}',
          style: type.caption.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

/// One registered kind on a line: its key, scopes, and what it means. Opened,
/// it shows its arguments and an example to try.
class _KindRow extends StatelessWidget {
  const _KindRow({
    super.key,
    required this.kind,
    required this.open,
    required this.onToggle,
    required this.onTry,
  });

  final MarkKind kind;
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onTry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final mono = type.body.copyWith(
      fontFamily: 'monospace',
      fontFamilyFallback: _monoFallback,
    );
    final muted = type.caption.copyWith(color: colors.textMuted);
    final scopes = kind.scopes.map((s) => s.name).join(' · ');
    final change = Motion.enabled(context) ? Motion.standard : Duration.zero;
    Widget argument(MarkArgument arg, {String suffix = ''}) => Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${arg.name}$suffix',
              style: type.label.copyWith(
                fontFamily: 'monospace',
                fontFamilyFallback: _monoFallback,
              ),
            ),
            TextSpan(text: '  ${arg.description}', style: type.body),
          ],
        ),
      ),
    );
    final details = Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.sm, 0, Spacing.sm, Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              scopes,
              if (kind.content == MarkContent.required)
                'content'
              else
                'no content',
              if (kind.topLevel) 'top level',
              if (kind.once) 'once',
              if (kind.mandatory) 'required',
            ].join(' · '),
            style: muted,
          ),
          if (kind.args.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text('Arguments', style: muted),
            for (final (i, arg) in kind.args.indexed)
              argument(
                arg,
                suffix: kind.repeatsLastArgument && i == kind.args.length - 1
                    ? ' …'
                    : '',
              ),
          ],
          if (kind.named.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Text('Named', style: muted),
            for (final arg in kind.named) argument(arg, suffix: '='),
          ],
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(child: SelectableText(kind.example, style: mono)),
              QuietButton(label: 'Try', onPressed: onTry),
            ],
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pressable(
          onPressed: onToggle,
          selected: open,
          borderRadius: BorderRadius.circular(Radii.sm),
          builder: (context, state) => AnimatedContainer(
            duration: Motion.quick,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: state.hovered || state.pressed
                  ? colors.surfaceSunken
                  : null,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 88,
                  child: Text(
                    kind.key,
                    overflow: TextOverflow.ellipsis,
                    style: mono.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    kind.description,
                    maxLines: open ? null : 1,
                    overflow: open ? null : TextOverflow.ellipsis,
                    style: type.caption.copyWith(color: colors.textMuted),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  scopes,
                  style: type.caption.copyWith(color: colors.textFaint),
                ),
                const SizedBox(width: Spacing.xs),
                AnimatedRotation(
                  turns: open ? 0.25 : 0,
                  duration: change,
                  curve: Motion.settle,
                  child: Icon(
                    MemukiIcons.forward,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: change,
          curve: Motion.settle,
          alignment: Alignment.topCenter,
          child: open ? details : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
