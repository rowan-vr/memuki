import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'mark_editing.dart';

/// Builds a mark as a span, given the style of the text around it and its
/// content rendered in [MarkRendering.style].
typedef MarkSpanBuilder = InlineSpan Function(
  BuildContext context,
  MarkNode mark,
  TextStyle style,
  TextSpan content,
);

/// Builds a mark that stands on lines of its own, such as a list, or returns
/// null to show it as its content in [MarkRendering.style].
typedef MarkBlockBuilder = Widget? Function(
  BuildContext context,
  MarkBlock block,
);

/// What a [MarkBlockBuilder] builds: one mark, the style inside it, its place
/// among the marks of its kind next to it, and a way to lay out content.
@immutable
class MarkBlock {
  const MarkBlock({
    required this.mark,
    required this.style,
    required this.index,
    required this.count,
    required this.layout,
  });

  final MarkNode mark;

  /// The style of the text in the mark, after [MarkRendering.style].
  final TextStyle style;

  /// Its position among the marks of its key in the same content, from 0,
  /// and how many there are, so senses can be numbered.
  final int index;
  final int count;

  /// Lays out [nodes] as blocks, [spacing] apart.
  final Widget Function(
    List<ContentNode> nodes, {
    TextStyle? style,
    TextAlign textAlign,
    double spacing,
  })
  layout;

  /// The mark's own content, laid out from the start of the line.
  Widget content({TextStyle? style, double spacing = Spacing.sm}) => layout(
    mark.content ?? const [],
    style: style ?? this.style,
    textAlign: TextAlign.start,
    spacing: spacing,
  );
}

/// How content is shown, read-only, for one kind of mark. The kind's meaning
/// is in its `MarkKind`; editing is in `MarkEditing`.
///
/// A kind without an entry shows its content as it is.
@immutable
class MarkRendering {
  const MarkRendering({this.style, this.span, this.block});

  /// How text in the mark looks, given the style around it.
  final TextStyle Function(BuildContext context, MarkNode mark, TextStyle base)?
  style;

  /// The mark as a span, for marks that are more than styled text. Its
  /// content as text by default.
  final MarkSpanBuilder? span;

  /// The mark on lines of its own, for marks such as lists. Text around it
  /// goes on lines before and after it.
  final MarkBlockBuilder? block;

  /// The size of tags, and of sense numbers, against the text around them.
  static const _tagScale = 0.75;

