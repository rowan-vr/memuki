import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// Draws [indicator] behind the selected one of a group of items and slides
/// it to the new item when the selection changes.
///
/// [builder] lays out the items, wrapping the part of each item the
/// indicator should cover with the `anchor` function it is given. The
/// indicator jumps rather than slides when the layout changes, such as when
/// the window is resized.
class SlidingIndicator extends StatefulWidget {
  const SlidingIndicator({
    super.key,
    required this.count,
    required this.selected,
    required this.indicator,
    required this.builder,
  });

  final int count;
  final int selected;
  final Widget indicator;
  final Widget Function(
    BuildContext context,
    Widget Function(int index, Widget child) anchor,
  )
  builder;

  @override
  State<SlidingIndicator> createState() => _SlidingIndicatorState();
}

class _SlidingIndicatorState extends State<SlidingIndicator> {
  final _stack = GlobalKey();
  late List<GlobalKey> _anchors;
  Rect? _rect;

  /// Whether the next move follows a change of selection, so it slides.
  bool _slide = false;

  /// How long the current move takes.
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _anchors = [for (var i = 0; i < widget.count; i++) GlobalKey()];
  }

  @override
  void didUpdateWidget(SlidingIndicator old) {
    super.didUpdateWidget(old);
    if (widget.count != old.count) {
      _anchors = [for (var i = 0; i < widget.count; i++) GlobalKey()];
    }
    if (widget.selected != old.selected) _slide = true;
  }

  void _measure() {
    if (!mounted) return;
    final stack = _stack.currentContext?.findRenderObject() as RenderBox?;
    final selected = widget.selected;
    final anchor = selected >= 0 && selected < _anchors.length
        ? _anchors[selected].currentContext?.findRenderObject() as RenderBox?
        : null;
    if (stack == null || anchor == null || !anchor.hasSize) return;
    final rect =
        anchor.localToGlobal(Offset.zero, ancestor: stack) & anchor.size;
    if (rect == _rect) return;
    setState(() {
      _duration = _slide && _rect != null && Motion.enabled(context)
          ? Motion.standard
          : Duration.zero;
      _slide = false;
      _rect = rect;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    final rect = _rect;
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          key: _stack,
          children: [
            if (rect != null)
              AnimatedPositioned.fromRect(
                rect: rect,
                duration: _duration,
                curve: Motion.spring,
                child: widget.indicator,
              ),
            widget.builder(
              context,
              (index, child) =>
                  KeyedSubtree(key: _anchors[index], child: child),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gives [child] a small springy bounce each time [active] turns on, such as
/// an icon as its destination is selected.
class Pop extends StatefulWidget {
  const Pop({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<Pop> createState() => _PopState();
}

class _PopState extends State<Pop> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.gentle,
    value: 1,
  );
  late final _scale = _controller.drive(
    Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: Motion.spring)),
  );

  @override
  void didUpdateWidget(Pop old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active && Motion.enabled(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

/// Fades [child] in while it rises a little, once, when it first appears.
/// Items with a higher [index] start slightly later, so a list arrives in a
/// short stagger.
class Entrance extends StatefulWidget {
  const Entrance({super.key, this.index = 0, required this.child});

  final int index;
  final Widget child;

  /// The delay between consecutive items.
  static const stagger = Duration(milliseconds: 40);

  /// Items after this many start together, so long lists do not trail.
  static const maxStaggered = 6;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final delay =
        Entrance.stagger * widget.index.clamp(0, Entrance.maxStaggered);
    _controller = AnimationController(
      vsync: this,
      duration: delay + Motion.standard,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isDismissed) {
      Motion.enabled(context) ? _controller.forward() : _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _controller.duration!.inMicroseconds;
    final start = total == 0 ? 0.0 : 1 - Motion.standard.inMicroseconds / total;
    final progress = _controller.drive(
      CurveTween(curve: Interval(start, 1, curve: Motion.settle)),
    );
    return FadeTransition(
      opacity: progress,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 8 * (1 - progress.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Fades [child] in with a small rise whenever [value] changes, such as the
/// page of the selected top-level destination.
class SwitchTransition extends StatefulWidget {
  const SwitchTransition({super.key, required this.value, required this.child});

  final Object? value;
  final Widget child;

  @override
  State<SwitchTransition> createState() => _SwitchTransitionState();
}

class _SwitchTransitionState extends State<SwitchTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.standard,
    value: 1,
  );
  late final _progress = _controller.drive(CurveTween(curve: Motion.settle));

  @override
  void didUpdateWidget(SwitchTransition old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && Motion.enabled(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _progress,
    child: AnimatedBuilder(
      animation: _progress,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - _progress.value)),
        child: child,
      ),
      child: widget.child,
    ),
  );
}
