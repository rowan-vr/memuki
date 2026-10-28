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

## Licence

Memuki's code is licensed under the [GNU Affero General Public License v3.0](LICENSE).

Dictionary data is not covered by this licence; each dictionary package carries its own upstream licence and attribution. Use of the "Memuki" name will be covered by a separate trademark policy.
