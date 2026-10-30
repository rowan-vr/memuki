import 'package:flutter/material.dart';

import 'contrast.dart';

/// Colour modes. Each has its own palette; none is derived from another.
enum ColorMode {
  light(Brightness.light),
  dark(Brightness.dark),
  sepia(Brightness.light);

  const ColorMode(this.brightness);

  final Brightness brightness;
}

/// Accent colours the user can choose from. The accent colours primary
/// actions, selection, and focus.
enum MemukiAccent { coral, orange, mustard, green, blue, purple, grey }

/// A colour with the colours drawn on it and its tinted background.
@immutable
class ToneColors {
  const ToneColors({
    required this.base,
    required this.onBase,
    required this.soft,
    required this.onSoft,
  });

  /// Derives the other colours from [base] for a palette with [background]
  /// and [text]: [soft] is [base] mixed into the background, and the colours
  /// drawn on each are the nearest that read at WCAG AA contrast.
  factory ToneColors.of(
    Color base, {
    required Color background,
    required Color text,
    required double softness,
  }) {
    final soft = Color.lerp(background, base, softness)!;
    const white = Color(0xFFFFFFFF);
    const ink = Color(0xFF1C1A17);
    final onBase = contrastRatio(white, base) >= contrastRatio(ink, base)
        ? white
        : ink;
    return ToneColors(
      base: base,
      onBase: onBase,
      soft: soft,
      onSoft: readableOn(soft, base, text),
    );
  }

  /// The solid colour, used for filled controls.
  final Color base;

  /// Text and icons on [base].
  final Color onBase;

  /// A tinted background, used for chips, highlights, and selected rows.
  final Color soft;

  /// Text and icons on [soft].
  final Color onSoft;

  static ToneColors lerp(ToneColors a, ToneColors b, double t) => ToneColors(
    base: Color.lerp(a.base, b.base, t)!,
    onBase: Color.lerp(a.onBase, b.onBase, t)!,
    soft: Color.lerp(a.soft, b.soft, t)!,
    onSoft: Color.lerp(a.onSoft, b.onSoft, t)!,
  );
}

/// Memuki's colour tokens: warm cream paper in light mode, neutral charcoal in
/// dark mode, and aged paper in sepia, with muted accents.
@immutable
class MemukiColors extends ThemeExtension<MemukiColors> {
  const MemukiColors({
    required this.mode,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.danger,
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
    required this.burned,
    required this.swatches,
  });

  factory MemukiColors.of(ColorMode mode, MemukiAccent accent) {
    final n = _neutrals[mode]!;
    final hues = _hues[mode]!;
    final softness = mode == ColorMode.dark ? 0.24 : 0.16;
    ToneColors tone(Color base) => ToneColors.of(
      base,
      background: n.surface,
      text: n.text,
      softness: softness,
    );
    return MemukiColors(
      mode: mode,
      background: n.background,
      surface: n.surface,
      surfaceRaised: n.raised,
      surfaceSunken: n.sunken,
      border: n.border,
      text: n.text,
      textMuted: n.muted,
      textFaint: n.faint,
      accent: tone(hues.accents[accent]!),
      danger: hues.accents[MemukiAccent.coral]!,
      again: tone(hues.again),
      hard: tone(hues.hard),
      good: tone(hues.good),
      easy: tone(hues.easy),
      burned: tone(hues.burned),
      swatches: {
        for (final MapEntry(:key, :value) in hues.accents.entries)
          key: tone(value),
      },
    );
  }

  final ColorMode mode;

  Brightness get brightness => mode.brightness;

  /// Behind everything; the desk.
  final Color background;

  /// Cards, sheets, and panels on [background].
  final Color surface;

  /// Surfaces above [surface], such as menus and dialogs.
  final Color surfaceRaised;

  /// Wells set into a surface, such as text fields and tracks.
  final Color surfaceSunken;

  final Color border;
  final Color text;

  /// Secondary text.
  final Color textMuted;

  /// Placeholders and disabled text. Not for text that must be read.
  final Color textFaint;

  /// The chosen accent, for primary actions, selection, and focus.
  final ToneColors accent;

  final Color danger;

  /// Grade colours.
  final ToneColors again;
  final ToneColors hard;
  final ToneColors good;
  final ToneColors easy;

  /// Burned cards.
  final ToneColors burned;

