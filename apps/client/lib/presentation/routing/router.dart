import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../decks/decks_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../shell/app_shell.dart';

part 'router.g.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(routes: $appRoutes);
  ref.onDispose(router.dispose);
  return router;
});

/// Top-level destinations. Each branch keeps its own navigation stack, so
/// switching destinations preserves where the user was in each one.
///
/// The branch order defines the order of the navigation destinations in
/// [AppShell].
@TypedStatefulShellRoute<ShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(
      routes: [TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<DecksBranchData>(
      routes: [TypedGoRoute<DecksRoute>(path: '/decks')],
    ),
    TypedStatefulShellBranch<SettingsBranchData>(
      routes: [TypedGoRoute<SettingsRoute>(path: '/settings')],
    ),
  ],
)
class ShellRouteData extends StatefulShellRouteData {
  const ShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}

class DecksBranchData extends StatefulShellBranchData {
  const DecksBranchData();
}

class SettingsBranchData extends StatefulShellBranchData {
  const SettingsBranchData();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class DecksRoute extends GoRouteData with $DecksRoute {
  const DecksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DecksScreen();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
}
