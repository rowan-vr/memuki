import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icons.dart';
import 'panel.dart';
import 'pressable.dart';

/// A row in a list: an optional leading element, a title with an optional
/// subtitle, and a trailing element. A row with [onTap] shows a chevron unless
/// it has its own [trailing].
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final trailing =
        this.trailing ??
        (onTap == null
            ? null
            : Icon(MemukiIcons.forward, size: 20, color: colors.textMuted));
    Widget content(bool hovered) => AnimatedContainer(
      duration: Motion.quick,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: context.layout.dense(Spacing.sm + 2),
      ),
      decoration: BoxDecoration(
        color: hovered ? colors.surfaceSunken : null,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: Spacing.md)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: type.bodyStrong),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: type.caption.copyWith(color: colors.textMuted),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: Spacing.sm),
            trailing,
          ],
        ],
      ),
    );
    if (onTap == null) return content(false);
    return Pressable(
      onPressed: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      builder: (context, state) => content(state.hovered || state.pressed),
    );
  }
}

/// Rows on one panel, separated by hairlines.
class RowGroup extends StatelessWidget {
  const RowGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final border = context.colors.border;
    return Panel(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                color: border,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// A small square of a deck's or tag's colour.
class Swatch extends StatelessWidget {
  const Swatch({super.key, required this.color, this.size = 26});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Radii.xs),
    ),
  );
}
