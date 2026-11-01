import 'package:flutter/material.dart';

import '../../domain/content/card_renderer.dart';
import '../../domain/content/content_node.dart';
import '../../domain/content/mark_kinds.dart';
import '../components/card_frame.dart';
import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'content_view.dart';

/// A rendered card in its frame: the front, and when [revealed] the back
/// under it. Each field is styled by its role, and shown as its placement's
/// `display` asks: `badges` shows each `label: value` line as a badge.
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
        block: (context, block) => switch (block.mark.named['display']) {
          'badges' => _Badges(
            MarkKinds.builtIn.plainText(block.mark.content ?? const []),
          ),
          _ => null,
        },
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

/// Each line of [text] as a badge: a `label: value` line as its label and
/// value side by side, and any other line as it is.
class _Badges extends StatelessWidget {
  const _Badges(this.text);

  final String text;

  static final _pair = RegExp(r'^([^:：]+)[:：]\s*(.+)$');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final tone = colors.swatches[MemukiAccent.green]!;
    final radius = BorderRadius.circular(Radii.xs);
    Widget part(String text, Color background, Color foreground, bool bold) =>
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs + 2,
            vertical: 2,
          ),
          color: background,
          child: Text(
            text,
            style: type.caption.copyWith(
              color: foreground,
              fontWeight: bold ? FontWeight.w700 : null,
              fontVariations: bold ? const [FontVariation.weight(700)] : null,
            ),
          ),
        );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final line in text.split('\n').map((l) => l.trim()))
          if (line.isNotEmpty)
            ClipRRect(
              borderRadius: radius,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: switch (_pair.firstMatch(line)) {
                  final m? => [
                    part(m[1]!.trim(), tone.base, tone.onBase, true),
                    part(m[2]!.trim(), tone.soft, tone.onSoft, false),
                  ],
                  null => [part(line, tone.soft, tone.onSoft, false)],
                },
              ),
            ),
      ],
    );
  }
}
