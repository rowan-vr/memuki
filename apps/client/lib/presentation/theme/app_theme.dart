import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// Bundled typeface covering Latin, kana, and kanji with Japanese glyph
  /// forms. Bundling it avoids missing glyphs on systems without CJK fonts and
  /// Chinese glyph variants for Han characters.
  static const fontFamily = 'NotoSansJP';

  static const _seedColor = Color(0xFF3D6FB6);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      fontFamily: fontFamily,
    );
    return base.copyWith(
      textTheme: _withWeightAxis(base.textTheme),
      primaryTextTheme: _withWeightAxis(base.primaryTextTheme),
    );
  }

  /// The bundled font is a variable font. Sets its `wght` axis from each
  /// style's [FontWeight] so text theme weights render as intended.
  static TextTheme _withWeightAxis(TextTheme textTheme) {
    TextStyle? apply(TextStyle? style) {
      final weight = style?.fontWeight;
      if (style == null || weight == null) return style;
      return style.copyWith(
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
      );
    }

    return textTheme.copyWith(
      displayLarge: apply(textTheme.displayLarge),
      displayMedium: apply(textTheme.displayMedium),
      displaySmall: apply(textTheme.displaySmall),
      headlineLarge: apply(textTheme.headlineLarge),
      headlineMedium: apply(textTheme.headlineMedium),
      headlineSmall: apply(textTheme.headlineSmall),
      titleLarge: apply(textTheme.titleLarge),
      titleMedium: apply(textTheme.titleMedium),
      titleSmall: apply(textTheme.titleSmall),
      bodyLarge: apply(textTheme.bodyLarge),
      bodyMedium: apply(textTheme.bodyMedium),
      bodySmall: apply(textTheme.bodySmall),
      labelLarge: apply(textTheme.labelLarge),
      labelMedium: apply(textTheme.labelMedium),
      labelSmall: apply(textTheme.labelSmall),
    );
  }
}
