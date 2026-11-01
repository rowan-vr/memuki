import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../theme/app_theme.dart';
import 'mark_editing.dart';

/// Builds a mark as a span, given the style of the text around it and its
/// content rendered in [MarkRendering.style].
typedef MarkSpanBuilder = InlineSpan Function(
  BuildContext context,
  MarkNode mark,
  TextStyle style,
  TextSpan content,
);

/// How content is shown, read-only, for one kind of mark. The kind's meaning
/// is in its `MarkKind`; editing is in `MarkEditing`.
///
/// A kind without an entry shows its content as it is.
@immutable
class MarkRendering {
  const MarkRendering({this.style, this.span});

  /// How text in the mark looks, given the style around it.
  final TextStyle Function(BuildContext context, MarkNode mark, TextStyle base)?
  style;

  /// The mark as a span, for marks that are more than styled text. Its
  /// content as text by default.
  final MarkSpanBuilder? span;

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
  };

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
  static TextSpan _resized(TextSpan span, double size) => TextSpan(
    text: span.text,
    style: span.style?.copyWith(fontSize: size),
    children: [
      for (final child in span.children ?? const <InlineSpan>[])
        child is TextSpan ? _resized(child, size) : child,
    ],
  );
}

/// Text inside a widget span. The span is scaled with the text around it
/// already, so the text in it is not scaled again.
Widget _inline(TextSpan span) =>
    Text.rich(span, textScaler: TextScaler.noScaling);

/// Shows content read-only, with its marks rendered by [rendering].
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
  Widget build(BuildContext context) {
    final base = style ?? context.type.body;
    return Text.rich(
      contentSpan(context, nodes, base, rendering ?? MarkRendering.builtIn),
      textAlign: textAlign,
    );
  }
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
