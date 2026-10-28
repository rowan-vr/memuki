# Memuki

Memuki is a free, open-source, offline-first, cross-platform spaced-repetition and knowledge-mining application, starting with dictionary-based vocabulary mining for language learners.

> **Status:** early development (Phase 0 — project setup). Not yet usable for studying.

## Documentation

- [Vision](docs/VISION.md): principles and non-goals
- [Requirements](docs/REQUIREMENTS.md): what Memuki must do
- [Architecture](docs/ARCHITECTURE.md): design and decision log
- [Roadmap](docs/ROADMAP.md): milestones, phases, and per-phase decisions
- [Development](docs/DEVELOPMENT.md): setup, running, testing, and building

## Repository layout

```text
apps/client/   Flutter application
docs/          Project documentation
.github/       CI workflows
```

Further components (sync server, dictionary package builders) are added as their phases begin. See [Architecture](docs/ARCHITECTURE.md#repository-structure).

## Development

See the [development guide](docs/DEVELOPMENT.md) for setup, running, testing, and building. Quick start on Linux with [FVM](https://fvm.app/) installed:

```sh
fvm install
cd apps/client
fvm flutter pub get
fvm flutter run -d linux
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Contributions require agreeing to the [Contributor License Agreement](CLA.md).

## Licence

Memuki's code is licensed under the [GNU Affero General Public License v3.0](LICENSE).

Dictionary data is not covered by this licence; each dictionary package carries its own upstream licence and attribution. Use of the "Memuki" name is covered by the [trademark policy](docs/TRADEMARK.md).
