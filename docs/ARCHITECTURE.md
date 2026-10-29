# Memuki — Architecture

This document describes Memuki's intended architecture. Items marked **Proposed** are the current direction but not final; items under [Open questions](#open-questions) are undecided.

## Overview

- One Flutter client (`apps/client/`) for all platforms.
- Local-first: the local database is the source of truth for the device. The sync server is optional.
- Domain and scheduling logic are plain Dart, independent of Flutter and of storage.
- Platform-specific integrations sit behind interfaces.

## Module boundaries

Code starts inside `apps/client/lib/` and is extracted into `packages/` only when a boundary has proven stable.

| Module | Responsibility | Depends on |
|---|---|---|
| domain | Entities, value types, invariants | — |
| scheduler | Scheduling algorithms and queue logic | domain |
| storage | Database, migrations, repositories, media store | domain |
| services | Use cases: study, mining, import, sync | domain, scheduler, storage |
| presentation | Widgets, routing, design system | services |

## Client application

- **Routing:** go_router. Routes are classes annotated with `@TypedGoRoute` and compiled by go_router_builder into `$appRoutes`, so paths and parameters are type-checked. Top-level destinations are branches of a `StatefulShellRoute`; each branch keeps its own navigation stack.
- **State and dependencies:** Riverpod. Services, repositories, and UI state are exposed as providers, and tests replace them with `ProviderScope` overrides. There is no separate service locator.
- **Layout:** Material 3 window size classes: compact (< 600 px) uses a bottom navigation bar, medium (600–839 px) a navigation rail, and expanded (≥ 840 px) an extended rail.
- **Theme:** light and dark themes generated from one seed color. Spacing follows a 4 px scale.
- **Typography:** Noto Sans JP is bundled and used for all text. It covers Latin, kana, and kanji with Japanese glyph forms, so rendering does not depend on installed system fonts. It is a variable font; text theme weights set its `wght` axis.
- **Logging:** the `logging` package with named loggers (`memuki.<area>`). Records go to `dart:developer` and the console. Uncaught framework and asynchronous errors are logged at the top level.
- **Generated code:** route and localization code is generated and committed. CI regenerates it and fails if the result differs.

## Data model

```text
Collection
├── Deck
│   ├── Deck (nested)
│   └── Card ──► SchedulingState (materialized)
│        └──► ReviewEvent (append-only)
├── NoteType
│   └── CardTemplate
├── Note ──► NoteType
│   └── generates Cards via CardTemplates
├── Tag
└── MediaAsset
```

- A user can have several collections. Each collection contains decks.
- Decks can be nested. Each deck has an optional parent deck in the same collection.
- Note types belong to one collection. Using a note type in another collection copies it.
- A note belongs to one collection; its cards belong to decks in that collection.
- A card is identified by `(note ID, card template ID)`. Template IDs are stable, so reordering or renaming templates does not change card identity.
- Fields carry metadata (role, type, validation) so specialized field types can be added without schema redesign.
- Source attribution (dictionary entry, import origin) is stored on notes.

## Identity and change tracking

