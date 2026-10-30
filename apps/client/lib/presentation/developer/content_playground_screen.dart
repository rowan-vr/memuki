import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/mark_kinds.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/indicators.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../components/rows.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'content_warnings.dart';

/// Japanese and other text in monospaced source falls back to the body face.
const _monoFallback = [MemukiType.bodyFamily];

/// A debug-only page for trying the content format: source in, a rough
/// preview, the plain text, the canonical source, and any problems out, next
/// to the list of registered mark kinds.
///
/// The preview is a sketch for checking structure, not the card renderer.
/// It is a development tool, so its text is not localized.
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

class _ContentPlaygroundScreenState extends State<ContentPlaygroundScreen> {
  /// Fields and templates each keep their own source.
  final _sources = {
    for (final MapEntry(:key, :value) in _samples.entries)
      key: TextEditingController(text: value),
  };
  final _filter = TextEditingController();
  var _scope = MarkScope.field;
  final _open = <String>{};

  MarkKinds get _kinds => widget.kinds ?? MarkKinds.builtIn;

  @override
  void dispose() {
    for (final source in _sources.values) {
      source.dispose();
    }
    _filter.dispose();
    super.dispose();
  }

  void _try(MarkKind kind) => setState(() {
    _scope = kind.scopes.first;
    _sources[_scope]!.text = kind.example;
  });

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
  });

  final TextEditingController source;
  final MarkScope scope;
  final MarkKinds kinds;
  final ValueChanged<MarkScope> onScope;

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
            Row(
              children: [
                Expanded(child: Text('Source', style: type.heading)),
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
            Panel(
              child: _Preview(nodes: parsed.nodes, kinds: kinds),
            ),
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

/// A rough rendering of content: inline marks styled by kind, and the
/// template's sides and conditions as boxes.
class _Preview extends StatelessWidget {
  const _Preview({required this.nodes, required this.kinds});

  final List<ContentNode> nodes;
  final MarkKinds kinds;

  static const _blocks = {'front', 'back', 'if'};

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return Text(
        '(empty)',
        style: context.type.body.copyWith(color: context.colors.textFaint),
      );
    }
    final children = <Widget>[];
    var inline = <ContentNode>[];
    void flush() {
      if (inline.every((n) => n is TextNode && n.text.trim().isEmpty)) {
        inline = [];
        return;
      }
      // Line breaks next to a block lay out the source, not the content.
      if (inline.first case TextNode(:final text)) {
        inline.first = ContentNode.text(text.trimLeft());
      }
      if (inline.last case TextNode(:final text)) {
        inline.last = ContentNode.text(text.trimRight());
      }
      children.add(
        Text.rich(
          TextSpan(children: _spans(context, inline)),
          // Room above each line for readings.
          style: context.type.body.copyWith(height: 2.2),
        ),
      );
      inline = [];
    }

    for (final node in nodes) {
      if (node is CommentNode) continue;
      if (node is MarkNode &&
          (_blocks.contains(node.key) || node.key == 'requires')) {
        flush();
        children.add(_block(context, node));
      } else {
        inline.add(node);
      }
    }
    flush();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(height: Spacing.sm),
          child,
        ],
      ],
    );
  }

  Widget _block(BuildContext context, MarkNode mark) {
    final colors = context.colors;
    final type = context.type;
    if (mark.key == 'requires') {
      return Text(
        'Requires ${mark.args.join(', ')}',
        style: type.caption.copyWith(color: colors.textMuted),
      );
    }
    final label = mark.key == 'if'
        ? 'if ${mark.args.firstOrNull ?? ''}'
        : mark.key;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm + 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: type.caption.copyWith(color: colors.textMuted)),
          const SizedBox(height: Spacing.xs),
          _Preview(nodes: mark.content ?? const [], kinds: kinds),
        ],
      ),
    );
  }

  List<InlineSpan> _spans(BuildContext context, List<ContentNode> nodes) => [
    for (final node in nodes)
      switch (node) {
        // Line breaks and indentation between marks lay out the source,
        // not the content.
        TextNode(:final text) => TextSpan(
          text: text.trim().isEmpty && text.contains('\n') ? ' ' : text,
        ),
        MarkNode() => _mark(context, node),
        CommentNode() => const TextSpan(),
      },
  ];

  InlineSpan _mark(BuildContext context, MarkNode mark) {
    final c = context.colors;
    final t = context.type;
    final inner = _spans(context, mark.content ?? const []);
    switch (mark.key) {
      case 'ruby':
        // The base sets the baseline; the reading is painted above it.
        return WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: CustomPaint(
            foregroundPainter: _ReadingPainter(
              mark.args.firstOrNull ?? '',
              t.caption.copyWith(color: c.textMuted, height: 1),
              Directionality.of(context),
            ),
            child: Text.rich(TextSpan(children: inner), style: t.body),
          ),
        );
      case 'em':
        return TextSpan(
          children: inner,
          style: TextStyle(fontWeight: FontWeight.w700, color: c.accent.onSoft),
        );
      case 'sub' || 'sup':
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Transform.translate(
            offset: Offset(0, mark.key == 'sub' ? 5 : -6),
            child: Text.rich(
              TextSpan(children: inner),
              style: t.body,
              textScaler: const TextScaler.linear(0.7),
            ),
          ),
        );
      case 'lang':
        return TextSpan(
          children: inner,
          style: TextStyle(locale: _locale(mark.args.firstOrNull)),
        );
      case 'field':
        final role = mark.named['role'];
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Tag(
            label: [mark.args.firstOrNull ?? '?', ?role].join(' · '),
            tone: c.accent,
          ),
        );
      default:
        final known = kinds[mark.key] != null;
        return TextSpan(
          children: inner,
          style: known
              ? null
              : TextStyle(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationColor: c.textFaint,
                ),
        );
    }
  }

  /// A rough locale from a BCP 47 tag: language, then a script or region.
  static Locale? _locale(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('-');
    String? script;
    String? region;
    for (final part in parts.skip(1)) {
      if (part.length == 4) {
        script = part;
      } else {
        region = part;
      }
    }
    return Locale.fromSubtags(
      languageCode: parts.first,
      scriptCode: script,
      countryCode: region,
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

/// Paints a reading centred above the base text it belongs to.
class _ReadingPainter extends CustomPainter {
  _ReadingPainter(this.reading, this.style, this.direction);

  final String reading;
  final TextStyle style;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(text: reading, style: style),
      textDirection: direction,
    )..layout();
    painter
      ..paint(
        canvas,
        Offset((size.width - painter.width) / 2, -painter.height + 2),
      )
      ..dispose();
  }

  @override
  bool shouldRepaint(_ReadingPainter old) =>
      old.reading != reading || old.style != style;
}
