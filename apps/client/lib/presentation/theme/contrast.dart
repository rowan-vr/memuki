import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2 contrast ratio between two opaque colours, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// The colour on the way from [from] to [towards] closest to [from] that
/// reaches [ratio] contrast against [background], or [towards] if none does.
Color readableOn(
  Color background,
  Color from,
  Color towards, {
  double ratio = 4.5,
}) {
  for (var t = 0.0; t <= 1; t += 0.05) {
    final color = Color.lerp(from, towards, t)!;
    if (contrastRatio(color, background) >= ratio) return color;
  }
  return towards;
}
