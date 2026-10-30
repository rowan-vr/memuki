import 'package:flutter/widgets.dart';

/// Durations and curves. Motion is short and slightly springy; it confirms an
/// action and never makes the user wait.
abstract final class Motion {
  /// Presses, hovers, and toggles.
  static const quick = Duration(milliseconds: 120);

  /// Elements changing size or position.
  static const standard = Duration(milliseconds: 220);

  /// Elements entering, and moments such as flipping a card.
  static const gentle = Duration(milliseconds: 360);

  /// Settling into place without overshoot.
  static const settle = Curves.easeOutCubic;

  /// A small overshoot, for playful moments such as a card flip or a toggle.
  static const spring = Cubic(0.34, 1.36, 0.64, 1);

  /// Elements leaving.
  static const exit = Curves.easeInCubic;

  /// Whether to animate: false when the platform asks for reduced motion,
  /// in which case motion is left out or replaced by a fade.
  static bool enabled(BuildContext context) =>
      !MediaQuery.disableAnimationsOf(context);
}
