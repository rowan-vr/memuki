import 'package:flutter/material.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/content_parser.dart';
import '../../domain/content/content_writer.dart';
import '../../domain/content/mark_kinds.dart';
import '../components/icons.dart';
import '../components/pressable.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_type.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';

/// Something wrong in content source, explained: what it is, what it means,
/// and where it is, as a position or the mark's source.
@immutable
class ContentWarning {
  const ContentWarning(this.title, this.detail, [this.where]);

  final String title;
  final String detail;
  final String? where;
}

/// The problems and issues in [source] explained, in that order.
///
/// Development text, so not localized.
List<ContentWarning> contentWarnings(
  String source,
  ParsedContent parsed,
  List<MarkIssue> issues,
  MarkKinds kinds,
) => [
  for (final p in parsed.problems) _problem(p, _position(source, p.offset)),
  for (final i in issues) _issue(i, kinds),
];

ContentWarning _problem(ContentProblem problem, String where) {
  final (title, detail) = switch (problem.kind) {
    ContentProblemKind.unclosedMark => (
      'Unclosed mark',
      'This { is never closed with }. Its opening is shown as text.',
    ),
    ContentProblemKind.unexpectedClose => (
      'Stray close',
      r'This } does not close any mark. Write \} to show a brace.',
    ),
    ContentProblemKind.invalidMark => (
      'Invalid mark',
      'A { must be followed by a key and arguments, such as {em | …}. '
          r'Write \{ to show a brace.',
    ),
    ContentProblemKind.unterminatedQuote => (
      'Unterminated quote',
      'This quoted argument has no closing ".',
    ),
    ContentProblemKind.trailingBackslash => (
      'Trailing backslash',
      r'The source ends with a single \. Write \\ for a backslash.',
    ),
    ContentProblemKind.duplicateArgument => (
      'Repeated argument',
      'This named argument is given more than once; the last value is used.',
    ),
    ContentProblemKind.tooDeep => (
      'Nested too deeply',
      'Marks nest at most $maxContentDepth deep. This one is kept as text.',
    ),
  };
  return ContentWarning(title, detail, where);
}

ContentWarning _issue(MarkIssue issue, MarkKinds kinds) {
  final node = issue.node;
  final key = node is MarkNode ? node.key : '';
  final kind = kinds[key];
  final source = _snippet(node);
  return switch (issue.kind) {
    MarkIssueKind.unknownKind => ContentWarning(
      'Unknown mark',
      'No kind is called "$key". The mark is kept, and its content is shown '
          'as it is.',
      source,
    ),
    MarkIssueKind.wrongScope => ContentWarning(
      'Not allowed here',
      '"$key" belongs in ${_list(kind!.scopes.map((s) => '${s.name}s'))}.',
      source,
    ),
    MarkIssueKind.wrongArgumentCount => ContentWarning(
      'Wrong number of arguments',
      '"$key" takes ${_arguments(kind!)}, but has '
          '${(node as MarkNode).args.length}.',
      source,
    ),
    MarkIssueKind.unknownArgument => ContentWarning(
      'Unknown named argument',
      kind!.named.isEmpty
          ? '"$key" takes no named arguments.'
          : '"$key" accepts '
                '${_list(kind.named.map((a) => '${a.name}='))} only.',
      source,
    ),
    MarkIssueKind.missingContent => ContentWarning(
      'Missing content',
      '"$key" needs content after |, such as {$key … | text}.',
      source,
    ),
    MarkIssueKind.unexpectedContent => ContentWarning(
      'Unexpected content',
      '"$key" takes no content; leave out the | and what follows it.',
      source,
    ),
    MarkIssueKind.misplaced => ContentWarning(
      'Misplaced "$key"',
      '"$key" stands at the top level of a template, not inside another '
          'mark.',
      source,
    ),
    MarkIssueKind.repeated => ContentWarning(
      'Second "$key"',
      'A template has only one "$key"; this one is extra.',
      source,
    ),
    MarkIssueKind.missing => ContentWarning(
      'No "$key"',
      'A template needs a "$key", such as ${kind!.example}.',
    ),
    MarkIssueKind.loose => ContentWarning(
      'Outside the sides',
      'Text and marks outside front and back are never shown. Move this '
          'into a side, or make it a comment with {# …}.',
      source,
    ),
  };
}

/// The arguments [kind] takes, counted and named.
String _arguments(MarkKind kind) {
  final count = kind.args.length;
  final names = kind.args.map((a) => a.name).join(', ');
  if (kind.repeatsLastArgument) return 'at least $count ($names …)';
  if (count == 0) return 'no arguments';
  return '$count ($names)';
}

String _list(Iterable<String> items) {
  final all = items.toList();
  if (all.length < 2) return all.join();
  return '${all.take(all.length - 1).join(', ')} or ${all.last}';
}

/// [node] as source, shortened to a line.
String _snippet(ContentNode node) {
  final source = switch (node) {
    TextNode(:final text) => text.trim(),
    _ => writeContent([node]),
  }.replaceAll(RegExp(r'\s+'), ' ');
  return source.length > 60 ? '${source.substring(0, 59)}…' : source;
}

/// [offset] in [text] as a line and column, both from 1.
String _position(String text, int offset) {
  final before = text.substring(0, offset);
  final line = '\n'.allMatches(before).length + 1;
  final column = offset - before.lastIndexOf('\n');
  return 'Line $line, column $column';
}

/// [warnings] on a red banner, one at a time, with arrows to page through
/// them.
class WarningBanner extends StatefulWidget {
  const WarningBanner(this.warnings, {super.key});

  final List<ContentWarning> warnings;

  @override
  State<WarningBanner> createState() => _WarningBannerState();
}

class _WarningBannerState extends State<WarningBanner> {
  var _page = 0;

  @override
  Widget build(BuildContext context) {
    final tone = context.colors.again;
    final type = context.type;
    final count = widget.warnings.length;
    // Fewer warnings than before can leave the page past the end.
    final page = _page.clamp(0, count - 1);
    final warning = widget.warnings[page];
    Widget arrow(IconData icon, int to) {
      final enabled = to >= 0 && to < count;
      return Pressable(
        onPressed: enabled ? () => setState(() => _page = to) : null,
        borderRadius: BorderRadius.circular(Radii.xs),
        semanticLabel: to < page ? 'Previous warning' : 'Next warning',
        builder: (context, state) => Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? tone.onSoft : tone.onSoft.withValues(alpha: 0.35),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm + 2,
        Spacing.sm,
        Spacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(MemukiIcons.warning, size: 18, color: tone.onSoft),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.enabled(context) ? Motion.quick : Duration.zero,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, ?current],
              ),
              child: Column(
                key: ValueKey(page),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warning.title,
                    style: type.bodyStrong.copyWith(color: tone.onSoft),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    warning.detail,
                    style: type.body.copyWith(color: tone.onSoft),
                  ),
                  if (warning.where case final where?) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      where,
                      style: type.caption.copyWith(
                        color: tone.onSoft.withValues(alpha: 0.8),
                        fontFamily: 'monospace',
                        fontFamilyFallback: const [MemukiType.bodyFamily],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (count > 1) ...[
            const SizedBox(width: Spacing.sm),
            arrow(MemukiIcons.back, page - 1),
            SizedBox(
              width: 44,
              child: Text(
                '${page + 1}/$count',
                textAlign: TextAlign.center,
                style: type.label.copyWith(
                  color: tone.onSoft,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            arrow(MemukiIcons.forward, page + 1),
          ],
        ],
      ),
    );
  }
}
