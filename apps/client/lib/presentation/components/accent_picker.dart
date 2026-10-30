import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'pressable.dart';

/// Picks an accent colour from the palette, one dot per colour with a ring
/// around the selected one. [labelOf] names each colour for screen readers.
class AccentPicker extends StatelessWidget {
  const AccentPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.labelOf = _name,
  });

  static String _name(MemukiAccent accent) => accent.name;

  final MemukiAccent selected;
  final ValueChanged<MemukiAccent> onSelected;
  final String Function(MemukiAccent accent) labelOf;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: Spacing.xs + 2,
      runSpacing: Spacing.xs,
      children: [
        for (final accent in MemukiAccent.values)
          Pressable(
            onPressed: () => onSelected(accent),
            selected: accent == selected,
            semanticLabel: labelOf(accent),
            borderRadius: BorderRadius.circular(Radii.pill),
            builder: (context, state) => AnimatedContainer(
              duration: Motion.quick,
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent == selected
                      ? colors.text
                      : const Color(0x00000000),
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.swatches[accent]!.base,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
