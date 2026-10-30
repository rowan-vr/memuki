import 'package:flutter/widgets.dart';

import '../../domain/content/content_node.dart';
import '../../domain/content/marked_text.dart';
import '../components/indicators.dart';
import '../theme/app_theme.dart';

/// A text controller for content: its text is the content's text, and its
/// marks are ranges that follow edits.
///
/// Undo and redo cover the marks as well as the text, which Flutter's own
/// undo, holding only text, cannot.
class MarkedTextController extends TextEditingController {
  MarkedTextController([List<ContentNode> nodes = const []])
    : this._(MarkedText.fromNodes(nodes));

  MarkedTextController._(MarkedText content)
    : _ranges = content.ranges,
      super(text: content.text) {
    _history.add((value, _ranges));
  }

  List<MarkRange> _ranges;

  /// The marks, outer first.
  List<MarkRange> get ranges => _ranges;

  /// The content being edited.
  List<ContentNode> get nodes => MarkedText(text, _ranges).toNodes();

  set nodes(List<ContentNode> nodes) {
    final content = MarkedText.fromNodes(nodes);
    _ranges = content.ranges;
    super.value = TextEditingValue(
      text: content.text,
      selection: TextSelection.collapsed(offset: content.text.length),
    );
    _commit();
  }

  /// States to undo to; [_at] is the current one.
  final _history = <(TextEditingValue, List<MarkRange>)>[];
  var _at = 0;

  /// The kind of the last edit, and where the cursor was after it, so that
  /// typing a word is one step of undo.
  _Edit? _lastEdit;
  int _lastCursor = -1;

  static const _historyLimit = 200;

  @override
  set value(TextEditingValue next) {
    final previous = value;
    if (next.text == previous.text) {
      super.value = next;
      return;
    }
    final cursor = next.selection.isCollapsed
        ? next.selection.baseOffset
        : null;
    _ranges = shiftRanges(_ranges, previous.text, next.text, cursor: cursor);
    super.value = next;
    final edit = next.text.length > previous.text.length
        ? _Edit.insert
        : _Edit.delete;
    final continues =
        previous.composing.isValid ||
        next.composing.isValid ||
        (edit == _lastEdit &&
            previous.selection.baseOffset == _lastCursor &&
            !_endsWord(previous.text, next.text));
    _lastEdit = edit;
    _lastCursor = next.selection.baseOffset;
    _commit(merge: continues);
  }

  /// Whether the change typed whitespace, which ends a step of undo.
  static bool _endsWord(String before, String after) =>
      after.length > before.length &&
      after.runes.where((c) => c == 0x20 || c == 0x0A).length >
          before.runes.where((c) => c == 0x20 || c == 0x0A).length;

  void _commit({bool merge = false}) {
    _history.removeRange(_at + 1, _history.length);
    if (merge && _at > 0) {
      _history[_at] = (value, _ranges);
    } else {
      _history.add((value, _ranges));
      if (_history.length > _historyLimit) _history.removeAt(0);
      _at = _history.length - 1;
    }
  }

  bool get canUndo => _at > 0;
  bool get canRedo => _at < _history.length - 1;

  void undo() {
    if (!canUndo) return;
    _at--;
    _restore();
  }

  void redo() {
    if (!canRedo) return;
    _at++;
    _restore();
  }

  void _restore() {
    final (v, r) = _history[_at];
    _ranges = r;
    _lastEdit = null;
    super.value = v.copyWith(composing: TextRange.empty);
  }

  void _changeMarks(List<MarkRange> ranges) {
    _ranges = ranges;
    _lastEdit = null;
    _commit();
    notifyListeners();
  }

  /// Toggles [mark] over the selection: see [toggleMark].
  void toggle(MarkNode mark) {
    if (!selection.isValid) return;
    _changeMarks(toggleMark(_ranges, mark, selection.start, selection.end));
  }

  /// Whether the selection is all marked with [key].
  bool isMarked(String key) =>
      selection.isValid &&
      hasMark(_ranges, key, selection.start, selection.end);

  /// The innermost mark the selection is in that [test] accepts.
  MarkRange? markAtSelection(bool Function(MarkRange range) test) {
    if (!selection.isValid) return null;
    return nested(_ranges)
        .where(
          (r) =>
              !r.atom &&
              r.start <= selection.start &&
              selection.end <= r.end &&
              test(r),
        )
        .lastOrNull;
  }

