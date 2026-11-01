import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/content/content_node.dart';
import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../theme/app_theme.dart';

/// Builds the editor of one argument of a mark, in place of a text field.
typedef ArgumentEditorBuilder = Widget Function(
  BuildContext context,
  ArgumentEditing argument,
);

/// What an [ArgumentEditorBuilder] edits: one argument's value.
@immutable
class ArgumentEditing {
  const ArgumentEditing({
    required this.value,
    required this.onChanged,
    required this.onDone,
    this.focusNode,
  });

  final String value;
  final ValueChanged<String> onChanged;

  /// Returns to the text.
  final VoidCallback onDone;

  /// Focused when a new mark asks for its arguments; set on the first
  /// argument only.
  final FocusNode? focusNode;
}

/// A shortcut for a mark: [key] with the platform's primary modifier.
@immutable
class MarkShortcut {
  const MarkShortcut(this.key, {this.shift = false, this.alt = false});

  final LogicalKeyboardKey key;
  final bool shift;
  final bool alt;
}

/// How the field editor shows and applies one kind of mark in text. The
/// kind's meaning, its arguments and where it belongs, is in its `MarkKind`;
/// marks that stand on lines of their own, such as a dictionary sense, are
/// edited by their `BlockEditing` instead.
///
/// A kind without an entry is shown with a wavy underline and offered under
/// its key.
@immutable
class MarkEditing {
  const MarkEditing({
    this.label,
    this.icon,
    this.glyph,
    this.shortcut,
    this.style,
    this.extendsAtEnd = true,
    this.annotation,
    this.argumentLabels = const {},
    this.argumentEditors = const {},
    this.offered = true,
  });

  /// The name in the toolbar and the selection menu; the key when null.
  final String Function(AppLocalizations l10n)? label;

  /// The toolbar shows [icon], or else [glyph], or else the key.
  final IconData? icon;
  final String? glyph;

  final MarkShortcut? shortcut;

  /// How text in the mark looks, given the size of the text around it.
  final TextStyle Function(BuildContext context, MarkNode mark, double size)?
  style;

  /// Whether text typed right after the mark joins it.
  final bool extendsAtEnd;

  /// Text painted above the mark's text, such as a ruby's reading. The text
  /// under it is spread to make room when it is wider.
  final String? Function(MarkNode mark)? annotation;

  /// Labels of arguments, by name; the name when missing.
  final Map<String, String Function(AppLocalizations l10n)> argumentLabels;

  /// Editors of arguments, by name; a text field when missing.
  final Map<String, ArgumentEditorBuilder> argumentEditors;

  /// Whether the toolbar, the selection menu, and shortcuts offer it. Kinds
  /// that come from dictionaries are shown but not offered.
  final bool offered;

  /// The entries for the built-in kinds.
  static final Map<String, MarkEditing> builtIn = {
    'ruby': MarkEditing(
      label: (l10n) => l10n.editorRuby,
      glyph: 'あ',
      shortcut: const MarkShortcut(LogicalKeyboardKey.keyR, alt: true),
      style: (context, _, _) => TextStyle(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: context.colors.textFaint,
      ),
      // A reading belongs to exactly its base text.
      extendsAtEnd: false,
      annotation: (mark) => mark.args.firstOrNull,
      argumentLabels: {'reading': (l10n) => l10n.editorReading},
    ),
    'em': MarkEditing(
      label: (l10n) => l10n.editorEmphasis,
      icon: MemukiIcons.emphasis,
      shortcut: const MarkShortcut(LogicalKeyboardKey.keyB),
      style: (context, _, _) => TextStyle(
        fontWeight: FontWeight.w700,
        color: context.colors.accent.onSoft,
      ),
    ),
    // Editable text cannot raise or lower glyphs, so subscript and
    // superscript are smaller and use the font's own forms where it has them.
    'sub': MarkEditing(
      label: (l10n) => l10n.editorSubscript,
      icon: MemukiIcons.subscript,
      shortcut: const MarkShortcut(LogicalKeyboardKey.equal),
      style: (_, _, size) => TextStyle(
        fontSize: size * 0.7,
        fontFeatures: const [FontFeature.subscripts()],
      ),
    ),
    'sup': MarkEditing(
      label: (l10n) => l10n.editorSuperscript,
      icon: MemukiIcons.superscript,
      shortcut: const MarkShortcut(LogicalKeyboardKey.equal, shift: true),
      style: (_, _, size) => TextStyle(
        fontSize: size * 0.7,
        fontFeatures: const [FontFeature.superscripts()],
      ),
    ),
    'lang': MarkEditing(
      label: (l10n) => l10n.editorLanguage,
      icon: MemukiIcons.language,
      shortcut: const MarkShortcut(LogicalKeyboardKey.keyL, alt: true),
      style: (_, mark, _) => TextStyle(locale: localeOf(mark.args.firstOrNull)),
      argumentLabels: {'tag': (l10n) => l10n.editorLanguageTag},
    ),
    'tag': MarkEditing(
      offered: false,
      style: (context, _, _) => TextStyle(
        fontWeight: FontWeight.w700,
        color: context.colors.textMuted,
      ),
    ),
    'form': const MarkEditing(offered: false),
    'source': const MarkEditing(offered: false),
    'audio': const MarkEditing(offered: false, icon: MemukiIcons.audio),
  };
}

/// How text inside [mark] looks while editing, by [editing].
TextStyle markStyle(
  BuildContext context,
  Map<String, MarkEditing> editing,
  MarkNode mark,
  TextStyle? base,
) {
  final size = base?.fontSize ?? context.type.body.fontSize!;
  final entry = editing[mark.key];
  if (entry == null) {
    return TextStyle(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.wavy,
      decorationColor: context.colors.textFaint,
    );
  }
  return entry.style?.call(context, mark, size) ?? const TextStyle();
}

/// How an annotation, such as a ruby's reading, looks over its text.
TextStyle annotationStyle(BuildContext context) =>
    context.type.caption.copyWith(color: context.colors.textMuted, height: 1);

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
