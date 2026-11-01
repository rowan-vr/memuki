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

/// An argument a mark kind takes.
@immutable
class MarkArgument {
  const MarkArgument(this.name, this.description);

  final String name;
  final String description;
}

/// A kind of mark: what it means, the arguments it takes, where it may
/// appear, and how it reads as plain text.
///
/// Rendering and editing are defined by the layers that do them, keyed by
/// [key], so this stays free of UI.
@immutable
class MarkKind {
  const MarkKind(
    this.key, {
    required this.description,
    required this.example,
    required this.scopes,
    this.args = const [],
    this.repeatsLastArgument = false,
    this.named = const [],
    this.content = MarkContent.required,
    this.topLevel = false,
    this.once = false,
    this.mandatory = false,
    this.onRequest = false,
    this.plainText = _content,
  });

  final String key;

  /// What the mark means, for documentation and development tools.
  final String description;

  /// The mark in use, as source.
  final String example;

  final Set<MarkScope> scopes;

  /// The positional arguments it takes, in order.
  final List<MarkArgument> args;

  /// Whether the last of [args] may be given more than once.
  final bool repeatsLastArgument;

  /// The named arguments it accepts. All are optional.
  final List<MarkArgument> named;

  final MarkContent content;

  /// Whether, in a template, it may only stand at the top level, outside any
  /// other mark.
  final bool topLevel;

  /// Whether a template may have it at most once.
  final bool once;

  /// Whether a template must have it.
  final bool mandatory;

  /// Whether it is kept in field values but left off cards, unless the
  /// template places the field with `show` naming it. Used for reference
  /// details such as a dictionary's sources.
  final bool onRequest;

  /// The mark as plain text, given its content as plain text.
  final String Function(MarkNode mark, String content) plainText;

  static String _content(MarkNode mark, String content) => content;

  /// For marks that read as nothing, such as references.
  static String nothing(MarkNode mark, String content) => '';

  /// For marks that stand on lines of their own.
  static String line(MarkNode mark, String content) => '$content\n';
}

/// Something wrong with how a mark is used, or with a template's layout,
/// found by [MarkKinds.check].
enum MarkIssueKind {
  /// Its key names no known kind. It is kept, and reads as its content.
  unknownKind,

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

  /// Inside another mark, but its kind stands only at a template's top level.
  misplaced,

  /// A second one, where a template may have only one.
  repeated,

  /// Not there, but a template must have one. The issue's node is a bare
  /// mark of the missing kind.
  missing,

  /// Text or a mark at a template's top level, outside the marks that stand
  /// there, so it would never be shown.
  loose,
}

@immutable
class MarkIssue {
  const MarkIssue(this.kind, this.node);

  final MarkIssueKind kind;

  /// The mark with the issue, or for [MarkIssueKind.loose] the text or mark.
  final ContentNode node;

  @override
  bool operator ==(Object other) =>
      other is MarkIssue && other.kind == kind && other.node == node;

  @override
  int get hashCode => Object.hash(kind, node);

  @override
  String toString() => 'MarkIssue(${kind.name}, $node)';
}

/// The known mark kinds. A kind that is not known, such as one from a newer
/// version or a missing plugin, keeps its content and reads as it.
class MarkKinds {
  MarkKinds(Iterable<MarkKind> kinds)
    : _kinds = {for (final k in kinds) k.key: k};

