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
- **Domain models:** immutable classes generated with `freezed`, in `lib/domain/`, with no dependency on storage or Flutter. Card types are prefixed `StudyCard` (`StudyCard`, `StudyCardTemplate`, `StudyCardId`, `StudyCardState`), so they do not clash with Flutter's `Card` widget. Entities validate their invariants on construction and in `copyWith`; invariants that span entities are enforced by repositories. Each entity has its own ID type (an extension type over the UUID string). Database rows are mapped to and from domain models in the storage module.
- **Generated code:** route, localization, and model code is generated and committed. CI regenerates it and fails if the result differs.

## Data model

```text
Collection
├── Deck
│   ├── Deck (nested)
│   └── StudyCard ──► SchedulingState (materialized)
│        └──► ReviewEvent (append-only)
├── NoteType
│   └── StudyCardTemplate
├── Note ──► NoteType
│   ├── generates StudyCards via StudyCardTemplates
│   └── NoteTag ──► Tag
├── Tag
│   └── Tag (nested)
└── MediaAsset
```

- A user can have several collections. Each collection contains decks.
- Decks can be nested. Each deck has an optional parent deck in the same collection.
- Note types belong to one collection. Using a note type in another collection copies it.
- A note belongs to one collection; its cards belong to decks in that collection.
- A card is identified by `(note ID, card template ID)`. Template IDs are stable, so reordering or renaming templates does not change card identity. The card's ID is derived from that pair (a UUIDv8 from SHA-256 of both IDs), so devices that create the same card independently produce the same ID.
- Tags are entities in a collection with stable IDs and an optional parent tag. Names are unique among tags with the same parent, ignoring case, and may contain spaces. A note's tags are separate note–tag rows, so renaming a tag is a single change and tags added on different devices merge. Anki tags such as `a::b::c` import as a chain of nested tags.
- Fields carry metadata (role, type, validation) so specialized field types can be added without schema redesign.
- Source attribution (dictionary entry, import origin) is stored on notes.

## Identity and change tracking

