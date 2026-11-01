import 'package:flutter/material.dart';

import '../../domain/content/card_renderer.dart';
import '../../domain/content/content_node.dart';
import '../components/card_frame.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import 'content_view.dart';

/// A rendered card in its frame: the front, and when [revealed] the back
/// under it. Each field is styled by its role.
class CardView extends StatelessWidget {
  const CardView({
    super.key,
    required this.card,
    this.revealed = false,
    this.rendering,
  });

  final RenderedCard card;
  final bool revealed;

  /// How marks in the fields are shown; [MarkRendering.builtIn] by default.
  final Map<String, MarkRendering>? rendering;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final marks = {
      ...(rendering ?? MarkRendering.builtIn),
      'field': MarkRendering(
        style: (context, mark, base) =>
            roleStyle(context, mark.named['role'], base),
      ),
    };
    Widget side(List<ContentNode> nodes) =>
        ContentView(nodes, textAlign: TextAlign.center, rendering: marks);
    return CardFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          // Clear of the notecard's ruled header.
          Spacing.xxl + Spacing.lg,
          Spacing.lg,
          Spacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            side(card.front),
            if (revealed) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                child: Divider(height: 1, thickness: 1, color: colors.border),
              ),
              side(card.back),
            ],
          ],
        ),
      ),
    );
  }
}

/// How a field placed in [role] looks on a card, from the text around it.
/// A role without its own styling, or none, keeps [base].
TextStyle roleStyle(BuildContext context, String? role, TextStyle base) {
  final colors = context.colors;
  return switch (role) {
    'prompt' => base.copyWith(fontSize: 44, height: 1.3),
    'reading' => base.copyWith(fontSize: 18, color: colors.textMuted),
    'answer' => context.type.title,
    'example' => base.copyWith(color: colors.textMuted),
    _ => base,
  };
}