  /// The kinds built into Memuki.
  static final builtIn = MarkKinds([
    const MarkKind(
      'ruby',
      description: 'Base text with its reading shown above it.',
      example: '{ruby てんき | 天気}',
      scopes: {MarkScope.field},
      args: [MarkArgument('reading', 'How the base text is read.')],
    ),
    const MarkKind(
      'em',
      description: 'Emphasised text.',
      example: '今日は{em | いい}天気',
      scopes: {MarkScope.field},
    ),
    const MarkKind(
      'sub',
      description: 'Subscript, such as in chemical formulas.',
      example: 'H{sub | 2}O',
      scopes: {MarkScope.field},
    ),
    const MarkKind(
      'sup',
      description: 'Superscript, such as in exponents.',
      example: 'x{sup | 2}',
      scopes: {MarkScope.field},
    ),
    const MarkKind(
      'lang',
      description:
          "Text in another language than the field's, which selects its "
          'glyph forms, direction, and font.',
      example: '{lang zh-Hans | 你好}',
      scopes: {MarkScope.field, MarkScope.template},
      args: [MarkArgument('tag', 'A BCP 47 language tag, such as zh-Hans.')],
    ),
    const MarkKind(
      'sense',
      description:
          'One meaning of a word: its tags, glosses, and examples. Several '
          'senses in a field are numbered.',
      example: '{sense | {tag pos n | noun} {list | {item | scenery}}}',
      scopes: {MarkScope.field},
      plainText: MarkKind.line,
    ),
    MarkKind(
      'tag',
      description:
          'A label from a dictionary, such as a part of speech, kept with its '
          'code.',
      example: '{tag pos adv | adverb}',
      scopes: const {MarkScope.field},
      args: const [
        MarkArgument(
          'category',
          'What it labels: pos (part of speech), misc, field (a subject such '
              'as computing), or dialect.',
        ),
        MarkArgument('code', "The dictionary's code for it, such as adv."),
      ],
      plainText: (_, content) => '$content ',
    ),
    const MarkKind(
      'list',
      description: 'A list of items, such as the glosses of a sense.',
      example: '{list | {item | clearly}{item | plainly}}',
      scopes: {MarkScope.field},
    ),
    const MarkKind(
      'item',
      description: 'An item of a list.',
      example: '{item | clearly}',
      scopes: {MarkScope.field},
      plainText: MarkKind.line,
    ),
    const MarkKind(
      'example',
      description: 'An example sentence, with its translation.',
      example: '{example | 景色がいい。{translation | The view is nice.}}',
      scopes: {MarkScope.field},
      plainText: MarkKind.line,
    ),
    MarkKind(
      'translation',
      description: 'The translation of an example sentence.',
      example: '{translation | The view is nice.}',
      scopes: const {MarkScope.field},
      plainText: (_, content) => '\n$content',
    ),
    const MarkKind(
      'forms',
      description: 'The spellings and readings of a word, from a dictionary.',
      example: '{forms | {form 景色 reading=けしき status=priority}}',
      scopes: {MarkScope.field},
      onRequest: true,
      plainText: MarkKind.nothing,
    ),
    const MarkKind(
      'form',
      description: 'A spelling of a word with a reading.',
      example: '{form 景色 reading=けしき status=priority}',
      scopes: {MarkScope.field},
      args: [MarkArgument('form', 'How it is written.')],
      named: [
        MarkArgument('reading', 'How it is read.'),
        MarkArgument(
          'status',
          'How it is used: priority, valid, irregular, rare, outdated, or '
              'old.',
        ),
      ],
      content: MarkContent.forbidden,
      plainText: MarkKind.nothing,
    ),
    const MarkKind(
      'source',
      description: 'Where content comes from, such as a dictionary.',
      example: '{source JMdict url=https://www.edrdg.org/jmdict/}',
      scopes: {MarkScope.field},
      args: [MarkArgument('name', 'The name of the source.')],
      named: [
        MarkArgument('url', 'Where to find it.'),
        MarkArgument('date', 'The version or date of the source.'),
      ],
      content: MarkContent.forbidden,
      onRequest: true,
      plainText: MarkKind.nothing,
    ),
    const MarkKind(
      'audio',
      description: 'A sound file from the media store, such as a recording.',
      example: '{audio keshiki.mp3}',
      scopes: {MarkScope.field},
      args: [MarkArgument('file', 'The name of the file.')],
      content: MarkContent.forbidden,
      plainText: MarkKind.nothing,
    ),
    const MarkKind(
      'front',
      description: 'The front of the card: what is asked.',
      example: '{front | {field Word role=prompt}}',
      scopes: {MarkScope.template},
      topLevel: true,
      once: true,
      mandatory: true,
    ),
    const MarkKind(
      'back',
      description: 'The back of the card: the answer.',
      example: '{back | {field Meaning role=answer}}',
      scopes: {MarkScope.template},
      topLevel: true,
      once: true,
      mandatory: true,
    ),
    MarkKind(
      'field',
      description: "Where a field's value goes.",
      example: '{field Word role=prompt}',
      scopes: const {MarkScope.template},
      args: const [MarkArgument('name', 'The field.')],
      named: const [
        MarkArgument(
          'role',
          'What the field is on the card, such as prompt, reading, answer, '
              'or example; it decides the styling.',
        ),
        MarkArgument(
          'display',
          'How the value is shown instead of as text: badges shows each '
              '"label: value" line as a badge.',
        ),
        MarkArgument(
          'show',
          'Kinds kept in the value but left off cards to show anyway, such '
              'as "source forms".',
        ),
      ],
      content: MarkContent.forbidden,
      plainText: (mark, _) => '',
    ),
    const MarkKind(
      'if',
      description: 'Content shown only when the field is not empty.',
      example: '{if Example | {field Example}}',
      scopes: {MarkScope.template},
      args: [MarkArgument('name', 'The field to test.')],
    ),
    MarkKind(
      'requires',
      description:
          'The fields a note must fill for this template to generate a card.',
      example: '{requires Word Meaning}',
      scopes: const {MarkScope.template},
      args: const [MarkArgument('name', 'A field.')],
      repeatsLastArgument: true,
      content: MarkContent.forbidden,
      topLevel: true,
      plainText: (mark, _) => '',
    ),
  ]);

