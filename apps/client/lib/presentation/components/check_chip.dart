import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icons.dart';
import 'pressable.dart';

/// A choice that is on or off, such as a field a template requires: its
/// label, with a check when it is on and a plus when it is not.
class CheckChip extends StatelessWidget {
  const CheckChip({
    super.key,
    required this.label,
    required this.checked,
    required this.onPressed,
  });

  final String label;
  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.sm);
    return Semantics(
      checked: checked,
      child: Pressable(
        onPressed: onPressed,
        borderRadius: radius,
        builder: (context, state) => AnimatedContainer(
          duration: Motion.quick,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm + 2,
            vertical: context.layout.dense(Spacing.xs + 2),
          ),
          decoration: BoxDecoration(
            color: checked
                ? colors.accent.soft
                : state.hovered || state.pressed
                ? colors.border
                : colors.surfaceSunken,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                checked ? MemukiIcons.check : MemukiIcons.add,
                size: 16,
                color: checked ? colors.accent.onSoft : colors.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                label,
                style: context.type.label.copyWith(
                  color: checked ? colors.accent.onSoft : colors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
