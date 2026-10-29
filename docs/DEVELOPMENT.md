# Memuki — Development Guide

How to set up, run, test, and build Memuki. For contribution rules (CLA, pull requests, commit messages), see [CONTRIBUTING.md](../CONTRIBUTING.md).

All `flutter` and `dart` commands go through [FVM](https://fvm.app/) so everyone uses the Flutter version pinned in [`.fvmrc`](../.fvmrc). Unless stated otherwise, commands run from `apps/client/`.

## Prerequisites

### System packages

Linux is the current development target. Install Git, the tools FVM and Flutter need, and the Linux desktop build dependencies:

Arch Linux:

```sh
sudo pacman -S --needed git curl unzip xz zip clang cmake ninja pkgconf gtk3
```

Debian / Ubuntu:

```sh
sudo apt-get install git curl unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev
```

Fedora:

```sh
sudo dnf install git curl unzip xz zip clang cmake ninja-build pkgconf-pkg-config gtk3-devel
```

### FVM

Install FVM by following the [FVM installation guide](https://fvm.app/documentation/getting-started/installation), for example:

```sh
curl -fsSL https://fvm.app/install.sh | bash
```

A separate Flutter installation is not required; FVM downloads the pinned version.

## First run

```sh
git clone git@github.com:rowan-vr/memuki.git
cd memuki
fvm install                # Downloads the Flutter version from .fvmrc
cd apps/client
fvm flutter doctor         # Checks the toolchain; the Linux toolchain must be ✓
fvm flutter pub get        # Installs dependencies and generates localizations
fvm flutter run -d linux
```

A window titled "Memuki" opens with Home, Decks, and Settings in a navigation rail. Narrowing the window switches to a bottom navigation bar.

## Daily workflow

### Running

```sh
fvm flutter run -d linux
```

While it runs, press `r` to hot reload (keeps app state), `R` to hot restart (resets state), and `q` to quit.

### Before pushing

CI runs the same checks. Run them locally first:

```sh
fvm dart format . && fvm dart run build_runner build && fvm flutter analyze && fvm flutter test
```

Commit any files these commands change.

### Command reference

| Command | Purpose |
|---|---|
| `fvm flutter pub get` | Install dependencies; regenerate localizations |
| `fvm flutter run -d linux` | Run the app in debug mode |
| `fvm flutter test` | Run all tests |
| `fvm flutter analyze` | Static analysis and lints |
| `fvm dart format .` | Format all Dart code |
| `fvm dart run build_runner build` | Regenerate code (routes) |
| `fvm dart run build_runner watch` | Regenerate code on every change |
| `fvm flutter build linux` | Release build in `build/linux/x64/release/bundle/` |
| `fvm flutter pub outdated` | List dependency updates |

## Testing

### Running tests

```sh
fvm flutter test                                          # All tests
fvm flutter test test/presentation/app_shell_test.dart    # One file
fvm flutter test --plain-name 'compact window'            # Tests whose name contains the text
fvm flutter test --coverage                               # Writes coverage/lcov.info
```

To view coverage as HTML, install `lcov` (e.g. `sudo pacman -S lcov`) and run:

```sh
genhtml coverage/lcov.info -o coverage/html
xdg-open coverage/html/index.html
```

`coverage/` is ignored by Git.

### Writing tests

- Tests live in `test/` and mirror the `lib/` structure: tests for `lib/core/logging.dart` go in `test/core/logging_test.dart`.
- Plain Dart logic gets unit tests (`test()`). Widgets get widget tests (`testWidgets()`).
- `test/helpers/pump_app.dart` provides `tester.pumpApp(size: ...)`, which pumps the full app in a window of the given size.
- Replace dependencies with Riverpod overrides instead of global fakes:

  ```dart
  await tester.pumpWidget(
    ProviderScope(
      overrides: [someRepositoryProvider.overrideWithValue(FakeRepository())],
      child: const MemukiApp(),
    ),
  );
  ```

- Find widgets by type or by their English text; tests run with the English locale.

### Database tests

- `test/helpers/test_database.dart`: `openTestDatabase()` gives an in-memory database, and `Repositories(db).seedCollection()` a small collection for focused tests.
- `test/helpers/fixtures.dart`: `CollectionFixture.generate(seed: ...)` builds a whole collection (deck and tag trees, notes, cards, review history, scheduling state, media) from a seed. The same seed always gives the same entities. With `openFixtureDatabase()`, which fixes the clock and HLC node, it also gives the same rows and timestamps, so a failure can be rerun from its seed. `dumpTables(db)` returns every row of every table for before/after comparisons.
- `test/storage/rollback_test.dart` makes every repository write fail at its last step and checks that the database is unchanged. **A new write method must be added to its `_writes` list**, or it is not checked.
- `test/storage/persistence_test.dart` writes a generated collection to a database file and media folder, reopens both, and checks that everything reads back the same.

## Code generation

Some Dart code is generated from other files:

| Source | Generated | Regenerated by |
|---|---|---|
| Route classes in `lib/presentation/routing/router.dart` | `router.g.dart` | `fvm dart run build_runner build` |
| Strings in `lib/l10n/app_en.arb` | `lib/l10n/generated/` | `fvm flutter pub get`, `fvm flutter run`, `fvm flutter build` |
| Database tables in `lib/storage/` | `database.g.dart` | `fvm dart run build_runner build` |
| Database schema versions | `drift_schemas/`, `test/storage/generated_migrations/` | `fvm dart run drift_dev make-migrations` |

Generated files are committed, so a fresh checkout builds without running generators first. CI regenerates them and fails if the result differs from what is committed. When that check fails, run `fvm dart run build_runner build` and `fvm flutter pub get`, then commit the changes.

Do not edit generated files by hand.

### Changing the database schema

Every schema version is kept as a snapshot in `drift_schemas/`, and a test fails when the tables no longer match the snapshot of the current version. To change the schema:

1. Edit the tables in `lib/storage/` and increase `schemaVersion` in `lib/storage/database.dart`.
2. Run `fvm dart run drift_dev make-migrations`. It writes a snapshot of the new version, a typed steps file, and a migration test in `test/storage/generated_migrations/`.
3. Implement the step in `MemukiDatabase.upgradeSchema`.
4. Fill in the test data in the generated migration test and run the tests.

Upgrades run in a single transaction and are rejected if they leave foreign key violations. Native builds write a copy of the database (`memuki-v<old version>-<timestamp>.sqlite`) next to it before upgrading.

## Continuous integration

[`.github/workflows/client.yml`](../.github/workflows/client.yml) runs on every push to `main` and every pull request. Its jobs run only when `apps/client/`, `.fvmrc`, or the workflow itself changed; otherwise they are skipped.

| Job | Checks | Reproduce locally |
|---|---|---|
| Format, analyze, test | Formatting | `fvm dart format --output=none --set-exit-if-changed .` |
| | Generated code is up to date | `fvm dart run build_runner build`, then `git status` |
| | Analysis | `fvm flutter analyze` |
| | Tests | `fvm flutter test` |
| Linux build | Release build | `fvm flutter build linux --release` |

The Linux build runs only after the checks pass. CI reads the Flutter version from `.fvmrc`.

The **Client CI** job summarizes the run: it fails if any client job failed and passes if they succeeded or were skipped. Branch protection requires this one job, so pull requests that do not touch the client are not blocked waiting for skipped checks.

## IDE setup

Point the IDE at the FVM-managed SDK, `.fvm/flutter_sdk` in the repository root, rather than a system Flutter installation. Otherwise the IDE may analyze and run with a different Flutter version.

### VS Code

Install the Dart and Flutter extensions, then add to `.vscode/settings.json` in the repository root:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

Open `apps/client/` or the repository root as the workspace.

### Android Studio / IntelliJ IDEA

Install the Flutter plugin, then set **Settings → Languages & Frameworks → Flutter → Flutter SDK path** to `<repository>/.fvm/flutter_sdk`. Open `apps/client/` as the project.

## Troubleshooting

| Problem | Fix |
|---|---|
| `CMake was unable to find a build program` or `gtk+-3.0 not found` | Install the [system packages](#system-packages) for your distribution. |
| `flutter: command not found`, or the wrong Flutter version is used | Prefix commands with `fvm`, and run `fvm install` in the repository root. |
| `Target of URI hasn't been generated: 'router.g.dart'` or missing `$...Route` mixins | Run `fvm dart run build_runner build`. |
| A new string is missing from `AppLocalizations` | Run `fvm flutter pub get` to regenerate localizations. Check that the key and its `@key` description are in `app_en.arb`. |
| CI fails on generated code | See [Code generation](#code-generation). |
| Odd build errors after switching branches or upgrading Flutter | Run `fvm flutter clean && fvm flutter pub get`. |
