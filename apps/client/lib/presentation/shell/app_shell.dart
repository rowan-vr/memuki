import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../components/icons.dart';
import '../components/navigation.dart';
import '../developer/developer_tools_provider.dart';
import '../theme/breakpoints.dart';

/// The app frame around the top-level destinations.
///
/// Uses a [NavBar] along the bottom of compact windows, a [NavRail] on
/// medium windows, and an extended rail with the app's name on expanded
/// windows.
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
      NavDestination(icon: MemukiIcons.home, label: l10n.navHome),
      NavDestination(icon: MemukiIcons.decks, label: l10n.navDecks),
      NavDestination(icon: MemukiIcons.settings, label: l10n.navSettings),
      if (ref.watch(developerToolsProvider))
        const NavDestination(icon: MemukiIcons.developer, label: 'Developer'),
    ];
    final selected = navigationShell.currentIndex;

    final windowSize = WindowSize.of(context);
    if (windowSize == WindowSize.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavBar(
          destinations: destinations,
          selectedIndex: selected,
          onSelected: _goBranch,
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavRail(
            destinations: destinations,
            selectedIndex: selected,
            onSelected: _goBranch,
            extended: windowSize == WindowSize.expanded,
            title: l10n.appTitle,
          ),
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
