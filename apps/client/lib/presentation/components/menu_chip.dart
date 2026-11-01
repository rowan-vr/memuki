import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icons.dart';
import 'panel.dart';
import 'pressable.dart';
import 'segmented_choice.dart';

/// Picks one of a list of options from a menu that opens under it. Shows the
/// selected option's label, or [placeholder] when none of [choices] is
/// selected.
class MenuChip<T> extends StatefulWidget {
  const MenuChip({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
    this.placeholder,
  });

  final List<Choice<T>> choices;
  final T selected;
  final ValueChanged<T> onSelected;

  /// What is picked, for screen readers, such as "Field".
  final String semanticLabel;

  /// Shown when [selected] is not one of [choices]; the selected value as
  /// text when null.
  final String? placeholder;

  @override
  State<MenuChip<T>> createState() => _MenuChipState<T>();
}

class _MenuChipState<T> extends State<MenuChip<T>> {
  final _menu = OverlayPortalController();
  final _link = LayerLink();

  void _pick(T value) {
    _menu.hide();
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final current = widget.choices
        .where((c) => c.value == widget.selected)
        .firstOrNull;
    final label = current?.label ?? widget.placeholder ?? '${widget.selected}';
    final radius = BorderRadius.circular(Radii.sm);
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _menu,
        overlayChildBuilder: _buildMenu,
        child: Pressable(
          onPressed: _menu.toggle,
          semanticLabel: '${widget.semanticLabel}: $label',
          borderRadius: radius,
          builder: (context, state) => AnimatedContainer(
            duration: Motion.quick,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm + 2,
              vertical: context.layout.dense(Spacing.xs + 2),
            ),
            decoration: BoxDecoration(
              color: state.hovered || state.pressed
                  ? colors.border
                  : colors.surfaceSunken,
              borderRadius: radius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: type.label.copyWith(
                      color: current == null ? colors.textMuted : colors.text,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Icon(MemukiIcons.expand, size: 16, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final type = context.type;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
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
                  maxWidth: 280,
                  maxHeight: 320,
                ),
                child: Panel(
                  padding: const EdgeInsets.all(Spacing.xs),
                  child: SingleChildScrollView(
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final choice in widget.choices)
                            _Item(
                              label: choice.label,
                              selected: choice.value == widget.selected,
                              onPressed: () => _pick(choice.value),
                              style: type.label,
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
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.sm - 2);
    return Pressable(
      onPressed: onPressed,
      selected: selected,
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
          children: [
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: Spacing.sm),
            Opacity(
              opacity: selected ? 1 : 0,
              child: Icon(
                MemukiIcons.check,
                size: 16,
                color: colors.accent.base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
