import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'panel.dart';
import 'pressable.dart';

/// An option of a [SegmentedChoice].
@immutable
class Choice<T> {
  const Choice(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Picks one of a few options, shown side by side in a sunken track with the
/// selected one raised. Options wrap onto further lines when they do not fit.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final List<Choice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Wrap(
        children: [
          for (final choice in choices)
            _Segment(
              choice: choice,
              selected: choice.value == selected,
              onTap: () => onSelected(choice.value),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final Choice<T> choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.sm - 3);
    final fg = selected ? colors.text : colors.textMuted;
    return Pressable(
      onPressed: onTap,
      selected: selected,
      borderRadius: radius,
      builder: (context, state) => AnimatedContainer(
        duration: Motion.quick,
        curve: Motion.settle,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md - 4,
          vertical: context.layout.dense(Spacing.xs + 2),
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.surfaceRaised
              : state.hovered
              ? colors.border.withValues(alpha: 0.5)
              : null,
          borderRadius: radius,
          boxShadow: selected ? paperShadow(colors) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (choice.icon != null) ...[
              Icon(choice.icon, size: 16, color: fg),
              const SizedBox(width: Spacing.xs + 2),
            ],
            Text(choice.label, style: context.type.label.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
