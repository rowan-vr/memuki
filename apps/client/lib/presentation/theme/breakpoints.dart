import 'package:flutter/widgets.dart';

/// Window size classes, following the Material 3 layout guidelines.
enum WindowSize {
  /// Phones in portrait. Below 600 px wide.
  compact,

  /// Tablets in portrait, small desktop windows. 600–839 px wide.
  medium,

  /// Tablets in landscape, desktop. 840 px and wider.
  expanded;

  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;

  static WindowSize fromWidth(double width) {
    if (width >= expandedMinWidth) return expanded;
    if (width >= mediumMinWidth) return medium;
    return compact;
  }

  static WindowSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
