import 'package:flutter/material.dart';

import '../../components/screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import 'chunky_review.dart';
import 'mascot_review.dart';
import 'paper_review.dart';
import 'stationery_review.dart';

/// Candidate visual concepts.
enum VisualConcept { stationery, paper, chunky, mascot }

/// A debug-only screen comparing visual concepts on a mock review screen.
///
/// Each concept uses its own colours rather than Memuki's tokens, since the
/// tokens follow from whichever concept is chosen. It is a development tool,
/// so its text is not localized.
class ConceptsScreen extends StatefulWidget {
  const ConceptsScreen({super.key});

  @override
  State<ConceptsScreen> createState() => _ConceptsScreenState();
}

class _ConceptsScreenState extends State<ConceptsScreen> {
  VisualConcept _concept = VisualConcept.stationery;
  Brightness? _brightness;

  @override
  Widget build(BuildContext context) {
    final brightness = _brightness ?? Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    return Screen(
      title: 'Visual concepts',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                for (final concept in VisualConcept.values)
                  _Pick(
                    label: concept.name,
                    selected: concept == _concept,
                    onTap: () => setState(() => _concept = concept),
                  ),
                const SizedBox(width: Spacing.md),
                for (final b in Brightness.values)
                  _Pick(
                    label: b.name,
                    selected: b == brightness,
                    onTap: () => setState(() => _brightness = b),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          Expanded(
            child: switch (_concept) {
              VisualConcept.stationery => StationeryReview(dark: dark),
              VisualConcept.paper => PaperReview(dark: dark),
              VisualConcept.chunky => ChunkyReview(dark: dark),
              VisualConcept.mascot => MascotReview(dark: dark),
            },
          ),
        ],
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.accent.soft : colors.surfaceSunken,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: context.type.label.copyWith(
              color: selected ? colors.accent.onSoft : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
