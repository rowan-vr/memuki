import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/accent_picker.dart';
import '../components/animations.dart';
import '../components/buttons.dart';
import '../components/card_frame.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_layout.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'appearance_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appearance = ref.watch(appearanceProvider);
    final change = ref.read(appearanceProvider.notifier).change;
    // On phones the mode choices show only their names, so they fit on one
    // line.
    final icons = WindowSize.of(context) != WindowSize.compact;
    return Screen(
      title: l10n.navSettings,
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Entrance(
                    child: SectionHeader(title: l10n.settingsAppearance),
                  ),
                  Entrance(
                    index: 1,
                    child: Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Preview(),
                          _Setting(
                            label: l10n.settingsMode,
                            child: SegmentedChoice(
                              choices: [
                                Choice(
                                  ModeChoice.system,
                                  l10n.settingsModeSystem,
                                  icon: icons ? MemukiIcons.systemTheme : null,
                                ),
                                Choice(
                                  ModeChoice.light,
                                  l10n.settingsModeLight,
                                  icon: icons ? MemukiIcons.lightTheme : null,
                                ),
                                Choice(
                                  ModeChoice.dark,
                                  l10n.settingsModeDark,
                                  icon: icons ? MemukiIcons.darkTheme : null,
                                ),
                                Choice(
                                  ModeChoice.sepia,
                                  l10n.settingsModeSepia,
                                  icon: icons ? MemukiIcons.sepiaTheme : null,
                                ),
                              ],
                              selected: appearance.mode,
                              onSelected: (v) =>
                                  change((s) => s.copyWith(mode: v)),
                            ),
                          ),
                          _Setting(
                            label: l10n.settingsAccent,
                            child: AccentPicker(
                              selected: appearance.accent,
                              labelOf: (accent) => _accentName(l10n, accent),
                              onSelected: (v) =>
                                  change((s) => s.copyWith(accent: v)),
                            ),
                          ),
                          _Setting(
                            label: l10n.settingsCardStyle,
                            child: SegmentedChoice(
                              choices: [
                                Choice(
                                  CardStyle.standard,
                                  l10n.cardStyleStandard,
                                ),
                                Choice(
                                  CardStyle.notecard,
                                  l10n.cardStyleNotecard,
                                ),
                                Choice(
                                  CardStyle.minimal,
                                  l10n.cardStyleMinimal,
                                ),
                              ],
                              selected: appearance.cardStyle,
                              onSelected: (v) =>
                                  change((s) => s.copyWith(cardStyle: v)),
                            ),
                          ),
                          _Setting(
                            label: l10n.settingsDensity,
                            child: SegmentedChoice(
                              choices: [
                                Choice(
                                  Density.comfortable,
                                  l10n.densityComfortable,
                                ),
                                Choice(Density.compact, l10n.densityCompact),
                              ],
                              selected: appearance.density,
                              onSelected: (v) =>
                                  change((s) => s.copyWith(density: v)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _accentName(AppLocalizations l10n, MemukiAccent accent) =>
    switch (accent) {
      MemukiAccent.coral => l10n.accentCoral,
      MemukiAccent.orange => l10n.accentOrange,
      MemukiAccent.mustard => l10n.accentMustard,
      MemukiAccent.green => l10n.accentGreen,
      MemukiAccent.blue => l10n.accentBlue,
      MemukiAccent.purple => l10n.accentPurple,
      MemukiAccent.grey => l10n.accentGrey,
    };

/// A labelled setting in the appearance panel.
class _Setting extends StatelessWidget {
  const _Setting({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.layout.dense(Spacing.md + 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.type.bodyStrong),
          const SizedBox(height: Spacing.sm),
          child,
        ],
      ),
    );
  }
}

/// A sample card and grade buttons in the current appearance, so changes
/// show as they are made.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = context.type;
    final grades = [
      (l10n.gradeAgain, l10n.durationMinutes(1), colors.again),
      (l10n.gradeHard, l10n.durationMinutes(6), colors.hard),
      (l10n.gradeGood, l10n.durationDays(1), colors.good),
      (l10n.gradeEasy, l10n.durationDays(4), colors.easy),
    ];
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardFrame(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.lg,
                  // Clear of the notecard's ruled header.
                  Spacing.xxl + Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                ),
                child: Column(
                  children: [
                    Text(
                      '猫',
                      style: type.body.copyWith(fontSize: 40, height: 1.2),
                    ),
                    Text(
                      'ねこ',
                      style: type.body.copyWith(color: colors.textMuted),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(l10n.settingsPreviewMeaning, style: type.heading),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                for (final (i, (label, interval, tone)) in grades.indexed) ...[
                  if (i > 0) const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: GradeButton(
                      label: label,
                      interval: interval,
                      tone: tone,
                      onPressed: () {},
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
