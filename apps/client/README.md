# Memuki client

The Flutter application for all Memuki platforms. Linux is the current development target.

See the [repository README](../../README.md) for setup and the [docs](../../docs/) for architecture and roadmap.

## Commands

Run from this directory:

```sh
fvm flutter pub get                    # Install dependencies; regenerates localizations
fvm flutter run -d linux               # Run on Linux
fvm flutter test                       # Run tests
fvm flutter analyze                    # Static analysis
fvm dart format .                      # Format code
fvm dart run build_runner build        # Regenerate routes (*.g.dart)
fvm dart run build_runner watch        # Regenerate routes on change
fvm flutter build linux                # Release build in build/linux/x64/release/bundle/
```

CI runs formatting, code generation, analysis, tests, and a Linux build. Before pushing, run:

```sh
fvm dart format . && fvm dart run build_runner build && fvm flutter analyze && fvm flutter test
```

## Layout

```text
lib/
├── main.dart              Entry point: logging, error handlers, ProviderScope
├── app.dart               MaterialApp: theme, localization, router
├── core/                  Logging and error handling
├── l10n/                  ARB string files; generated/ is gen-l10n output
└── presentation/
    ├── routing/           Typed routes (router.dart → router.g.dart)
    ├── shell/             Adaptive navigation frame
    ├── theme/             Theme, spacing, breakpoints
    └── <feature>/         Screens and their providers
test/                      Mirrors lib/; helpers/ holds shared test utilities
assets/fonts/              Bundled fonts with their licences
```

Domain, scheduler, storage, and service modules are added under `lib/` as their phases begin. See [module boundaries](../../docs/ARCHITECTURE.md#module-boundaries).

## Conventions

### Routes

Routes are defined in `lib/presentation/routing/router.dart` as `GoRouteData` classes and registered in a `@TypedGoRoute` annotation. After adding or changing a route, run `build_runner build`. Navigate with the generated methods rather than string paths:

```dart
const DecksRoute().go(context);
```

### State and dependencies

Expose state and services as Riverpod providers next to the feature that owns them. Widgets read them with `ConsumerWidget` and `ref.watch`. In tests, replace dependencies with `ProviderScope(overrides: [...])`.

### Strings

Every user-facing string goes in `lib/l10n/app_en.arb` with a `@key` description. Access strings with `AppLocalizations.of(context)`. `flutter pub get` and `flutter run` regenerate `lib/l10n/generated/`.

### Logging

Create a named logger per area and log through it instead of `print`:

```dart
final _log = Logger('memuki.storage');

_log.info('Opened collection');
_log.severe('Migration failed', error, stackTrace);
```

Logs never contain study content: no note fields, card text, media, or dictionary lookups. Refer to entities by ID instead.

### Layout and spacing

Use `Spacing` constants for padding and gaps, and `WindowSize.of(context)` for layout decisions based on window width.
