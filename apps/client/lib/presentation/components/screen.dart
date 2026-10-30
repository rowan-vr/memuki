import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'icons.dart';
import 'pressable.dart';

/// A page of the app: a [PageHeader] above the [body] on the desk.
class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;

  /// Shown at the end of the header, such as [IconAction]s.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: title, actions: actions),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// The top of a page: its title, a back button when there is a page to go
/// back to, and [actions].
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final canGoBack = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          canGoBack ? Spacing.sm : Spacing.lg,
          Spacing.md,
          Spacing.md,
          Spacing.xs,
        ),
        child: Row(
          children: [
            if (canGoBack) ...[
              IconAction(
                icon: MemukiIcons.back,
                semanticLabel: MaterialLocalizations.of(context)
                    .backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.title,
                ),
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(width: Spacing.xs),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

/// A button showing only an icon, such as in a [PageHeader]. [semanticLabel]
/// names it for screen readers.
class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Radii.sm);
    return Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      borderRadius: radius,
      builder: (context, state) => AnimatedContainer(
        duration: Motion.quick,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: state.pressed
              ? colors.border
              : state.hovered
              ? colors.surfaceSunken
              : null,
          borderRadius: radius,
        ),
        child: Icon(
          icon,
          size: 22,
          color: state.enabled ? colors.text : colors.textFaint,
        ),
      ),
    );
  }
}
