import 'package:flutter/material.dart';

import 'motion.dart';

/// How a page opens: it slides in a short way from the end and fades in,
/// while the page below shifts back a little. Going back reverses it. With
/// reduced motion it only fades.
class MemukiPageTransitionsBuilder extends PageTransitionsBuilder {
  const MemukiPageTransitionsBuilder();

  @override
  Duration get transitionDuration => Motion.standard;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: Motion.settle,
      reverseCurve: Motion.exit,
    );
    if (!Motion.enabled(context)) {
      return FadeTransition(opacity: enter, child: child);
    }
    final below = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Motion.settle,
    );
    return SlideTransition(
      position: below.drive(
        Tween(begin: Offset.zero, end: const Offset(-0.04, 0)),
      ),
      child: SlideTransition(
        textDirection: Directionality.of(context),
        position: enter.drive(
          Tween(begin: const Offset(0.08, 0), end: Offset.zero),
        ),
        child: FadeTransition(opacity: enter, child: child),
      ),
    );
  }
}
