import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';

/// A small pill label, such as a note's tag or a card's level. Neutral unless
/// it has a [tone].
class Tag extends StatelessWidget {
  const Tag({super.key, required this.label, this.tone});

  final String label;
  final ToneColors? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm + 2,
        vertical: Spacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: tone?.soft ?? colors.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: context.type.caption.copyWith(
          color: tone?.onSoft ?? colors.textMuted,
        ),
      ),
    );
  }
}

/// A thin bar showing progress from 0 to 1.
class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.value, this.tone, this.label});

  final double value;

  /// Defaults to [MemukiColors.good].
  final ToneColors? tone;

  /// Read by screen readers, such as "12 of 42".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = value.clamp(0.0, 1.0);
    return Semantics(
      label: label,
      value: '${(fraction * 100).round()}%',
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedFractionallySizedBox(
          duration: Motion.standard,
          curve: Motion.settle,
          widthFactor: fraction,
          child: Container(
            decoration: BoxDecoration(
              color: (tone ?? colors.good).base,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
          ),
        ),
      ),
    );
  }
}