  /// The entries for the built-in kinds that belong in fields.
  static final Map<String, MarkRendering> builtIn = {
    'ruby': const MarkRendering(span: _ruby),
    'em': MarkRendering(
      style: (context, _, base) => base.copyWith(
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation.weight(700)],
        color: context.colors.accent.onSoft,
      ),
    ),
    'sub': const MarkRendering(span: _subscript),
    'sup': const MarkRendering(span: _superscript),
    'lang': MarkRendering(
      style: (_, mark, base) =>
          base.copyWith(locale: localeOf(mark.args.firstOrNull)),
    ),
    'sense': const MarkRendering(block: _sense),
    'tag': const MarkRendering(span: _tag),
    'list': MarkRendering(
      block: (_, block) => Padding(
        padding: const EdgeInsetsDirectional.only(start: Spacing.sm),
        child: block.content(spacing: Spacing.xs),
      ),
    ),
    'item': const MarkRendering(block: _item),
    'example': const MarkRendering(block: _example),
    'translation': MarkRendering(
      style: (context, _, base) => base.copyWith(
        fontSize: (base.fontSize ?? context.type.body.fontSize!) * 0.8,
        color: context.colors.textMuted,
      ),
      block: (_, block) => block.content(),
    ),
    'forms': const MarkRendering(block: _forms),
    'form': const MarkRendering(span: _form),
    'source': const MarkRendering(span: _source),
    'audio': const MarkRendering(span: _audio),
  };

  /// A meaning of a word, numbered in a disc when there are several: its
  /// tags and glosses from the start of the line.
  static Widget _sense(BuildContext context, MarkBlock block) {
    final content = block.content();
    if (block.count < 2) return content;
    final colors = context.colors;
    final size = block.style.fontSize ?? context.type.body.fontSize!;
    final line = size * (block.style.height ?? 1.5);
    // As tall as the tags beside it.
    final disc = size * _tagScale * (block.style.height ?? 1.5);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Centred on the first line, level with the tags on it.
        SizedBox(
          height: line,
          child: Center(
            child: Container(
              width: disc,
              height: disc,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accent.soft,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${block.index + 1}',
                textScaler: TextScaler.noScaling,
                style: block.style.copyWith(
                  fontSize: size * _tagScale,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontVariations: const [FontVariation.weight(700)],
                  color: colors.accent.onSoft,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(child: content),
      ],
    );
  }

  /// A label, smaller than the text around it and tinted by what it labels,
  /// with a little room after it.
  static InlineSpan _tag(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) {
    final colors = context.colors;
    final size = (style.fontSize ?? context.type.body.fontSize!) * _tagScale;
    final tone = switch (mark.args.firstOrNull) {
      'misc' => colors.swatches[MemukiAccent.coral],
      'field' => colors.swatches[MemukiAccent.purple],
      'dialect' => colors.swatches[MemukiAccent.green],
      _ => null,
    };
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs + 2),
          decoration: BoxDecoration(
            color: tone?.soft ?? colors.surfaceSunken,
            borderRadius: BorderRadius.circular(Radii.xs),
          ),
          child: _inline(
            _restyled(
              content,
              (s) => s.copyWith(
                fontSize: size,
                fontWeight: FontWeight.w700,
                fontVariations: const [FontVariation.weight(700)],
                color: tone?.onSoft ?? colors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _item(BuildContext context, MarkBlock block) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('•', style: block.style.copyWith(color: context.colors.textMuted)),
      const SizedBox(width: Spacing.sm),
      Expanded(child: block.content(spacing: Spacing.xs)),
    ],
  );

  /// An example sentence in a box ruled down its start, as wide as it needs.
  static Widget _example(BuildContext context, MarkBlock block) {
    final colors = context.colors;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + 2,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: BorderDirectional(
            start: BorderSide(color: colors.textMuted, width: 3),
          ),
        ),
        child: block.content(spacing: Spacing.xs),
      ),
    );
  }

  static Widget _forms(BuildContext context, MarkBlock block) {
    final l10n = AppLocalizations.of(context);
    final forms = (block.mark.content ?? const []).whereType<MarkNode>();
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          _tag(
            context,
            const MarkNode('tag', args: ['forms']),
            block.style,
            TextSpan(text: l10n.contentForms, style: block.style),
          ),
        ),
        for (final form in forms)
          if (form.key == 'form')
            Text.rich(_form(context, form, block.style, const TextSpan())),
      ],
    );
  }

  /// A spelling with its reading in brackets, in the accent colour when it is
  /// the one mostly used, and faint when it is rarely used or out of date.
  static InlineSpan _form(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) {
    final colors = context.colors;
    final form = mark.args.firstOrNull ?? '';
    final reading = mark.named['reading'];
    final color = switch (mark.named['status']) {
      'priority' => colors.accent.onSoft,
      'valid' || null => style.color,
      _ => colors.textFaint,
    };
    return TextSpan(
      text: reading == null || reading == form ? form : '$form【$reading】',
      style: style.copyWith(color: color),
    );
  }

  static InlineSpan _source(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) => TextSpan(
    text: [?mark.args.firstOrNull, ?mark.named['date']].join(' · '),
    style: style.copyWith(
      fontSize: (style.fontSize ?? context.type.body.fontSize!) * 0.75,
      color: context.colors.textMuted,
    ),
  );

  /// A sound to play. Playing it comes with the media player.
  static InlineSpan _audio(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Semantics(
      container: true,
      label: AppLocalizations.of(context).contentAudio,
      child: Icon(
        MemukiIcons.audio,
        size: (style.fontSize ?? context.type.body.fontSize!) * 1.2,
        color: context.colors.textMuted,
      ),
    ),
  );

  /// The reading stacked over the base text, as one group. Laid out upwards,
  /// so the base text comes first and gives the group its baseline.
  static InlineSpan _ruby(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) {
    final size = style.fontSize ?? context.type.body.fontSize!;
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.up,
        children: [
          _inline(content),
          Text(
            mark.args.firstOrNull ?? '',
            textScaler: TextScaler.noScaling,
            style: style.copyWith(
              fontSize: size * 0.5,
              height: 1.2,
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  static InlineSpan _subscript(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) => _shifted(context, style, content, 0.2);

  static InlineSpan _superscript(
    BuildContext context,
    MarkNode mark,
    TextStyle style,
    TextSpan content,
  ) => _shifted(context, style, content, -0.4);

  /// [content] smaller, and moved down by [shift] of the text's size, or up
  /// when it is negative. The line keeps its height.
  static InlineSpan _shifted(
    BuildContext context,
    TextStyle style,
    TextSpan content,
    double shift,
  ) {
    final size = style.fontSize ?? context.type.body.fontSize!;
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Transform.translate(
        offset: Offset(0, size * shift),
        child: _inline(_resized(content, size * 0.7)),
      ),
    );
  }

  /// [span] with each of its own sizes replaced by [size].
  static TextSpan _resized(TextSpan span, double size) =>
      _restyled(span, (s) => s.copyWith(fontSize: size));

  /// [span] with each of its own styles changed by [change].
  static TextSpan _restyled(
    TextSpan span,
    TextStyle Function(TextStyle) change,
  ) => TextSpan(
    text: span.text,
    style: span.style == null ? null : change(span.style!),
    children: [
      for (final child in span.children ?? const <InlineSpan>[])
        child is TextSpan ? _restyled(child, change) : child,
    ],
  );
}

/// Text inside a widget span. The span is scaled with the text around it
/// already, so the text in it is not scaled again.
Widget _inline(TextSpan span) =>
    Text.rich(span, textScaler: TextScaler.noScaling);

/// Shows content read-only, with its marks rendered by [rendering]. Text
/// and inline marks flow as lines aligned by [textAlign]; marks rendered as
/// blocks, such as lists, stand between them.
class ContentView extends StatelessWidget {
  const ContentView(
    this.nodes, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.rendering,
  });

  final List<ContentNode> nodes;

  /// The body text style by default.
  final TextStyle? style;

  final TextAlign textAlign;

  /// [MarkRendering.builtIn] by default.
  final Map<String, MarkRendering>? rendering;

  @override
  Widget build(BuildContext context) => _layout(
    context,
    nodes,
    style ?? context.type.body,
    textAlign,
    rendering ?? MarkRendering.builtIn,
    Spacing.sm,
  );
}

/// [nodes] as lines of text, with block marks between them, [spacing] apart.
Widget _layout(
  BuildContext context,
  List<ContentNode> nodes,
  TextStyle style,
  TextAlign textAlign,
  Map<String, MarkRendering> rendering,
  double spacing,
) {
  final out = <Widget>[];
  var run = <InlineSpan>[];
  void flush() {
    final spans = _trimmed(run);
    run = [];
    if (spans != null) {
      out.add(Text.rich(TextSpan(children: spans), textAlign: textAlign));
    }
  }

  final base = style;
  Widget layout(
    List<ContentNode> nodes, {
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    double spacing = Spacing.sm,
  }) => _layout(context, nodes, style ?? base, textAlign, rendering, spacing);

  void visit(List<ContentNode> nodes, TextStyle style) {
    final counts = <String, int>{};
    for (final node in nodes) {
      if (node is MarkNode) counts[node.key] = (counts[node.key] ?? 0) + 1;
    }
    final seen = <String, int>{};
    for (final node in nodes) {
      switch (node) {
        case TextNode(:final text):
          run.add(TextSpan(text: text, style: style));
        case CommentNode():
          break;
        case MarkNode(:final key, :final content):
          final entry = rendering[key];
          final inner = entry?.style?.call(context, node, style) ?? style;
          final index = seen[key] ?? 0;
          seen[key] = index + 1;
          final block = entry?.block?.call(
            context,
            MarkBlock(
              mark: node,
              style: inner,
              index: index,
              count: counts[key]!,
              layout: layout,
            ),
          );
          if (block != null) {
            flush();
            out.add(block);
          } else if (entry?.span case final span?) {
            run.add(
              span(
                context,
                node,
                style,
                contentSpan(context, content ?? const [], inner, rendering),
              ),
            );
          } else {
            visit(content ?? const [], inner);
          }
      }
    }
  }

  visit(nodes, style);
  flush();
  if (out.isEmpty) return Text.rich(TextSpan(style: style));
  if (out.length == 1) return out.single;
  return Column(
    crossAxisAlignment: textAlign == TextAlign.center
        ? CrossAxisAlignment.stretch
        : CrossAxisAlignment.start,
    children: [
      for (final (i, child) in out.indexed) ...[
        if (i > 0) SizedBox(height: spacing),
        child,
      ],
    ],
  );
}

/// [spans] without the whitespace at their ends, which only lays out the
/// source around blocks, or null when nothing else is left.
List<InlineSpan>? _trimmed(List<InlineSpan> spans) {
  bool blank(InlineSpan s) => s is TextSpan && (s.text ?? '').trim().isEmpty;
  if (spans.every(blank)) return null;
  final out = [...spans];
  while (blank(out.first)) {
    out.removeAt(0);
  }
  while (blank(out.last)) {
    out.removeLast();
  }
  if (out.first case TextSpan(:final text?, :final style)) {
    out.first = TextSpan(text: text.trimLeft(), style: style);
  }
  if (out.last case TextSpan(:final text?, :final style)) {
    out.last = TextSpan(text: text.trimRight(), style: style);
  }
  return out;
}

/// [nodes] as one span in [style], with marks rendered by [rendering].
/// Every span carries its whole style, so any part can be laid out alone.
TextSpan contentSpan(
  BuildContext context,
  List<ContentNode> nodes,
  TextStyle style,
  Map<String, MarkRendering> rendering,
) => TextSpan(
  style: style,
  children: [
    for (final node in nodes)
      switch (node) {
        TextNode(:final text) => TextSpan(text: text, style: style),
        MarkNode() => _mark(context, node, style, rendering),
        CommentNode() => const TextSpan(),
      },
  ],
);

InlineSpan _mark(
  BuildContext context,
  MarkNode mark,
  TextStyle style,
  Map<String, MarkRendering> rendering,
) {
  final entry = rendering[mark.key];
  final inner = entry?.style?.call(context, mark, style) ?? style;
  final content = contentSpan(
    context,
    mark.content ?? const [],
    inner,
    rendering,
  );
  return entry?.span?.call(context, mark, style, content) ?? content;
}
