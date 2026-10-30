import 'package:flutter/material.dart';

/// Heading typeface candidates, compared in the component catalogue until the
/// heading typeface is settled. Body text always uses Noto Sans JP.
enum HeadingFace {
  fraunces('Fraunces', serif: true),
  sourceSerif('SourceSerif4', serif: true),
  zenMaruGothic('ZenMaruGothic'),
  mPlusRounded('MPLUSRounded1c');

  const HeadingFace(this.family, {this.serif = false});

  final String family;
  final bool serif;
}

/// Memuki's type scale. Headings use a face with character; body text and
/// labels use Noto Sans JP, which also backs the heading faces for Japanese and
/// other glyphs they lack.
@immutable
class MemukiType extends ThemeExtension<MemukiType> {
  const MemukiType({
    required this.display,
    required this.title,
    required this.heading,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
  });

  /// Bundled typeface covering Latin, kana, and kanji with Japanese glyph
  /// forms. Bundling it avoids missing glyphs on systems without CJK fonts and
  /// Chinese glyph variants for Han characters.
  static const bodyFamily = 'NotoSansJP';

  factory MemukiType.of(HeadingFace face, Color color) {
    TextStyle headingStyle(double size, double height) => TextStyle(
      fontFamily: face.family,
      fontFamilyFallback: const [bodyFamily],
      fontSize: size,
      height: height / size,
      fontWeight: face.serif ? FontWeight.w600 : FontWeight.w700,
      fontVariations: [
        FontVariation.weight(face.serif ? 600 : 700),
        // Rounds Fraunces' terminals slightly; other faces ignore the axis.
        if (face == HeadingFace.fraunces) const FontVariation('SOFT', 50),
      ],
      letterSpacing: 0,
      color: color,
    );
    TextStyle bodyStyle(double size, double height, FontWeight weight) =>
        TextStyle(
          fontFamily: bodyFamily,
          fontSize: size,
          height: height / size,
          fontWeight: weight,
          fontVariations: [FontVariation.weight(weight.value.toDouble())],
          letterSpacing: 0,
          color: color,
        );
    return MemukiType(
      display: headingStyle(32, 40),
      title: headingStyle(24, 32),
      heading: headingStyle(19, 26),
      body: bodyStyle(16, 24, FontWeight.w400),
      bodyStrong: bodyStyle(16, 24, FontWeight.w600),
      label: bodyStyle(14, 20, FontWeight.w600),
      caption: bodyStyle(12.5, 18, FontWeight.w500),
    );
  }

  /// Large screen titles and greetings.
  final TextStyle display;

  /// Screen and section titles.
  final TextStyle title;

  /// Headings within a screen.
  final TextStyle heading;

  final TextStyle body;
  final TextStyle bodyStrong;

  /// Buttons, tabs, and form labels.
  final TextStyle label;

  /// Secondary details and metadata.
  final TextStyle caption;

  @override
  MemukiType copyWith() => this;

  @override
  MemukiType lerp(MemukiType? other, double t) {
    if (other == null) return this;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return MemukiType(
      display: s(display, other.display),
      title: s(title, other.title),
      heading: s(heading, other.heading),
      body: s(body, other.body),
      bodyStrong: s(bodyStrong, other.bodyStrong),
      label: s(label, other.label),
      caption: s(caption, other.caption),
    );
  }
}
