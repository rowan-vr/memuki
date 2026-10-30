import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../catalogue/catalogue_screen.dart';
import '../catalogue/concepts/concepts_screen.dart';
import '../decks/decks_screen.dart';
import '../developer/developer_screen.dart';
import '../developer/developer_tools_provider.dart';
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
    TypedStatefulShellBranch<DeveloperBranchData>(
      routes: [
        TypedGoRoute<DeveloperRoute>(
          path: '/developer',
          routes: [
            TypedGoRoute<CatalogueRoute>(path: 'catalogue'),
            TypedGoRoute<ConceptsRoute>(path: 'concepts'),
          ],
        ),
      ],
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

/// Development tools. Last, so [AppShell] can leave its destination out when
/// they are not available.
class DeveloperBranchData extends StatefulShellBranchData {
  const DeveloperBranchData();
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

/// Development tools; redirects home when they are not available.
class DeveloperRoute extends GoRouteData with $DeveloperRoute {
  const DeveloperRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) =>
      ProviderScope.containerOf(context).read(developerToolsProvider)
      ? null
      : const HomeRoute().location;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DeveloperScreen();
}

/// The component catalogue, a development tool.
class CatalogueRoute extends GoRouteData with $CatalogueRoute {
  const CatalogueRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CatalogueScreen();
}

/// Visual concepts compared on a mock review screen, a development tool.
class ConceptsRoute extends GoRouteData with $ConceptsRoute {
  const ConceptsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConceptsScreen();
}
