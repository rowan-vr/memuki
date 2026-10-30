import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';

/// The soft shadow of paper lying on the desk.
List<BoxShadow> paperShadow(MemukiColors colors) {
  final light = colors.brightness == Brightness.light;
  return [
    BoxShadow(
      color: light ? const Color(0x14473A28) : const Color(0x59000000),
      blurRadius: 1,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: light ? const Color(0x0F473A28) : const Color(0x40000000),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

/// A paper panel on the desk, grouping related content.
///
/// [padding] defaults to the standard panel padding, scaled vertically for
/// the density.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: Spacing.md + 4,
            vertical: context.layout.dense(Spacing.md + 4),
          ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: colors.border),
        boxShadow: paperShadow(colors),
      ),
      child: child,
    );
  }
}

/// A heading above a section, with an optional action on the right, such as
/// "See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;

  /// Usually a [QuietButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: context.type.heading),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
