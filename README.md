# Memuki

Memuki is a free, open-source, offline-first, cross-platform spaced-repetition and knowledge-mining application, starting with dictionary-based vocabulary mining for language learners.

> **Status:** early development (Phase 0 — project setup). Not yet usable for studying.

## Documentation

- [Vision](docs/VISION.md): principles and non-goals
- [Requirements](docs/REQUIREMENTS.md): what Memuki must do
- [Architecture](docs/ARCHITECTURE.md): design and decision log
- [Roadmap](docs/ROADMAP.md): milestones, phases, and per-phase decisions

## Repository layout

```text
apps/client/   Flutter application
docs/          Project documentation
.github/       CI workflows
```

Further components (sync server, dictionary package builders) are added as their phases begin. See [Architecture](docs/ARCHITECTURE.md#repository-structure).

## Development

### Requirements

- [FVM](https://fvm.app/); the Flutter version is pinned in [`.fvmrc`](.fvmrc)
- Linux desktop build dependencies: `clang`, `cmake`, `ninja`, `pkg-config`, GTK 3 development headers

### Setup

```sh
fvm install
cd apps/client
fvm flutter pub get
fvm flutter run -d linux
```

See [apps/client/README.md](apps/client/README.md) for test, analysis, and formatting commands.

## Contributing

Contributions require agreeing to the [Contributor License Agreement](CLA.md).

### Commit messages

Commits follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
<type>(<scope>): <summary>

[optional body]

[optional footer]
```

- **Summary:** imperative mood, lowercase, no trailing period, at most 72 characters.
- **Scope:** optional; the part of the codebase affected.
- **Breaking changes:** add `!` after the type or scope and explain in a `BREAKING CHANGE:` footer.

Types:

| Type | Use for |
|---|---|
| `feat` | New functionality |
| `fix` | Bug fixes |
| `docs` | Documentation only |
| `refactor` | Code changes that neither fix a bug nor add functionality |
| `perf` | Performance improvements |
| `test` | Adding or changing tests |
| `style` | Formatting only; no behavior change |
| `build` | Build system, dependencies, platform runners |
| `ci` | CI configuration |
| `chore` | Maintenance that fits no other type |
| `revert` | Reverting an earlier commit |

Scopes:

| Scope | Area |
|---|---|
| `client` | Flutter application in general |
| `ui` | Presentation layer and design system |
| `domain` | Domain models |
| `scheduler` | Scheduling algorithms and queues |
| `storage` | Database, migrations, media store |
| `templates` | Note types, fields, card templates, rendering |
| `study` | Review sessions |
| `mining` | Mining pipeline and profiles |
| `dict` | Dictionary providers and packages |
| `import` | Anki import, export, backup |
| `sync` | Client-side sync |
| `server` | Sync server |
| `l10n` | Localization |
| `deps` | Dependency updates |

New scopes are added here when a new area appears.

Examples:

```text
feat(scheduler): add burned card state
fix(storage): roll back partial note insert on failure
docs: add per-phase decision tables to roadmap
ci: cache pub dependencies
build(deps): bump drift to 2.x
feat(sync)!: switch change batches to protobuf

BREAKING CHANGE: sync protocol v2 is incompatible with v1 clients.
```

## Licence

Memuki's code is licensed under the [GNU Affero General Public License v3.0](LICENSE).

Dictionary data is not covered by this licence; each dictionary package carries its own upstream licence and attribution. Use of the "Memuki" name will be covered by a separate trademark policy.
