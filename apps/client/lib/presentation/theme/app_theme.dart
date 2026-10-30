import 'package:flutter/material.dart';

import 'contrast.dart';
import 'memuki_colors.dart';
import 'memuki_layout.dart';
import 'memuki_type.dart';

/// Builds the app's themes from Memuki's tokens.
///
/// The tokens are carried as theme extensions and read through
/// [MemukiThemeContext]. They are also mapped into Material's [ThemeData],
/// which remains only as app plumbing (text selection, scrolling, navigation),
/// so anything Material still draws looks like Memuki.
/// The user's appearance choices, from which the theme is built.
@immutable
class Appearance {
  const Appearance({
    this.mode = ColorMode.light,
    this.accent = MemukiAccent.blue,
    this.headingFace = HeadingFace.zenMaruGothic,
    this.cardStyle = CardStyle.notecard,
    this.density = Density.comfortable,
  });

  final ColorMode mode;
  final MemukiAccent accent;
  final HeadingFace headingFace;
  final CardStyle cardStyle;
  final Density density;

  Appearance copyWith({
    ColorMode? mode,
    MemukiAccent? accent,
    HeadingFace? headingFace,
    CardStyle? cardStyle,
    Density? density,
  }) => Appearance(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    headingFace: headingFace ?? this.headingFace,
    cardStyle: cardStyle ?? this.cardStyle,
    density: density ?? this.density,
  );
}

abstract final class AppTheme {
  static ThemeData light() => build(const Appearance());

  static ThemeData dark() => build(const Appearance(mode: ColorMode.dark));

  static ThemeData build(Appearance appearance) {
    final colors = MemukiColors.of(appearance.mode, appearance.accent);
    final layout = MemukiLayout(
      cardStyle: appearance.cardStyle,
      density: appearance.density,
    );
    final type = MemukiType.of(appearance.headingFace, colors.text);
    final scheme = ColorScheme(
      brightness: colors.brightness,
      primary: colors.accent.base,
      onPrimary: colors.accent.onBase,
      primaryContainer: colors.accent.soft,
      onPrimaryContainer: colors.accent.onSoft,
      secondary: colors.accent.base,
      onSecondary: colors.accent.onBase,
      secondaryContainer: colors.accent.soft,
      onSecondaryContainer: colors.accent.onSoft,
      error: colors.danger,
      onError: contrastRatio(Colors.white, colors.danger) >= 4.5
          ? Colors.white
          : colors.text,
      surface: colors.background,
      onSurface: colors.text,
      onSurfaceVariant: colors.textMuted,
      surfaceContainerLowest: colors.surfaceSunken,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surfaceRaised,
      surfaceContainerHighest: colors.surfaceRaised,
      outline: colors.border,
      outlineVariant: colors.border,
    );
    final base = ThemeData(
      colorScheme: scheme,
      fontFamily: MemukiType.bodyFamily,
      scaffoldBackgroundColor: colors.background,
      splashFactory: NoSplash.splashFactory,
      dividerColor: colors.border,
      extensions: [colors, type, layout],
    );
    return base.copyWith(
      textTheme: _withWeightAxis(base.textTheme).copyWith(
        headlineLarge: type.display,
        headlineMedium: type.title,
        headlineSmall: type.heading,
        titleLarge: type.title,
        bodyLarge: type.body,
        labelLarge: type.label,
        bodySmall: type.caption,
      ),
      primaryTextTheme: _withWeightAxis(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: type.title,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accent.soft,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.accent.soft,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent.base,
        selectionColor: colors.accent.soft,
        selectionHandleColor: colors.accent.base,
      ),
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

/// Access to Memuki's tokens from the current theme.
extension MemukiThemeContext on BuildContext {
  MemukiColors get colors => Theme.of(this).extension<MemukiColors>()!;
  MemukiType get type => Theme.of(this).extension<MemukiType>()!;
  MemukiLayout get layout => Theme.of(this).extension<MemukiLayout>()!;
}
