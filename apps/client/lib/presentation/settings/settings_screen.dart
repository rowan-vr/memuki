import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/spacing.dart';
import 'theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        children: [
          ListTile(
            title: Text(l10n.settingsThemeMode),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(l10n.settingsThemeModeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(l10n.settingsThemeModeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(l10n.settingsThemeModeDark),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) => ref
                    .read(themeModeProvider.notifier)
                    .select(selection.single),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
