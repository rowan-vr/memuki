import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../developer/developer_tools_provider.dart';
import '../theme/breakpoints.dart';

/// The app frame around the top-level destinations.
///
/// Uses a bottom navigation bar on compact windows, a navigation rail on
/// medium windows, and an extended rail with labels on expanded windows.
///
/// The Developer destination is shown only when developer tools are
/// available. Its label is not localized.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (icon: MemukiIcons.home, label: l10n.navHome),
      (icon: MemukiIcons.decks, label: l10n.navDecks),
      (icon: MemukiIcons.settings, label: l10n.navSettings),
      if (ref.watch(developerToolsProvider))
        (icon: MemukiIcons.developer, label: 'Developer'),
    ];

    final windowSize = WindowSize.of(context);
    if (windowSize == WindowSize.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          destinations: [
            for (final d in destinations)
              NavigationDestination(icon: Icon(d.icon), label: d.label),
          ],
        ),
      );
    }

    final extended = windowSize == WindowSize.expanded;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            extended: extended,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final d in destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  /// Switches branch. Selecting the current destination again returns to the
  /// branch's initial location.
  void _goBranch(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