  /// Every accent colour, for decks and tags, which carry a colour of their
  /// own.
  final Map<MemukiAccent, ToneColors> swatches;

  /// Focus rings.
  Color get focus => accent.base;

  @override
  MemukiColors copyWith() => this;

  @override
  MemukiColors lerp(MemukiColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return MemukiColors(
      mode: t < 0.5 ? mode : other.mode,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      border: c(border, other.border),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textFaint: c(textFaint, other.textFaint),
      accent: ToneColors.lerp(accent, other.accent, t),
      danger: c(danger, other.danger),
      again: ToneColors.lerp(again, other.again, t),
      hard: ToneColors.lerp(hard, other.hard, t),
      good: ToneColors.lerp(good, other.good, t),
      easy: ToneColors.lerp(easy, other.easy, t),
      burned: ToneColors.lerp(burned, other.burned, t),
      swatches: {
        for (final key in swatches.keys)
          key: ToneColors.lerp(swatches[key]!, other.swatches[key]!, t),
      },
    );
  }
}

typedef _Neutrals = ({
  Color background,
  Color surface,
  Color raised,
  Color sunken,
  Color border,
  Color text,
  Color muted,
  Color faint,
});

const _neutrals = <ColorMode, _Neutrals>{
  ColorMode.light: (
    background: Color(0xFFF3EEE6),
    surface: Color(0xFFFBF9F5),
    raised: Color(0xFFFFFFFF),
    sunken: Color(0xFFEBE5DB),
    border: Color(0xFFE2DACD),
    text: Color(0xFF2A2724),
    muted: Color(0xFF635D55),
    faint: Color(0xFFA29B91),
  ),
  ColorMode.dark: (
    background: Color(0xFF1A1B1E),
    surface: Color(0xFF232428),
    raised: Color(0xFF2B2D32),
    sunken: Color(0xFF141517),
    border: Color(0xFF35373D),
    text: Color(0xFFECE9E4),
    muted: Color(0xFFA9A6A0),
    faint: Color(0xFF75736E),
  ),
  ColorMode.sepia: (
    background: Color(0xFFE9DEC8),
    surface: Color(0xFFF4ECDB),
    raised: Color(0xFFF9F2E4),
    sunken: Color(0xFFDFD2B8),
    border: Color(0xFFD5C6A8),
    text: Color(0xFF3A2E21),
    muted: Color(0xFF63523F),
    faint: Color(0xFF9C8A72),
  ),
};

typedef _Hues = ({
  Map<MemukiAccent, Color> accents,
  Color again,
  Color hard,
  Color good,
  Color easy,
  Color burned,
});

const _paperAccents = {
  MemukiAccent.coral: Color(0xFFB84A38),
  MemukiAccent.orange: Color(0xFFA9561A),
  MemukiAccent.mustard: Color(0xFF856310),
  MemukiAccent.green: Color(0xFF2E7650),
  MemukiAccent.blue: Color(0xFF26467A),
  MemukiAccent.purple: Color(0xFF654A96),
  MemukiAccent.grey: Color(0xFF55524D),
};

const _hues = <ColorMode, _Hues>{
  ColorMode.light: (
    accents: _paperAccents,
    again: Color(0xFFD9725F),
    hard: Color(0xFFDDAA48),
    good: Color(0xFF79AE86),
    easy: Color(0xFF86A8D2),
    burned: Color(0xFFE08A3C),
  ),
  ColorMode.sepia: (
    accents: _paperAccents,
    again: Color(0xFFD9725F),
    hard: Color(0xFFDDAA48),
    good: Color(0xFF79AE86),
    easy: Color(0xFF86A8D2),
    burned: Color(0xFFE08A3C),
  ),
  ColorMode.dark: (
    accents: {
      MemukiAccent.coral: Color(0xFFEF8C79),
      MemukiAccent.orange: Color(0xFFF0A461),
      MemukiAccent.mustard: Color(0xFFE2BE5E),
      MemukiAccent.green: Color(0xFF80C79C),
      MemukiAccent.blue: Color(0xFF86ABE2),
      MemukiAccent.purple: Color(0xFFB99FE6),
      MemukiAccent.grey: Color(0xFFB6B2AB),
    },
    again: Color(0xFFD8735F),
    hard: Color(0xFFD9A84B),
    good: Color(0xFF6FAA80),
    easy: Color(0xFF7A9FCF),
    burned: Color(0xFFE08A3C),
  ),
};
