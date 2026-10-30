/// Corner radii in logical pixels. Generous rounding is part of Memuki's look;
/// nested shapes use a smaller radius than their container.
abstract final class Radii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  /// Fully rounded ends, for chips and pill buttons.
  static const double pill = 999;
}
