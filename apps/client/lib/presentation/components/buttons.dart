import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'pressable.dart';

/// How prominent a [Button] is.
enum ButtonKind {
  /// The main action of a screen or panel, filled with the accent.
  primary,

  /// Other actions, outlined on paper.
  secondary,
}

/// A labelled button, with an optional leading icon. Disabled when
/// [onPressed] is null.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = ButtonKind.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonKind kind;

  /// Fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primary = kind == ButtonKind.primary;
    final fg = primary ? colors.accent.onBase : colors.text;
    final radius = BorderRadius.circular(Radii.sm);
    return Pressable(
      onPressed: onPressed,
      borderRadius: radius,
      builder: (context, state) {
        final base = primary ? colors.accent.base : colors.surface;
        return _Press(
          state: state,
          child: AnimatedContainer(
            duration: Motion.quick,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: context.layout.dense(Spacing.sm + 4),
            ),
            decoration: BoxDecoration(
              color: _hover(base, fg, state),
              borderRadius: radius,
              border: primary
                  ? null
                  : Border.all(color: colors.border, width: 1.5),
            ),
            child: _Label(label: label, icon: icon, color: fg, expand: expand),
          ),
        );
      },
    );
  }
}

/// A low-emphasis text button, such as "See all" or "Cancel".
class QuietButton extends StatelessWidget {
  const QuietButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.xs);
    return Pressable(
      onPressed: onPressed,
      borderRadius: radius,
      builder: (context, state) => _Press(
        state: state,
        child: AnimatedContainer(
          duration: Motion.quick,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs + 2,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: state.hovered ? colors.accent.soft : null,
            borderRadius: radius,
          ),
          child: _Label(label: label, icon: icon, color: colors.accent.onSoft),
        ),
      ),
    );
  }
}

/// One of the four grade buttons shown while studying: the grade and the
/// interval it leads to, on a soft tint of the grade's colour.
class GradeButton extends StatelessWidget {
  const GradeButton({
    super.key,
    required this.label,
    required this.interval,
    required this.tone,
    required this.onPressed,
  });

  final String label;
  final String interval;

  /// The grade's colour, such as [MemukiColors.good].
  final ToneColors tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    final radius = BorderRadius.circular(Radii.sm);
    return Pressable(
      onPressed: onPressed,
      borderRadius: radius,
      semanticLabel: '$label, $interval',
      builder: (context, state) => _Press(
        state: state,
        scale: 0.95,
        child: AnimatedContainer(
          duration: Motion.quick,
          padding: EdgeInsets.symmetric(
            vertical: context.layout.dense(Spacing.sm + 4),
          ),
          decoration: BoxDecoration(
            color: _hover(tone.soft, tone.onSoft, state),
            borderRadius: radius,
          ),
          child: ExcludeSemantics(
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: type.label.copyWith(color: tone.onSoft),
                ),
                Text(
                  interval,
                  textAlign: TextAlign.center,
                  style: type.caption.copyWith(color: tone.onSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [base] with a wash of [ink] while hovered or pressed.
Color _hover(Color base, Color ink, PressState state) {
  final amount = state.pressed
      ? 0.14
      : state.hovered
      ? 0.08
      : 0.0;
  return Color.alphaBlend(ink.withValues(alpha: amount), base);
}

/// Shrinks slightly while pressed and springs back on release; fades when
/// disabled.
class _Press extends StatelessWidget {
  const _Press({required this.state, required this.child, this.scale = 0.97});

  final PressState state;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Motion.quick,
      opacity: state.enabled ? 1 : 0.45,
      child: AnimatedScale(
        scale: state.pressed ? scale : 1,
        duration: Motion.quick,
        curve: state.pressed ? Motion.settle : Motion.spring,
        child: child,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.label,
    required this.icon,
    required this.color,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: Spacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.type.label.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
