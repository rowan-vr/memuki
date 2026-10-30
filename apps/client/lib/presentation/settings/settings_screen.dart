import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../components/panel.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import 'theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    return Screen(
      title: l10n.navSettings,
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsThemeMode, style: context.type.bodyStrong),
                const SizedBox(height: Spacing.sm),
                SegmentedChoice(
                  choices: [
                    Choice(
                      ThemeMode.system,
                      l10n.settingsThemeModeSystem,
                      icon: MemukiIcons.systemTheme,
                    ),
                    Choice(
                      ThemeMode.light,
                      l10n.settingsThemeModeLight,
                      icon: MemukiIcons.lightTheme,
                    ),
                    Choice(
                      ThemeMode.dark,
                      l10n.settingsThemeModeDark,
                      icon: MemukiIcons.darkTheme,
                    ),
                  ],
                  selected: themeMode,
                  onSelected: ref.read(themeModeProvider.notifier).select,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
