import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'animations.dart';
import 'pressable.dart';

/// A top-level destination in a [NavBar] or [NavRail].
@immutable
class NavDestination {
  const NavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The navigation along the bottom of compact windows: an icon and a label
/// per destination, the selected one on a tint of the accent that slides
/// over when the selection changes.
class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs + 2,
          ),
          child: SlidingIndicator(
            count: destinations.length,
            selected: selectedIndex,
            indicator: const _Indicator(pill: true),
            builder: (context, anchor) => Row(
              children: [
                for (final (i, d) in destinations.indexed)
                  Expanded(
                    child: _BarItem(
                      destination: d,
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                      anchor: (child) => anchor(i, child),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The selected destination's highlight, slid between destinations by a
/// [SlidingIndicator].
class _Indicator extends StatelessWidget {
  const _Indicator({required this.pill});

  final bool pill;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.accent.soft,
      borderRadius: BorderRadius.circular(pill ? Radii.pill : Radii.sm),
    ),
  );
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.anchor,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  /// Marks the part the [_Indicator] covers when selected.
  final Widget Function(Widget child) anchor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.accent.onSoft : colors.textMuted;
    return Pressable(
      onPressed: onTap,
      selected: selected,
      borderRadius: BorderRadius.circular(Radii.sm),
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            anchor(
              AnimatedContainer(
                duration: Motion.quick,
                curve: Motion.settle,
                width: 56,
                height: 30,
                decoration: BoxDecoration(
                  color: state.hovered && !selected
                      ? colors.surfaceSunken
                      : null,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Pop(
                  active: selected,
                  child: Icon(destination.icon, size: 20, color: fg),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.caption.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The navigation down the side of wider windows. Collapsed, it shows icons
/// with small labels under them; [extended], it is a sidebar with [title] at
/// the top and a row per destination.
class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.extended = false,
    this.title,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;

  /// Shown at the top when [extended], such as the app's name.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: extended ? 232 : 88,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? Spacing.md : Spacing.sm,
              vertical: Spacing.md,
            ),
            children: [
              if (extended && title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.sm + 2,
                    Spacing.xs,
                    0,
                    Spacing.lg,
                  ),
                  child: Text(title!, style: context.type.title),
                ),
              SlidingIndicator(
                count: destinations.length,
                selected: selectedIndex,
                indicator: _Indicator(pill: !extended),
                builder: (context, anchor) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, d) in destinations.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.xs),
                        child: extended
                            ? anchor(
                                i,
                                _RailRow(
                                  destination: d,
                                  selected: i == selectedIndex,
                                  onTap: () => onSelected(i),
                                ),
                              )
                            : _BarItem(
                                destination: d,
                                selected: i == selectedIndex,
                                onTap: () => onSelected(i),
                                anchor: (child) => anchor(i, child),
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.accent.onSoft : colors.textMuted;
    final radius = BorderRadius.circular(Radii.sm);
    return Pressable(
      onPressed: onTap,
      selected: selected,
      borderRadius: radius,
      builder: (context, state) => AnimatedContainer(
        duration: Motion.quick,
        curve: Motion.settle,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm + 2,
          vertical: context.layout.dense(Spacing.sm + 2),
        ),
        decoration: BoxDecoration(
          color: state.hovered && !selected ? colors.surfaceSunken : null,
          borderRadius: radius,
        ),
        child: Row(
          children: [
            Pop(
              active: selected,
              child: Icon(destination.icon, size: 20, color: fg),
            ),
            const SizedBox(width: Spacing.sm + 4),
            Expanded(
              child: Text(
                destination.label,
                style: context.type.label.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
