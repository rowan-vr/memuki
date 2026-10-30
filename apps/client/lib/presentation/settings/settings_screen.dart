import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/animations.dart';
import '../components/icons.dart';
import '../components/rows.dart';
import '../components/screen.dart';
import '../routing/router.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import 'appearance_settings.dart';

/// The settings, grouped into pages.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = switch (ref.watch(appearanceProvider).mode) {
      ModeChoice.system => l10n.settingsModeSystem,
      ModeChoice.light => l10n.settingsModeLight,
      ModeChoice.dark => l10n.settingsModeDark,
      ModeChoice.sepia => l10n.settingsModeSepia,
    };
    return Screen(
      title: l10n.navSettings,
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Entrance(
                child: RowGroup(
                  children: [
                    ListRow(
                      leading: Icon(
                        MemukiIcons.appearance,
                        color: context.colors.textMuted,
                      ),
                      title: l10n.settingsAppearance,
                      subtitle: mode,
                      onTap: () => const AppearanceRoute().go(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
