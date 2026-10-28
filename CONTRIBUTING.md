# Contributing to Memuki

Memuki is in early development. Contributions are welcome. The [roadmap](docs/ROADMAP.md) describes what is being built and in what order.

To set up a development environment, see the [development guide](docs/DEVELOPMENT.md).

## Contributor License Agreement

Contributions require agreeing to the [Contributor License Agreement](CLA.md). On your first pull request, a bot asks you to post the following comment:

> I have read the CLA Document and I hereby sign the CLA

Pull requests cannot be merged until the CLA is signed.

## Issues

- Work is tracked as GitHub issues, grouped into [milestones](https://github.com/rowan-vr/memuki/milestones) that match the roadmap.
- Labels give the roadmap phase (`phase: N`), the kind of work (`type: feature`, `type: bug`, `type: decision`, `type: spike`, …), and the affected area (`area: ui`, `area: domain`, …).
- `type: decision` issues are resolved by recording the outcome in the phase's decision table in [ROADMAP.md](docs/ROADMAP.md) and, if architectural, in the [ARCHITECTURE.md](docs/ARCHITECTURE.md#decision-log) decision log.
- Look for `good first issue` and `help wanted` for a place to start. For larger changes, discuss in an issue before opening a pull request.

## Pull requests

1. Create a branch from `main`.
2. Make the change, with tests for new behavior.
3. Run the [pre-push checks](docs/DEVELOPMENT.md#before-pushing).
4. Open a pull request against `main`. Reference the issue it resolves with `Closes #<number>`.

A pull request is ready to merge when CI passes, the CLA is signed, and it has been reviewed.

## Code

- Follow the conventions in [apps/client/README.md](apps/client/README.md#conventions).
- Every user-facing string goes through the localization layer.
- Logs never contain study content.
- Formatting and lints are enforced by CI.

## Commit messages

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