Decided in Phase 1. See [ROADMAP.md](ROADMAP.md#phase-1--domain-models-and-persistence).

- **IDs:** client-generated UUIDv7.
- **Ordering:** hybrid logical clock (HLC) timestamps on every change, rather than wall-clock time.
- **Deletion:** tombstones; rows are not hard-deleted while sync may still reference them.
- **Merge granularity:** per-field last-writer-wins on notes, per-entity on other entities.
- **Outbox:** every local mutation is recorded as a change entry for later sync.

## Review history and scheduling

- Review events are immutable and append-only.
- Scheduling state is a materialized cache that can be rebuilt by replaying a card's review events through the scheduler.
- Undo appends a compensating event; it does not delete the original event.
- Each event records the scheduler ID, scheduler version, and configuration version used, so replay is deterministic.
- Replay uses the configuration recorded on each event. Applying new configuration to existing cards is an explicit reschedule operation, never a side effect of replay.

With this model, merging concurrent reviews from different devices reduces to merging event logs and replaying.

## Scheduling

- Schedulers implement a versioned interface in the `scheduler` module. More than one scheduler can exist; configuration presets select which one a deck uses.
- **Default:** deterministic learning steps for new cards and relearning steps after lapses, with an SM-2-style ease multiplier for review intervals of graduated cards. Default steps: learning 1m → 4h → 12h → 1d → 2d; relearning 10m → 1h → 12h → 2d.
- **Burning:** independent of the review algorithm. When a grade produces a next interval at or above the preset's burn threshold, the card enters the Burned state with no due date and is excluded from normal queues. Burned cards have a separate review session; failing one returns it to relearning. Manual burn and unburn are recorded as events so replay and sync reproduce the state.
- **FSRS:** added in a later phase as an alternative review-phase algorithm; learning and relearning steps remain. Review events store grade, timestamps, due times, and response time from the start, so FSRS memory state can be computed from existing history when it is introduced.

## Card rendering

**Decided:** cards are rendered natively by Flutter from Memuki's own template model.

- Templates describe structure: which fields appear, in what order and position, with which semantic role (e.g. prompt, answer, reading, example, media).
- Styling comes from the design system and adapts to theme, platform, and text scale.
- Field content supports a restricted rich-text subset (emphasis, furigana/ruby, lists, media references). Arbitrary HTML, CSS, and JavaScript are not supported.
- Cloze and typed-answer behavior are template features, not markup conventions.
- Anki import converts templates to this model and reports what could not be carried over.

## Storage

- **Library:** Drift on all platforms, for typed queries and migrations. The schema and queries are shared between native and web.
- **Native:** SQLite.
- **Web:** SQLite compiled to WASM, stored in the Origin Private File System (OPFS). Chromium-based browsers only provide OPFS to Drift when the page is cross-origin isolated, so the web app is served with COOP/COEP headers. Without OPFS, Drift falls back to IndexedDB, which keeps the whole database in memory; the app warns when it runs on the fallback.
- **Persistence:** the web app requests persistent storage so the browser does not evict data under storage pressure.
- **SQLite version:** native and WASM builds use the same SQLite version.
- Measurements and limits are in the [browser storage spike](spikes/browser-storage.md).
- **Media:** stored outside the main database, content-addressed by hash, so identical media is stored once and sync can verify integrity.
- **Dictionaries:** each installed package is stored and indexed separately from the user's collections, and can be removed without touching study data. **Proposed:** packages ship as prebuilt SQLite databases, so installing one is a file copy rather than a row-by-row import.

## Dictionaries and mining

- `KnowledgeProvider` interface returns normalized entries: headwords, readings, definitions, forms, grammar, examples, frequency, and source/licence metadata.
- Multiple providers can answer one lookup; results keep provider attribution and priority.
- Language-specific processing (e.g. Japanese deinflection) lives in providers or language modules, not in the SRS core.
- Mining pipeline: input → lookup → enrichment → field mapping → duplicate check → preview → note creation. Later capture sources (OCR, documents, subtitles) feed the same pipeline.

## Synchronization

**Decided:** the server relays changes; clients merge.

- The server stores and serves change batches without interpreting their contents. All merge and conflict logic runs in the client, deterministically, using the identity and review-log model above.
- Collections are the unit of sync and sharing. Access control is per collection.
- Clients push and pull change batches incrementally using per-collection cursors.
- Operations are idempotent; retries never create duplicates.
- Clients periodically upload compacted collection snapshots so new devices can bootstrap without replaying full history.
- Media is transferred separately and resumably.
- Dictionary content is not synced; package references and preferences are.
- Because the server does not need to read content, end-to-end encryption and self-hosting are possible.
- Institutional features (Milestone H) are built as separate tools that act as clients, writing into shared collections. The server stays content-agnostic.
- Server: PostgreSQL. Implementation language (Go or Dart) is open.

## Localization

- Strings are externalized with Flutter's `gen-l10n` from Phase 0.
- No user-facing string literals in widgets.
- Locale-aware formatting for dates, numbers, and plurals.

## Extensibility

Three tiers, introduced in Milestone G:

1. **Data packages:** dictionaries, datasets, template sets, language packs.
2. **Declarative extensions:** mining profiles, field mappings, processing rules.
3. **Executable plugins:** sandboxed (WASM or equivalent), permission-scoped. Availability depends on platform rules, notably iOS.

Internal interfaces (providers, capture sources, mining processors) are designed with these tiers in mind but are not public until Milestone G.

## Licensing

- **Code:** AGPL-3.0 for the client, sync server, and all other code in this repository.
- **Contributions:** contributors sign a contributor licence agreement (CLA). This keeps the ability to dual-license commercially and to distribute through app stores whose terms conflict with the AGPL.
- **Dictionary data:** not covered by the code licence. Each dictionary package keeps its upstream licence (e.g. CC BY-SA for JMdict, KANJIDIC2, Jitendex, KanjiVG, Kaikki/Wiktionary) and ships its own licence and attribution metadata. Source-specific conditions, such as the EDRDG licence terms, are reviewed before a package is redistributed.
- **Bundled fonts:** keep their upstream licences. Noto Sans JP is under the SIL Open Font License 1.1 (`apps/client/assets/fonts/NotoSansJP/OFL.txt`).
- **No reused Anki or Yomitan code.** Anki import is implemented from the file format; Japanese deinflection is implemented in Memuki.
- **Name:** "Memuki" is governed by the [trademark policy](TRADEMARK.md), independent of the code licence. The name is not registered yet.

## Repository structure

Intended layout; directories are created only when needed.

```text
memuki/
├── apps/
│   ├── client/              # Flutter application
│   ├── browser-extension/   # Milestone G
│   └── teacher-dashboard/   # Milestone H
├── packages/                # Extracted Dart packages (domain, scheduler, mining, design_system)
├── services/
│   └── sync-server/         # Milestone C
├── contracts/
│   └── sync/                # Sync protocol definitions
├── dictionaries/            # Dictionary package builders; built packages carry upstream data licences
├── infrastructure/
├── docs/
└── .github/workflows/
```

## Decision log

| # | Decision | Status | Phase |
|---|---|---|---|
| D1 | Single Flutter client for all platforms | Decided | 0 |
| D2 | Native card rendering from Memuki templates; no user HTML/CSS/JS | Decided | 3 |
| D3 | Multiple collections per user, each containing decks | Decided | 1 |
| D4 | Anki is a one-time migration source, not an ongoing exchange target | Decided | 6 |
| D5 | UI localization infrastructure from Phase 0 | Decided | 0 |
| D6 | Client-generated UUIDv7 IDs, HLC timestamps, tombstones | Decided | 1 |
| D7 | Append-only review log with rebuildable scheduling state | Decided | 1–2 |
| D8 | Content-addressed media storage | Decided | 1 |
| D9 | SQLite via Drift on native and web | Decided | 1 |
| D10 | Sync server relays change batches; clients perform all merging | Decided | 7 |
| D11 | Collections are the unit of sync, sharing, and access control | Decided | 7 |
| D12 | AGPL-3.0 for all code, with a contributor licence agreement | Decided | 0 |
| D13 | Dictionary data licensed separately under upstream licences | Decided | 0 |
| D14 | Trademark policy for the Memuki name | Decided | 0 |
| D15 | Default scheduler: deterministic learning/relearning steps; SM-2-style review intervals | Decided | 2 |
| D16 | Pluggable, versioned scheduler interface; scheduler recorded on every review event | Decided | 2 |
| D17 | FSRS deferred to a later phase | Decided | — |
| D18 | Burned card state with configurable interval threshold, independent of review algorithm | Decided | 2 |
| D19 | Routing with go_router; typed routes generated by go_router_builder | Decided | 0 |
| D20 | Riverpod for state management and dependency injection | Decided | 0 |
| D21 | Bundled Noto Sans JP (variable font) as the app typeface | Decided | 0 |
| D22 | Generated code (routes, localizations) is committed; CI fails if it is stale | Decided | 0 |
| D23 | Note types belong to one collection; reuse across collections by copying | Decided | 1 |
| D24 | Nested decks via an optional parent deck in the same collection | Decided | 1 |
| D25 | Web app served with COOP/COEP headers so browser storage uses OPFS | Decided | 12 |

## Open questions

- **Sync server language.** Go or Dart. The server holds no domain logic, so little code would be shared with the client.
- **End-to-end encryption.** Enabled by D10; whether it is default, optional, or deferred is undecided.
- **Plugin licensing.** Whether plugins built against the Milestone G SDK must be AGPL-3.0, or whether the SDK carries a licence exception or permissive licence.
- **FSRS.** Roadmap placement, implementation (e.g. `dart-fsrs` or a custom port), and where parameter optimization runs, including on web.