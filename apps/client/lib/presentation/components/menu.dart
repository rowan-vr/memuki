import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icons.dart';
import 'panel.dart';
import 'pressable.dart';
import 'segmented_choice.dart';

/// An entry of a [Menu]. Disabled when [onPressed] is null.
@immutable
class MenuItem {
  const MenuItem({
    required this.label,
    required this.onPressed,
    this.icon,
    this.description,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// A line under the label saying what the entry does.
  final String? description;

  /// Marked with a check, for the current choice of a [MenuChip].
  final bool selected;
}

/// A menu of [items] that opens under the control [builder] draws, when the
/// control calls the toggle it is given. It closes when an item is picked,
/// on a tap outside it, and with Escape.
class Menu extends StatefulWidget {
  const Menu({super.key, required this.items, required this.builder});

  final List<MenuItem> items;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final _menu = OverlayPortalController();
  final _link = LayerLink();

  static const _maxWidth = 300.0;

  /// Whether the menu lines up with the control's end rather than its
  /// start, because it would run off the screen.
  var _alignEnd = false;

  void _toggle() {
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box != null && overlay != null) {
      final left = box.localToGlobal(Offset.zero, ancestor: overlay).dx;
      _alignEnd = left + _maxWidth > overlay.size.width;
    }
    _menu.toggle();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: OverlayPortal(
      controller: _menu,
      overlayChildBuilder: _buildMenu,
      child: widget.builder(context, _toggle),
    ),
  );

  Widget _buildMenu(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    child: CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: _alignEnd ? Alignment.bottomRight : Alignment.bottomLeft,
      followerAnchor: _alignEnd ? Alignment.topRight : Alignment.topLeft,
      offset: const Offset(0, Spacing.xs),
      child: TapRegion(
        onTapOutside: (_) => _menu.hide(),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): _menu.hide,
          },
          child: FocusScope(
            autofocus: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 160,
                maxWidth: _maxWidth,
                maxHeight: 360,
              ),
              child: Panel(
                padding: const EdgeInsets.all(Spacing.xs),
                child: SingleChildScrollView(
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final item in widget.items)
                          _Item(
                            item: item,
                            onPressed: item.onPressed == null
                                ? null
                                : () {
                                    _menu.hide();
                                    item.onPressed!();
                                  },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.onPressed});

  final MenuItem item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final radius = BorderRadius.circular(Radii.sm - 2);
    final enabled = onPressed != null;
    return Pressable(
      onPressed: onPressed,
      selected: item.selected,
      borderRadius: radius,
      builder: (context, state) => AnimatedContainer(
        duration: Motion.quick,
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: context.layout.dense(Spacing.sm),
        ),
        decoration: BoxDecoration(
          color: state.hovered || state.pressed ? colors.surfaceSunken : null,
          borderRadius: radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.icon case final icon?) ...[
              Icon(
                icon,
                size: 18,
                color: enabled ? colors.textMuted : colors.textFaint,
              ),
              const SizedBox(width: Spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: type.label.copyWith(
                      color: enabled ? colors.text : colors.textFaint,
                    ),
                  ),
                  if (item.description case final description?)
                    Text(
                      description,
                      style: type.caption.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ),
            if (item.selected) ...[
              const SizedBox(width: Spacing.sm),
              Icon(MemukiIcons.check, size: 16, color: colors.accent.base),
            ],
          ],
        ),
      ),
    );
  }
}

/// Picks one of a list of options from a [Menu] that opens under it. Shows
/// the selected option's label, or [placeholder] when none of [choices] is
/// selected. Tinted with [tone] when given.
class MenuChip<T> extends StatelessWidget {
  const MenuChip({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
    this.placeholder,
    this.tone,
  });

  final List<Choice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  /// What is picked, for screen readers, such as "Field".
  final String semanticLabel;

  /// Shown when [selected] is not one of [choices]; the selected value as
  /// text when null.
  final String? placeholder;

  final ToneColors? tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = choices.where((c) => c.value == selected).firstOrNull;
    final label = current?.label ?? placeholder ?? '$selected';
    final radius = BorderRadius.circular(Radii.sm);
    final fg =
        tone?.onSoft ?? (current == null ? colors.textMuted : colors.text);
    return Menu(
      items: [
        for (final choice in choices)
          MenuItem(
            label: choice.label,
            icon: choice.icon,
            selected: choice.value == selected,
            onPressed: () => onSelected(choice.value),
          ),
      ],
      builder: (context, toggle) => Pressable(
        onPressed: toggle,
        semanticLabel: '$semanticLabel: $label',
        borderRadius: radius,
        builder: (context, state) => AnimatedContainer(
          duration: Motion.quick,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm + 2,
            vertical: context.layout.dense(Spacing.xs + 2),
          ),
          decoration: BoxDecoration(
            color: state.hovered || state.pressed
                ? Color.lerp(tone?.soft ?? colors.surfaceSunken, fg, 0.12)
                : tone?.soft ?? colors.surfaceSunken,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.label.copyWith(color: fg),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(MemukiIcons.expand, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
