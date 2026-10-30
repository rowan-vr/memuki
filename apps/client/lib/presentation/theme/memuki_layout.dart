import 'package:flutter/material.dart';

/// How cards are drawn during study and in previews.
enum CardStyle {
  /// A plain paper card.
  standard,

  /// An index card with a coloured top rule and a folded corner.
  notecard,

  /// Text on the background, without a card.
  minimal,
}

/// How tightly lists, rows, and panels are spaced.
enum Density {
  comfortable(1),
  compact(0.75);

  const Density(this.factor);

  /// Multiplies vertical padding and row spacing.
  final double factor;
}

/// Layout preferences that components read alongside colours and type.
@immutable
class MemukiLayout extends ThemeExtension<MemukiLayout> {
  const MemukiLayout({required this.cardStyle, required this.density});

  final CardStyle cardStyle;
  final Density density;

  /// [value] scaled for the density, for vertical padding and gaps.
  double dense(double value) => value * density.factor;

  @override
  MemukiLayout copyWith({CardStyle? cardStyle, Density? density}) =>
      MemukiLayout(
        cardStyle: cardStyle ?? this.cardStyle,
        density: density ?? this.density,
      );

  @override
  MemukiLayout lerp(MemukiLayout? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
