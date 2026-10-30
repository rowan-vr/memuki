import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// The interaction state of a [Pressable], passed to its builder.
@immutable
class PressState {
  const PressState({
    required this.enabled,
    required this.hovered,
    required this.pressed,
    required this.focused,
  });

  final bool enabled;
  final bool hovered;
  final bool pressed;

  /// Focused by keyboard, so a focus ring is shown.
  final bool focused;
}

/// The interaction layer shared by Memuki's controls: tap, hover, keyboard
/// focus with a focus ring, activation with Enter or Space, the click cursor,
/// and button semantics. Controls draw themselves from the [PressState].
///
/// Disabled when [onPressed] is null.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.borderRadius = BorderRadius.zero,
    this.semanticLabel,
    this.selected,
  });

  final VoidCallback? onPressed;
  final Widget Function(BuildContext context, PressState state) builder;

  /// The shape the focus ring follows.
  final BorderRadius borderRadius;

  final String? semanticLabel;

  /// Whether the control is the selected one of a group, for semantics.
  final bool? selected;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool pressed) {
    if (_enabled && _pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final state = PressState(
      enabled: _enabled,
      hovered: _enabled && _hovered,
      pressed: _pressed,
      focused: _enabled && _focused,
    );
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onPressed,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: state.focused
                    ? Border.all(
                        color: context.colors.focus,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      )
                    : null,
              ),
              child: widget.builder(context, state),
            ),
          ),
        ),
      ),
    );
  }
}