  /// Replaces the node of [range], such as to change a ruby's reading. Typing
  /// in the same mark's arguments is one step of undo.
  void replace(MarkRange range, MarkNode mark) {
    final at = _ranges.indexOf(range);
    if (at < 0) return;
    _ranges = [..._ranges]..[at] = range.withNode(mark);
    final continues = _lastEdit == _Edit.argument && _lastCursor == range.start;
    _lastEdit = _Edit.argument;
    _lastCursor = range.start;
    _commit(merge: continues);
    notifyListeners();
  }

  /// Takes [range] off, keeping its text.
  void remove(MarkRange range) => _changeMarks([
    for (final r in _ranges)
      if (r != range) r,
  ]);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    final cuts = <int>{0, text.length};
    for (final r in _ranges) {
      cuts.addAll([r.start, r.end]);
    }
    if (composing.isValid) cuts.addAll([composing.start, composing.end]);
    final points = cuts.where((c) => c <= text.length).toList()..sort();
    final spread = _rubySpacing(context, style);
    final children = <InlineSpan>[];
    for (var i = 0; i + 1 < points.length; i++) {
      final a = points[i];
      final b = points[i + 1];
      final active = _ranges.where((r) => r.contains(a, b));
      if (active.where((r) => r.atom).firstOrNull case final atom?) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _Atom(atom.node),
          ),
        );
        continue;
      }
      var s = const TextStyle();
      for (final r in active) {
        s = s.merge(markStyle(context, r.node as MarkNode, style));
      }
      for (final r in active) {
        if (spread[r] case final spacing?) {
          s = s.merge(TextStyle(letterSpacing: spacing));
        }
      }
      if (composing.isValid && composing.start <= a && b <= composing.end) {
        s = s.merge(const TextStyle(decoration: TextDecoration.underline));
      }
      children.add(TextSpan(text: text.substring(a, b), style: s));
    }
    return TextSpan(style: style, children: children);
  }

  /// The letter spacing that widens the base text of each ruby whose reading
  /// is wider, so that the reading fits over it rather than over its
  /// neighbours.
  Map<MarkRange, double> _rubySpacing(BuildContext context, TextStyle? style) {
    final out = <MarkRange, double>{};
    for (final r in _ranges) {
      if (r.key != 'ruby' || r.end > text.length) continue;
      final reading = (r.node as MarkNode).args.firstOrNull ?? '';
      if (reading.isEmpty) continue;
      final base = text.substring(r.start, r.end);
      final extra =
          _width(reading, rubyReadingStyle(context), context) -
          _width(base, style, context);
      if (extra > 0) out[r] = extra / base.characters.length;
    }
    return out;
  }

  static double _width(String text, TextStyle? style, BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}

enum _Edit { insert, delete, argument }

/// How a ruby's reading looks over its base text.
TextStyle rubyReadingStyle(BuildContext context) =>
    context.type.caption.copyWith(color: context.colors.textMuted, height: 1);

/// How text inside [mark] looks while editing.
///
/// Editable text cannot raise or lower glyphs, so subscript and superscript
/// are smaller and use the font's own forms where it has them.
TextStyle markStyle(BuildContext context, MarkNode mark, TextStyle? base) {
  final colors = context.colors;
  final size = base?.fontSize ?? context.type.body.fontSize!;
  return switch (mark.key) {
    'em' => TextStyle(fontWeight: FontWeight.w700, color: colors.accent.onSoft),
    'sub' => TextStyle(
      fontSize: size * 0.7,
      fontFeatures: const [FontFeature.subscripts()],
    ),
    'sup' => TextStyle(
      fontSize: size * 0.7,
      fontFeatures: const [FontFeature.superscripts()],
    ),
    'lang' => TextStyle(locale: localeOf(mark.args.firstOrNull)),
    'ruby' => TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: colors.textFaint,
    ),
    _ => TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
      decorationColor: colors.textFaint,
    ),
  };
}

/// A rough locale from a BCP 47 tag: language, then a script or region.
Locale? localeOf(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final parts = tag.split('-');
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: parts.skip(1).where((p) => p.length == 4).firstOrNull,
    countryCode: parts.skip(1).where((p) => p.length != 4).firstOrNull,
  );
}

/// A comment or a mark without content, shown whole.
class _Atom extends StatelessWidget {
  const _Atom(this.node);

  final ContentNode node;

  @override
  Widget build(BuildContext context) => Tag(
    label: switch (node) {
      CommentNode(:final text) => '# $text',
      MarkNode(:final key, :final args) => [key, ...args].join(' '),
      TextNode(:final text) => text,
    },
  );
}