Decided in Phase 1. See [ROADMAP.md](ROADMAP.md#phase-1--domain-models-and-persistence).

- **IDs:** client-generated UUIDv7.
- **Ordering:** hybrid logical clock (HLC) timestamps on every change, rather than wall-clock time. A timestamp is wall-clock milliseconds, a counter, and the device's random node ID, stored as fixed-width hex text (`<12 ms>-<4 counter>-<16 node>`) so text order is timestamp order. The device's node ID and latest timestamp are kept in a local `device` table, so the clock never goes backwards across restarts. Received timestamps are merged into the clock and stored too. A received timestamp more than a minute ahead of the local wall clock is rejected, so a device with a wrong clock cannot win every conflict.
- **Deletion:** tombstones; rows are not hard-deleted while sync may still reference them. Every synced row has an `hlc` (its last change) and a `deleted` flag. A delete tombstones only the row it targets; the rows below it keep their flag and timestamp. Views in `views.drift` decide what is visible: a row is visible while its own flag is clear and its parents are visible, and a note that has cards is visible while one of its cards is. Reads go through these views. Undoing a delete, including through sync, brings back everything below it, and a delete does not overwrite concurrent changes to the rows below. Removing tombstones for good is part of Phase 8; purging a row must also remove the rows it hides.
- **Merge granularity:** per-field last-writer-wins on notes, per-entity on other entities. Each note field value is its own row with its own timestamp, and an update only stamps the values that changed.
- **Outbox:** every local change is recorded for later sync. The outbox holds one entry per changed entity (table, key, timestamp); later changes to the same entity overwrite its entry. Sync reads the entity's current row, which may be a tombstone, when pushing.
- **Recording:** repositories stamp each write with one new timestamp and record every row carrying it in the outbox, in the same transaction. Triggers reject an update of a synced row that does not change its `hlc`, and any update of a review event, so no change escapes the outbox.
- **Not synced:** scheduling state, which each device rebuilds from the synced review events.

## Review history and scheduling

- Review events are immutable and append-only.
- Scheduling state is a materialized cache that can be rebuilt by replaying a card's review events through the scheduler.
- Undo appends a compensating event that refers to the event it cancels; it does not delete the original event. An event is in effect unless an undo in effect refers to it, so undoing an undo is a redo. Replay applies only the reviews, burns, and unburns in effect. Undo cancels the latest of these; redo cancels the latest undo while only undos and redos follow it.
- Deleting a card tombstones the card and keeps its events, so recreating the card (same derived ID) restores its history. Whether events are removed when tombstones are purged is open (Phase 8).
- Each event records the scheduler ID, scheduler version, and preset version used, the reviewing device's UTC offset, and the card's state before the event (new, learning, review, relearning, or burned). The state before is derivable by replay but recorded, so queues and statistics can tell new, learning, and review answers apart with plain queries. Replay applies each event with the scheduler version recorded on it, so every released scheduler version stays available, and computes study days in the recorded offset rather than the replaying device's time zone. Every device therefore rebuilds the same state from the same events.
- Replay uses the preset version recorded on each event, and the collection's current study day start. An event whose scheduler version or preset version is unknown (such as old test data) is replayed with the card's current preset and the latest version of its scheduler, and reported. A card whose history cannot be replayed at all keeps its stored state and is reported. Replay has no side effects such as leech tags.
- Applying new configuration to existing cards is an explicit reschedule operation, never a side effect of replay.

With this model, merging concurrent reviews from different devices reduces to merging event logs and replaying.

## Scheduling

- Schedulers implement a versioned interface in the `scheduler` module. More than one scheduler can exist; configuration presets select which one a deck uses.
- A scheduler is a pure function from a card's state, a grade, the review time, study days, and its configuration to the card's next state. It does not read the clock, the database, or the device's time zone. The scheduling engine handles everything independent of the algorithm: burning, manual burn and unburn, undo, replay, and choosing the scheduler version for each event.
- **Default:** deterministic learning steps for new cards and relearning steps after lapses, with an SM-2-style ease multiplier for review intervals of graduated cards. Good slowly raises ease back towards the starting ease, so repeated Hard and Again grades do not keep intervals short permanently. Default steps: learning 1m → 4h → 12h → 1d → 2d; relearning 10m → 1h → 12h → 2d. Review intervals are fuzzed deterministically, seeded by the card and its review count, so cards learned together spread out and replay stays exact.
- **Burning:** independent of the review algorithm. When a grade produces a next interval at or above the preset's burn threshold, the card enters the Burned state with no due date and is excluded from normal queues. Burned cards have a separate review session; failing one returns it to relearning. Unburning returns a card to review with its interval and ease, due at the start of the current study day. Manual burn and unburn are recorded as events so replay and sync reproduce the state.
- **Leeches:** detected by the engine from the lapse count, at the preset's threshold (default 8) and every half of it after. Tagging the note is a side effect of recording a review, never of replay.
- **Recording a review:** the review service appends the event, saves the new scheduling state, and applies side effects such as the leech tag in one transaction.
- **Configuration:** decks select a shared preset; a deck without its own preset inherits its parent's, and a root deck without one uses the collection's default preset, which cannot be deleted. Decks whose preset is deleted inherit again. Presets set the scheduler and its settings, the burn threshold (default 1 year), the leech threshold (default 8), and daily limits (default 50 new cards and 500 reviews).
- **Preset versions:** a preset's settings are immutable versions with their own IDs; editing a preset adds a version and makes it current. Review events record the version ID, so concurrent edits on different devices cannot produce two different versions with the same identity, and replay always finds the settings an event used.
- **Study day:** starts at a per-collection hour (default 03:00 local time). Steps under 1d are exact durations; steps of 1d or more fall due at the start of a study day. Due times are computed in the UTC offset recorded on the review, and the queue computes today in the device's current offset. When the offset changes (travel, daylight saving), a learning card on a day step can fall due up to an hour after the day starts, and reviews recorded in the old offset can count towards a different study day for limits and sibling burying. Both settle by the next day; reviews are unaffected by the first, since every review due today is shown all day.
- **Nested decks:** studying a deck includes all decks below it. Each deck's daily limit caps the cards from it and the decks below it, and the studied deck's limit caps the combined total.
- **Study queue:** built from the cards' scheduling state when a card is needed, not stored. Due learning and relearning cards come first and are never limited; due reviews (most overdue first) and new cards follow, capped by the limits and ordered by the studied deck's preset: new cards mixed evenly among reviews, or either first, and introduced in creation order or a random order fixed for the study day. When nothing else is left, learning cards due within 20 minutes are shown early. What was studied today is counted from the events in effect in the current study day, so an undo gives a slot back: a review counts as a new card if its recorded state before is new, and against the review limit if it is review.
- **Suspending and burying:** card properties, synced like other card edits, not review events. A suspended card is left out of every queue; a buried card is left out until its `buried_until` time. A study session can skip cards for that session only, which is not stored. Sibling burying is not stored either: once a new or review card of a note has a review in effect today, the note's other new and review cards are left out of the day's queue, as the studied deck's preset sets. A review of a learning card buries them only for the session it happened in by default (the session passes its start time to the queue), or for the day, or not at all. Learning cards are never buried.
- **FSRS:** added in a later phase as an alternative review-phase algorithm; learning and relearning steps remain. Review events store grade, timestamps, due times, and response time from the start, so FSRS memory state can be computed from existing history when it is introduced.

## Card rendering

**Decided:** cards are rendered natively by Flutter from Memuki's own template model.

- Templates describe structure: which fields appear, in what order and position, with which semantic role (e.g. prompt, answer, reading, example, media).
- Styling comes from the design system and adapts to theme, platform, and text scale.
- Arbitrary HTML, CSS, and JavaScript are not supported.
- Cloze and typed-answer behavior are template features, not conventions in field text.
- Anki import converts templates and field HTML to this model and reports what could not be carried over.

### Content format

Field values and templates are stored as text in one format. Text is plain except for marks:

```
{key arg … name="value" | content}
```

The key names the kind of mark. Arguments follow, positional or named, quoted when they contain spaces. Content after `|` is optional and can contain further marks. `\` escapes `{`, `}`, `|`, and itself.

```
今日は{ruby てんき | 天気}が{em | いい}です。
{lang zh-Hans | {ruby "nǐ hǎo" | 你好}}
H{sub | 2}O
```

- **Marks are semantic.** They say what text is (a reading, emphasis, a language), never how it looks. There are no colour, size, or font marks; the design system styles each kind.
- **Kinds are a registry.** Each kind defines its arguments, how it renders, how it is added in the editor, how Anki HTML maps to it, and its plain-text fallback. New kinds (pitch accent, tone, formulas) are new entries, and language packs and plugins can add them. A kind the app does not know shows its content.
- **Plain text** is the content with the marks dropped (`今日は天気がいいです`). Search, duplicate detection, sorting, and typed-answer comparison use it.
- **Language:** each field definition has a language, and a `lang` mark overrides it for a span. The language selects glyph forms for shared Han characters, text direction, and font fallback.
- **Editing:** fields are edited directly in their rendered form; selecting text offers the marks that apply. A toggle shows the source.

### Templates

A template is content in the same format, whose marks place fields:

```
{front |
  {field Word role=prompt}
}
{back |
  {field Reading role=reading}
  {field Meaning role=answer}
  {if Example | {field Example role=example}}
}
{requires Word}
```

- Fields are placed by role; the role decides their styling. Templates carry no styling of their own.
- `if` shows its content only when the field is not empty; `requires` lists the fields a note must fill for the template to generate a card.
- Cloze and typed answer are template kinds that refer to a field.
- Templates are edited visually by arranging fields on the front and back, with the same source toggle.
- The format is stored on `StudyCardTemplate`; template IDs, and so card identity, do not depend on it.

## Storage

- **Library:** Drift on all platforms, for typed queries and migrations. The schema and queries are shared between native and web.
- **Native:** SQLite.
- **Web:** SQLite compiled to WASM, stored in the Origin Private File System (OPFS). Chromium-based browsers only provide OPFS to Drift when the page is cross-origin isolated, so the web app is served with COOP/COEP headers. Without OPFS, Drift falls back to IndexedDB, which keeps the whole database in memory; the app warns when it runs on the fallback.
- **Persistence:** the web app requests persistent storage so the browser does not evict data under storage pressure.
- **SQLite version:** native and WASM builds use the same SQLite version.
- **Schema:** IDs are stored as 16-byte blobs, times as UTC milliseconds, and enums by name. Rows that belong to a collection carry its ID, and references between them are composite foreign keys on `(collection_id, id)`, so a reference into another collection is rejected on every write path (repositories, import, sync). Deck and tag parent references are deferred to commit. `collection_id` cannot change after creation; moving to another collection is a copy.
- **Repositories:** one per aggregate (collections and decks, tags, note types, notes, cards, review history). They map rows to domain models and enforce invariants that span entities: parent changes cannot create cycles, tag names are unique among siblings ignoring case, and a note's fields and cards match its note type. Each write runs in a transaction; callers group several writes by wrapping them in one. Hierarchy walks use recursive queries with `UNION` and a depth limit of 64, so a cycle in corrupt data is logged instead of hanging the app.
- **Migrations:** the schema is versioned, with a snapshot of each version and generated migration tests. An upgrade runs in one transaction and is rejected if it leaves foreign key violations; native builds copy the database before upgrading. A database from a newer schema version is not opened.
- Measurements and limits are in the [browser storage spike](spikes/browser-storage.md).
- **Media:** stored outside the main database, content-addressed by SHA-256 hash, so sync can verify integrity. Each collection has its own folder (`media/<collection ID>/<hash>`), so identical media is stored once per collection and a collection's media can be synced, shared, or exported on its own. A file is written to a temporary file while it is hashed, flushed, and renamed into place before its `media_assets` row is written, so a row never points to a missing or partial file. Deleting media tombstones the row and keeps the file until tombstones are purged (Phase 8). The MIME type is detected from the file's first bytes and name, falling back to the type the caller gives. Storage goes through a `MediaStore` interface; native builds use the file system, and the web store is part of Milestone E.
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
| D26 | Immutable domain models generated with `freezed`; storage rows are separate and mapped | Decided | 1 |
| D27 | Tags are collection-scoped entities with optional parents; note membership is a separate synced relation | Decided | 1 |
| D28 | Cross-collection references rejected by composite foreign keys; `collection_id` is immutable | Decided | 1 |
| D29 | Parent cycles from concurrent moves are broken at merge by detaching the node whose parent change has the highest HLC | Proposed | 8 |
| D30 | Deleting a deck hides its subdecks and cards, and notes left without visible cards; deleting a tag hides its subtree and removes it from notes | Decided | 1 |
| D31 | Outbox lists changed entities, coalesced per entity; sync reads current rows (including tombstones) at push time | Decided | 1 |
| D32 | HLC timestamps stored as fixed-width hex text; stamped and recorded by repositories | Decided | 1 |
| D33 | Scheduling state is not synced; each device rebuilds it from synced review events | Decided | 1 |
| D34 | A delete tombstones only its target; rows below it are hidden by views over their parents' tombstones | Decided | 1 |
| D35 | Media files in a folder per collection, named by hash, written before their row | Decided | 1 |
| D36 | Scheduler presets assigned per deck and inherited by subdecks without their own | Decided | 2 |
| D37 | Study day starts at a per-collection hour (default 03:00); steps of 1d or more fall due at its start | Decided | 2 |
| D38 | Studying a deck includes its subdecks; the studied deck's daily limit caps the subdecks' combined total | Decided | 2 |
| D39 | Review events record the device's UTC offset; replay uses it and the recorded scheduler version, keeping old versions available | Decided | 2 |
| D40 | Preset settings are immutable versions identified by UUID; review events record the version ID; each collection has an undeletable default preset | Decided | 2 |
| D41 | Study queues are computed from scheduling state and today's history in effect; learning cards first, then reviews and new cards ordered per preset | Decided | 2 |
| D42 | Suspending and burying are synced card properties; sibling burying is computed from today's events in effect | Decided | 2 |
| D43 | Field values and templates share one text format of semantic marks, `{key args \| content}`, with a registry of mark kinds | Decided | 3 |
| D44 | Fields are edited directly in their rendered form; the source is available behind a toggle | Decided | 3 |
| D45 | Each field definition has a language, overridable per span, which selects glyph forms, text direction, and font fallback | Decided | 3 |

## Open questions

- **Sync server language.** Go or Dart. The server holds no domain logic, so little code would be shared with the client.
- **End-to-end encryption.** Enabled by D10; whether it is default, optional, or deferred is undecided.
- **Plugin licensing.** Whether plugins built against the Milestone G SDK must be AGPL-3.0, or whether the SDK carries a licence exception or permissive licence.
- **FSRS.** Roadmap placement, implementation (e.g. `dart-fsrs` or a custom port), and where parameter optimization runs, including on web.
- **Known-word layer.** Tracking knowledge per word (dictionary entry or lexeme) on top of notes and cards, by linking notes to dictionary entries through their source attribution and deriving word status from card states. It would support duplicate detection and showing known words while mining (Phase 5b). Notes and cards remain the unit of content and scheduling.