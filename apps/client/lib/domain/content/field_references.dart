import 'content_node.dart';
import 'content_writer.dart';

/// The marks of a template that name fields: `field` and `if` by their first
/// argument, `requires` by each of its arguments.
const _placing = {'field', 'if'};

/// The names of the fields [nodes], a template, refers to.
Set<String> fieldReferences(List<ContentNode> nodes) {
  final out = <String>{};
  void visit(List<ContentNode> nodes) {
    for (final node in nodes) {
      if (node is! MarkNode) continue;
      if (_placing.contains(node.key)) {
        if (node.args.firstOrNull case final name?) out.add(name);
      } else if (node.key == 'requires') {
        out.addAll(node.args);
      }
      if (node.content case final content?) visit(content);
    }
  }

  visit(nodes);
  return out;
}

/// [nodes], a template, with its references to the field [from] naming [to]
/// instead.
List<ContentNode> renameFieldReferences(
  List<ContentNode> nodes,
  String from,
  String to,
) => [
  for (final node in nodes)
    switch (node) {
      MarkNode(:final key, :final args, :final content) => node.copyWith(
        args: [
          for (final (i, arg) in args.indexed)
            arg == from &&
                    (key == 'requires' || (i == 0 && _placing.contains(key)))
                ? to
                : arg,
        ],
        content: content == null
            ? null
            : renameFieldReferences(content, from, to),
      ),
      _ => node,
    },
];

/// [nodes], a template, without the field [name]: its placements go, an
/// `if` on it goes with what it shows, as the field is never filled, and
/// `requires` no longer names it, going when it names nothing else.
List<ContentNode> removeFieldReferences(List<ContentNode> nodes, String name) {
  final out = <ContentNode>[];
  for (final node in nodes) {
    switch (node) {
      case MarkNode(:final key, :final args)
          when _placing.contains(key) && args.firstOrNull == name:
        continue;
      case MarkNode(key: 'requires', :final args) when args.contains(name):
        final rest = [
          for (final a in args)
            if (a != name) a,
        ];
        if (rest.isNotEmpty) out.add(node.copyWith(args: rest));
      case MarkNode(:final content?):
        out.add(node.copyWith(content: removeFieldReferences(content, name)));
      default:
        out.add(node);
    }
  }
  return out;
}

/// A template that asks with the first of [fields] and answers with the
/// rest, each on a line of its own, for a note type that does not yet have
/// one of its own.
String basicTemplateSource(List<String> fields) {
  MarkNode place(String name, String? role) =>
      MarkNode('field', args: [name], named: {'role': ?role});
  List<ContentNode> lines(Iterable<ContentNode> nodes) => [
    for (final (i, node) in nodes.indexed) ...[
      if (i > 0) const TextNode('\n'),
      node,
    ],
  ];
  return writeContent([
    MarkNode(
      'front',
      content: lines([
        if (fields.firstOrNull case final first?) place(first, 'prompt'),
      ]),
    ),
    const TextNode('\n'),
    MarkNode(
      'back',
      content: lines([
        for (final (i, name) in fields.skip(1).indexed)
          place(name, i == 0 ? 'answer' : null),
      ]),
    ),
  ]);
}