  final Map<String, MarkKind> _kinds;

  MarkKind? operator [](String key) => _kinds[key];

  /// Every kind, in the order given.
  Iterable<MarkKind> get all => _kinds.values;

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
        case CommentNode():
      }
    }
    return out.toString();
  }

  /// The marks in [nodes], at any depth, that are used in a way their kind
  /// does not allow in [scope], or whose kind is not known.
  ///
  /// A template is also checked as a whole: the marks that stand at its top
  /// level are there, once or as often as their kinds allow, and nothing
  /// but whitespace and comments is left outside them.
  List<MarkIssue> check(List<ContentNode> nodes, MarkScope scope) {
    final issues = <MarkIssue>[];
    final template = scope == MarkScope.template;
    if (template) {
      final seen = <String>{};
      for (final node in nodes) {
        switch (node) {
          case TextNode(:final text) when text.trim().isNotEmpty:
            issues.add(MarkIssue(MarkIssueKind.loose, node));
          case MarkNode(:final key):
            final kind = _kinds[key];
            if (kind == null || !kind.topLevel) {
              issues.add(MarkIssue(MarkIssueKind.loose, node));
            } else if (!seen.add(key) && kind.once) {
              issues.add(MarkIssue(MarkIssueKind.repeated, node));
            }
          default:
        }
      }
      for (final kind in all) {
        if (kind.mandatory && !seen.contains(kind.key)) {
          issues.add(
            MarkIssue(MarkIssueKind.missing, ContentNode.mark(kind.key)),
          );
        }
      }
    }
    void visit(List<ContentNode> nodes, {required bool top}) {
      for (final node in nodes) {
        if (node is! MarkNode) continue;
        final kind = _kinds[node.key];
        if (kind == null) {
          issues.add(MarkIssue(MarkIssueKind.unknownKind, node));
        } else {
          void add(MarkIssueKind issue) => issues.add(MarkIssue(issue, node));
          if (!kind.scopes.contains(scope)) add(MarkIssueKind.wrongScope);
          if (template && kind.topLevel && !top) add(MarkIssueKind.misplaced);
          final argsOk = kind.repeatsLastArgument
              ? node.args.length >= kind.args.length
              : node.args.length == kind.args.length;
          if (!argsOk) add(MarkIssueKind.wrongArgumentCount);
          final accepted = {for (final a in kind.named) a.name};
          if (node.named.keys.any((name) => !accepted.contains(name))) {
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
        if (node.content case final content?) visit(content, top: false);
      }
    }

    visit(nodes, top: true);
    return issues;
  }
}
