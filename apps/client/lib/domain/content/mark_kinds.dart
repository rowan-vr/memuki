import 'package:meta/meta.dart';

import 'content_node.dart';

/// Where a mark kind may appear.
enum MarkScope {
  /// In field values.
  field,

  /// In templates.
  template,
}

/// Whether a mark kind takes content after `|`.
enum MarkContent { required, forbidden }

/// A kind of mark: the arguments it takes, where it may appear, and how it
/// reads as plain text.
///
/// Rendering and editing are defined by the layers that do them, keyed by
/// [key], so this stays free of UI.
@immutable
class MarkKind {
  const MarkKind(
    this.key, {
    required this.scopes,
    this.args = 0,
    this.named = const {},
    this.content = MarkContent.required,
    this.plainText = _content,
  });

  final String key;
  final Set<MarkScope> scopes;

  /// How many positional arguments it takes, or -1 for one or more.
  final int args;

  /// The named arguments it accepts.
  final Set<String> named;

  final MarkContent content;

  /// The mark as plain text, given its content as plain text.
  final String Function(MarkNode mark, String content) plainText;

  static String _content(MarkNode mark, String content) => content;
}

/// Something wrong with how a mark is used, found by [MarkKinds.check].
enum MarkIssueKind {
  /// Not allowed where it is, such as a template mark in a field.
  wrongScope,

  /// Takes a different number of positional arguments.
  wrongArgumentCount,

  /// Has a named argument its kind does not accept.
  unknownArgument,

  /// Has no content but needs some.
  missingContent,

  /// Has content but takes none.
  unexpectedContent,
}

@immutable
class MarkIssue {
  const MarkIssue(this.kind, this.mark);

  final MarkIssueKind kind;
  final MarkNode mark;

  @override
  bool operator ==(Object other) =>
      other is MarkIssue && other.kind == kind && other.mark == mark;

  @override
  int get hashCode => Object.hash(kind, mark);

  @override
  String toString() => 'MarkIssue(${kind.name}, ${mark.key})';
}

/// The known mark kinds. A kind that is not known, such as one from a newer
/// version or a missing plugin, keeps its content and reads as it.
class MarkKinds {
  MarkKinds(Iterable<MarkKind> kinds)
    : _kinds = {for (final k in kinds) k.key: k};

  /// The kinds built into Memuki.
  static final builtIn = MarkKinds([
    // {ruby reading | base}: base text with its reading above it.
    const MarkKind('ruby', scopes: {MarkScope.field}, args: 1),
    const MarkKind('em', scopes: {MarkScope.field}),
    const MarkKind('sub', scopes: {MarkScope.field}),
    const MarkKind('sup', scopes: {MarkScope.field}),
    // {lang tag | text}: text in another language than the field's.
    const MarkKind(
      'lang',
      scopes: {MarkScope.field, MarkScope.template},
      args: 1,
    ),
    const MarkKind('front', scopes: {MarkScope.template}),
    const MarkKind('back', scopes: {MarkScope.template}),
    // {field Name role=…}: where a field's value goes.
    MarkKind(
      'field',
      scopes: const {MarkScope.template},
      args: 1,
      named: const {'role'},
      content: MarkContent.forbidden,
      plainText: (mark, _) => '',
    ),
    // {if Name | …}: shown when the field is not empty.
    const MarkKind('if', scopes: {MarkScope.template}, args: 1),
    // {requires Name …}: fields a note must fill to get this card.
    MarkKind(
      'requires',
      scopes: const {MarkScope.template},
      args: -1,
      content: MarkContent.forbidden,
      plainText: (mark, _) => '',
    ),
  ]);

  final Map<String, MarkKind> _kinds;

  MarkKind? operator [](String key) => _kinds[key];

  /// [nodes] as plain text: the text with the marks dropped, as each kind
  /// reads. Used for search, duplicate detection, sorting, and comparing
  /// typed answers.
  String plainText(List<ContentNode> nodes) {
    final out = StringBuffer();
    for (final node in nodes) {
      switch (node) {
        case TextNode(:final text):
          out.write(text);
        case MarkNode(:final content):
          final inner = content == null ? '' : plainText(content);
          final kind = _kinds[node.key];
          out.write(kind == null ? inner : kind.plainText(node, inner));
      }
    }
    return out.toString();
  }

  /// The marks in [nodes], at any depth, that are used in a way their kind
  /// does not allow in [scope]. Unknown kinds are not reported.
  List<MarkIssue> check(List<ContentNode> nodes, MarkScope scope) {
    final issues = <MarkIssue>[];
    void visit(List<ContentNode> nodes) {
      for (final node in nodes) {
        if (node is! MarkNode) continue;
        final kind = _kinds[node.key];
        if (kind != null) {
          void add(MarkIssueKind issue) => issues.add(MarkIssue(issue, node));
          if (!kind.scopes.contains(scope)) add(MarkIssueKind.wrongScope);
          final argsOk = kind.args < 0
              ? node.args.isNotEmpty
              : node.args.length == kind.args;
          if (!argsOk) add(MarkIssueKind.wrongArgumentCount);
          if (node.named.keys.any((name) => !kind.named.contains(name))) {
            add(MarkIssueKind.unknownArgument);
          }
          switch ((kind.content, node.content)) {
            case (MarkContent.required, null):
              add(MarkIssueKind.missingContent);
            case (MarkContent.forbidden, _?):
              add(MarkIssueKind.unexpectedContent);
            default:
          }
        }
        if (node.content case final content?) visit(content);
      }
    }

    visit(nodes);
    return issues;
  }
}
