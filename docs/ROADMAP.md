# Memuki — Development Roadmap

> **Last updated:** 2026-10-29
> **Scope:** 8 milestones, 21 phases (0–19, with Phase 5 split into 5a and 5b)
> **Sequence:** Linux → Sync → Mobile → Web → Advanced Mining → Extensions → Education

See [VISION.md](VISION.md) for principles, [REQUIREMENTS.md](REQUIREMENTS.md) for requirements, and [ARCHITECTURE.md](ARCHITECTURE.md) for design and the decision log.

A phase is complete when its acceptance criteria and tests pass, not after a fixed period.

## Milestone overview

| Milestone | Phases | Objective | Scope | Progress |
|---|---|---|---|---|
| A — Functional SRS | 0–4 | Working Linux SRS application | Committed | In progress |
| B — Desktop Mining & Migration | 5a–6 | Dictionary mining and Anki import | Committed | Not started |
| C — Synchronization | 7–8 | Reliable offline-first multi-device sync | Committed | Not started |
| D — Mobile & Anki Replacement | 9–11 | iOS/Android parity and 30-day Anki-free trial | Committed | Not started |
| E — Web Application | 12–13 | Flutter Web at app.memuki.net | Planned | Not started |
| F — Advanced Mining | 14–15 | OCR, documents, audio, and video | Horizon | Not started |
| G — Extension Ecosystem | 16–17 | Plugin SDK and first-party browser extension | Horizon | Not started |
| H — Education | 18–19 | Courses, classrooms, teachers, and reporting | Horizon | Not started |

Task-level work is tracked as issues under the matching [GitHub milestones](https://github.com/rowan-vr/memuki/milestones). This document tracks phase status and acceptance criteria.

Scope:

- **Committed:** scoped and sequenced; work proceeds in order.
- **Planned:** intended next; scope may change based on earlier milestones.
- **Horizon:** direction, not commitment. Re-scoped before work begins.

### Anki during development

Anki remains the primary study tool until Milestone D. Collections imported before then are test copies. There is no incremental or two-way exchange with Anki; the final migration happens at the start of the Phase 11 trial.

---

# Milestone A — Functional SRS

## Phase 0 — Project Setup

**Status:** Done

**Goal:** A reproducible, buildable, tested Flutter project.

### Implementation

- Initialize the Git monorepo with `apps/client/` as the Flutter application.
- Pin the Flutter version with FVM.
- Linux as the initial development target, without blocking other targets.
- Choose routing, state management, and dependency injection.
- Structured logging and top-level error handling.
- Base theme: light and dark modes, typography including Japanese font rendering, spacing tokens, and layout breakpoints. Reusable components are added as features need them.
- Localization infrastructure (`gen-l10n`) with English as the initial locale.
- Formatting, analysis, and lint rules.
- Unit and widget test infrastructure.
- GitHub Actions: formatting, analysis, tests, Linux build, dependency caching, path-based triggers.
- Development setup and conventions documented.
- `LICENSE` (AGPL-3.0), contributor licence agreement, and trademark policy.

### Decisions

| Decision | Status |
|---|---|
| Routing: go_router with typed routes from go_router_builder | Decided — D19 |
| State management and DI: Riverpod | Decided — D20 |
| Japanese text: bundled Noto Sans JP as the app typeface | Decided — D21 |
| Generated code committed; CI checks it is up to date | Decided — D22 |
| AGPL-3.0 for code, CLA for contributions, dictionary data under upstream licences, trademark policy | Decided — see [ARCHITECTURE.md](ARCHITECTURE.md#licensing) |

### Acceptance Criteria

- A clean checkout builds and launches on Linux using documented `fvm flutter` commands.
- The project passes all configured checks, and CI fails on formatting, analysis, or test failures.
- A minimal navigable shell works in light and dark themes and adapts to window size.
- User-facing strings go through the localization layer.

---

## Phase 1 — Domain Models and Persistence

**Status:** Done

**Goal:** A durable, sync-ready local data layer.

### Implementation

Core entities:

- Collection
- Deck
- NoteType
- FieldDefinition
- Note
- StudyCardTemplate
- StudyCard
- Tag
- NoteTag
- MediaAsset
- ReviewEvent
- SchedulingState

Requirements:

- A user can have several collections; each collection contains decks.
- A note can generate multiple cards, each with independent scheduling state.
- Fields support metadata and future specialized types.
- Source attribution and relationships can be added without redesigning the model.

Persistence:

- SQLite as the primary local database; evaluate Drift for typed access and migrations.
- Transactional operations.
- Versioned schemas, migrations, and migration error handling.
- Indexes for common queries.
- Repositories and query services.
- Media storage separate from the main database.
- Local change outbox for later sync.
- Deterministic test fixtures.

### Decisions

These shape the schema and the sync design in Phases 7–8, so they are settled here rather than later.

| Decision | Direction | Status |
|---|---|---|
| Entity ID format | Client-generated UUIDv7 | Decided |
| Change ordering | Hybrid logical clock timestamps | Decided |
| Deletion | Tombstones | Decided |
| Merge granularity | Per-field LWW on notes; per-entity elsewhere | Decided |
| Card identity | `(note ID, card template ID)` with stable template IDs | Decided |
| Scheduling state | Materialized cache, rebuildable by replaying review events | Decided |
| Undo | Compensating event; original event is kept | Decided |
| Media addressing | Content-addressed by hash | Decided |
| Media layout | A folder per collection, files named by SHA-256 hash; the file is written before its row | Decided |
| Database access library | Drift | Decided |
| Collection/deck model | Several collections per user, each with decks | Decided |
| Note type scope | Per collection; reuse elsewhere by copying | Decided |
| Deck nesting | Nested; each deck has an optional parent deck in the same collection | Decided |
| Browser storage feasibility | Viable on OPFS; IndexedDB as fallback. See [spike results](spikes/browser-storage.md) | Verified |
| Cross-collection integrity | Composite foreign keys on `(collection_id, id)`; `collection_id` is immutable, moving is a copy | Decided |
| Deleting a deck | Hides its subdecks and their cards; notes left without visible cards are hidden | Decided |
| Deleting a tag | Hides the tags below it and removes them from notes | Decided |
| Tombstone scope | A delete tombstones only its target; views hide the rows below it | Decided |
| Outbox contents | One entry per changed entity, overwritten by later changes; sync reads the current row (or tombstone) when pushing | Decided |
| HLC storage | Fixed-width hex text, stamped by repositories in the same transaction as the change | Decided |
| Scheduling state sync | Not synced; rebuilt from synced review events | Decided |

### Acceptance Criteria

- Create, read, update, and delete all core entities.
- Data survives application restarts.
- Notes generate stable card associations.
- Schema migrations preserve existing data.
- Failed transactions leave no partial changes.
- Browser storage spike result is recorded in [ARCHITECTURE.md](ARCHITECTURE.md).
- Database behavior is covered by automated tests.

---

## Phase 2 — Scheduling Engine

**Status:** Done

**Goal:** A reliable, deterministic, configurable SRS engine.

### Implementation

- Versioned scheduler interface, independent of Flutter and persistence, so additional schedulers (FSRS) can be added later.
- Default scheduler:
  - **Learning steps** for new cards (default 1m → 4h → 12h → 1d → 2d), then graduation with a graduating interval (default 3d) or, on Easy, an easy interval (default 14d).
  - **Review intervals** for graduated cards using an SM-2-style ease multiplier.
  - **Relearning steps** after a lapse (default 10m → 1h → 12h → 2d), then return to review with a minimum interval (default 2d).
  - **Leech detection** after a configurable number of lapses (default 8), tagging the card.
  - **Burning:** when a grade produces a next interval at or above the burn threshold, the card becomes Burned instead of receiving a due date. Burned cards are excluded from normal queues and daily limits.
- Manual burn and unburn, recorded as events.
- Grades: Again, Hard, Good, Easy.
- Per-card scheduling state (phase, current step, interval, ease, lapse count, due time).
- Scheduler configuration presets, versioned.
- Immutable review history with materialized scheduling state.
- Each review event records the scheduler ID and version, configuration version, grade, timestamp, previous and next due time, response time, and the card's state before it. This is sufficient to compute FSRS memory state from history later.
- Daily limits.
- Suspended and buried cards; sibling burying.
- Review queues and due-card selection.
- Time zones and day boundaries, including the interaction between sub-day steps (hours) and day-level steps.
- Review undo and correction behavior.
- Specification tests for every step transition.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Learning and relearning | Deterministic, configurable steps | Decided |
| Default step values | Learning 1m → 4h → 12h → 1d → 2d; graduating 3d; easy 14d; relearning 10m → 1h → 12h → 2d; minimum 2d; leech at 8 lapses | Decided |
| Review-phase algorithm | SM-2-style ease multiplier | Decided |
| Step grade semantics | Again: first step; Hard: repeat current step; Good: next step, graduating after the last; Easy: graduate immediately with the easy interval | Decided |
| Grades | Again, Hard, Good, and Easy are all stored and shown | Decided |
| Ease recovery | In review, Good raises ease slightly, up to the starting ease; the amount is set per preset | Decided |
| Review intervals | Hard: interval × 1.2; Good: (interval + half the days late) × ease; Easy: (interval + days late) × ease × 1.3; each at least one day more than the grade below. Ease starts at 250% with a minimum of 130%; Again −20, Hard −15, Good +5 up to the starting ease, Easy +15 percentage points | Decided |
| Interval after a lapse | A configurable share of the previous interval (default 0%), at least the minimum interval | Decided |
| Leeches | A lapse that reaches the leech threshold, or every half of it after (8, 12, 16, …), adds a root `leech` tag to the card's note; the card keeps being scheduled. The threshold is per preset and can be disabled | Decided |
| Unreplayable events | Replayed with the card's current preset and scheduler, with a warning; removing them later uses undo events, so history stays append-only | Decided |
| Fuzz | Review intervals of 3d or more are spread within a range that narrows to about ±5% for long intervals, seeded by the card and its review count so replay reproduces it | Decided |
| Burned state | Cards whose next interval reaches a configurable threshold are burned and leave normal scheduling | Decided |
| Burn threshold | Per preset, can be disabled; default 1 year | Decided |
| Grading a burned card | Pass: stays burned; Again: returns to relearning | Decided |
| Unburning | The card returns to review with its interval and ease, due at the start of the current study day | Decided |
| Undo and redo | An undo is an event referring to the event it cancels; an event is in effect unless an undo in effect refers to it. Undo cancels the latest review, burn, or unburn in effect; redo cancels the latest undo, while only undos and redos follow it. Undoing after a redo refers to the action again, so chains are at most redo → undo → action | Decided |
| Leech tag on undo | Undoing below the leech threshold removes the `leech` tag from the note unless another of its cards is still at or above its own threshold; a redo that reaches it again re-tags | Decided |
| Sub-day vs. day steps | Steps under 1d are exact durations; steps of 1d or more fall due at the start of the study day | Decided |
| Start of study day | Per collection; default 03:00 local time | Decided |
| Configuration scope | Per deck, via shared presets; a deck without its own preset inherits its parent's; root decks without one use the collection's default preset, which cannot be deleted | Decided |
| Preset versions | Editing a preset adds an immutable version with its own ID; review events record it | Decided |
| Default daily limits | 50 new cards and 500 reviews per day, per preset | Decided |
| Studying a parent deck | Includes the cards of all its subdecks; studying a subdeck includes only that subdeck and the decks below it | Decided |
| Daily limits in nested decks | Each subdeck's own limit applies, and the studied deck's limit caps the combined total | Decided |
| Queue order | Due learning and relearning cards first; then reviews and new cards, mixed evenly by default, or reviews first or new cards first, per preset | Decided |
| New card order | Creation order by default (oldest note first, a note's cards in template order), or random with a fixed order for the study day, per preset | Decided |
| What the limits count | The new-card limit counts cards first studied today; the review limit counts reviews of cards in the review phase. Learning and relearning cards are not limited. Counts come from the history in effect, so an undo gives the slot back | Decided |
| Learning ahead | When nothing else is left, learning cards due within 20 minutes are shown early | Decided |
| Suspending | A synced flag on the card; a suspended card keeps its scheduling state and is left out of every queue until unsuspended | Decided |
| Burying | A synced time on the card until which it is left out of queues, chosen per bury (e.g. later today or the next study day); a study session can also skip cards for that session only, without storing anything | Decided |
| Sibling burying | Once a new or review card of a note is studied today, the note's other new and review cards are left out of the day's queue, per preset (both on by default, using the studied deck's preset). Studying a learning card buries them for the current session by default, or for the day, or not at all. Learning cards are never buried. Computed from today's events in effect, so an undo brings the sibling back | Decided |
| Clock changes and day steps | A day step falls due at the day start in the UTC offset of the review, so after clocks go forward a learning card on a day step is shown up to an hour after the day starts. Reviews are unaffected, since every review due today is shown all day | Decided |
| Which study day an event belongs to | Today is computed in the device's current offset, so after a change of offset (travel, daylight saving) reviews recorded in the old offset may count towards a different study day for limits and sibling burying | Decided |
| FSRS | Separate later phase; placement TBD | Decided |

### Acceptance Criteria

- Step transitions match the specification for every grade.
- Cards reaching the burn threshold are burned and never appear in normal queues.
- Identical inputs produce identical results.
- Review events persist correctly and contain the fields required for future FSRS computation.
- Scheduling state is correct after restart and can be rebuilt from review history.
- Undo does not remove review history.
- Day rollover, time-zone, and sub-day step cases are tested.
- Scheduling never requires network access.

---

## Phase 3 — Notes, Fields, and Templates

**Status:** Not started

**Goal:** Users define what information is stored and how it is studied.

### Implementation

Design system (built first; card rendering and editors depend on it):

- Visual direction: colour palette, type scale, iconography, and motion.
- Component tokens beyond Phase 0 spacing: corner radii, elevation, and surfaces.
- Card typography: Japanese text, furigana, audio controls, and the styling of each field role.
- Core components shared by editors and the study screen.
- A component catalogue screen for reviewing tokens and components in both themes and at large text scales.

Notes and templates:

- Create, edit, and delete note types.
- Configurable fields with validation.
- Plain text, restricted rich text (including furigana/ruby), and media references.
- Extensible specialized field types.
- Card templates built from Memuki's template model: field placement, roles, and conditional fields.
- Front/back structure.
- Multiple cards per note.
- Cloze deletion.
- Card-generation rules.
- Card interaction types separate from scheduling.
- Note and template editors with live previews.
- Previews of all cards a note type generates.
- Defined behavior for modified and deleted templates.
- Scheduling history preserved when notes or templates change.

Initial templates:

- Basic
- Basic + Reverse
- Cloze
- Vocabulary
- Typed answer

### Decisions

| Decision | Status |
|---|---|
| Native Flutter rendering from Memuki templates; templates define structure, the design system defines styling; no user HTML/CSS/JS | Decided |
| Visual direction (palette, type scale, iconography, motion) | Open |
| Rich-text field storage format (representation of the restricted subset, including furigana) | Open |
| Template model representation | Open |

### Acceptance Criteria

- Users can create custom note types.
- One note can generate several independently scheduled cards.
- Templates can be modified without resetting unrelated review progress.
- All standard templates render correctly in light and dark themes and at large text scales.
- Card and editor styling comes from design system tokens and components, with no per-template styling.
- Existing notes remain valid after compatible template changes.
- Card generation is covered by automated tests.

---

## Phase 4 — Study Experience

**Status:** Not started

**Goal:** A comfortable daily study workflow on Linux.

### Implementation

Study interface:

- Card reveal and grading.
- Keyboard-first reviewing with configurable shortcuts.
- Review undo.
- Audio and media rendering.
- Session progress and empty-queue states.
- Separate review sessions for burned cards.
- Clear feedback for missing or invalid media.

Management:

- Collection and deck overview.
- Note and card browser.
- Search and filtering.
- Note editing.
- Suspending, burying, burning, and unburning.
- Burned-card view.
- Essential bulk operations.
- Study preferences and limits.

Statistics:

- Due, new, and burned cards.
- Review activity.
- Learning and review counts.
- Basic retention statistics.
- Daily activity and streaks.
- Review-history inspection.
- Statistics count only reviews of cards that are not deleted; deleted cards keep their review events.

Visual polish:

- Review screen, deck overview, browser, and statistics brought in line with the design system.
- Designed empty, loading, and error states.
- Transitions and feedback animations that respect reduced-motion settings.

Quality:

- Accessible focus navigation.
- Scalable text.
- Reduced-motion support.
- Responsive desktop layouts.
- Reference collection and performance measurement harness (see [Performance budgets](#performance-budgets)).
- A small Anki import fixture for testing with real card data.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Reference collection | Size and composition defined in this phase for performance measurement | Open |

### Acceptance Criteria — Milestone A

- Create a note and generate cards.
- Review cards and persist scheduling results.
- Restart the application and continue correctly.
- Browse, search, and edit existing notes.
- Study and management screens use design system components and have designed empty, loading, and error states.
- Baseline performance metrics are recorded against the reference collection.
- No server or external account is needed.

**Milestone A complete: Memuki is a functional Linux SRS.**

---

# Milestone B — Desktop Mining & Migration

## Phase 5a — Dictionary Infrastructure and Japanese Search

**Status:** Not started

**Goal:** Fast, offline dictionary search for Japanese.

### Implementation

Provider architecture:

- Subject-independent `KnowledgeProvider` interface.
- Normalized knowledge entries:
  - Headwords and concepts.
  - Languages and translation languages.
  - Readings and pronunciations.
  - Definitions and meanings.
  - Alternative forms.
  - Grammatical information.
  - Example sentences.
  - Related concepts.
  - Frequency metadata.
  - Source and licensing information.
- Multiple providers per lookup with priorities and per-source attribution.

Storage and packages:

- Indexed offline dictionary storage, separate from collections.
- Versioned dictionary packages.
- Install, remove, and update packages.
- Report storage usage per package.

Japanese search:

- JMdict or Jitendex.
- KANJIDIC2.
- Optional KanjiVG stroke-order data.
- Deinflection of conjugated forms, implemented in Memuki.
- Kana and kanji lookup, including prefix search.
- A tokenization/indexing strategy suitable for CJK text.

Quick Lookup:

- Global lookup interface searching installed providers.
- Multiple results and detailed entry view.

Dictionary licences, including source-specific terms such as EDRDG's, are reviewed before redistribution. Packages carry their own licence and attribution metadata, independent of the code licence.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Primary Japanese dictionary | JMdict or Jitendex | Open |
| CJK search indexing | FTS5 trigram, custom tokenizer, or dedicated index. Trigram covers three or more characters; shorter substrings need a fallback | Open |
| Dictionary package format | Prebuilt SQLite database, versioned, with licence and attribution metadata | Proposed |
| EDRDG licence conditions | Reviewed before redistribution | To verify |

### Acceptance Criteria

- Japanese words, including conjugated forms, can be looked up offline.
- Multiple dictionaries contribute to one result set with attribution.
- Packages can be installed, updated, and removed without affecting collections.

---

## Phase 5b — Search-Based Mining and Second Language

**Status:** Not started

**Goal:** Turn dictionary results into notes, and validate the architecture with a second language.

### Implementation

Mining:

- Selection of definitions and metadata from results.
- Configurable mining profiles.
- Field mapping from entries to note fields.
- Card previews.
- Duplicate detection.
- Editing before saving.
- Dictionary provenance stored on created notes.

Mining pipeline:

1. Input or search.
2. Knowledge-provider lookup.
3. Optional enrichment.
4. Field mapping.
5. Duplicate checking.
6. Note preview.
7. Note creation and card generation.

Second language:

- Kaikki/Wiktionary structured data importer.
- At least one non-Japanese language validated end to end.
- Differing language and definition-language combinations.

Future or optional providers: CC-CEDICT, FreeDict, Korean learner dictionaries where licensing permits, subject-specific providers.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Second validation language | — | Open |
| Duplicate detection criteria | — | Open |

### Out of scope

- OCR and camera capture.
- PDF and video processing.
- Browser extension.
- AnkiConnect and Yomitan integration.
- Public plugin marketplace.

### Acceptance Criteria

- A dictionary result becomes an editable note in a few actions.
- The same pipeline works for a second language.
- No language-specific fields are hardcoded into the SRS core.
- Dictionary attribution is preserved on created notes.

---

## Phase 6 — Anki Import and Data Portability

**Status:** Not started

**Goal:** Import existing Anki collections without losing learning history.

### Implementation

- Anki `.apkg` import; `.colpkg` where compatible.
- Import decks, notes, note types, fields, templates, tags, cards, media, review history, and scheduling state where compatible.
- Convert Anki templates into Memuki templates. Styling and scripts are not imported.
- Preserve original identifiers and provenance.
- Import preview, duplicate detection, and selective import.
- Validation and detailed import reports, including everything that was converted lossily or dropped.
- Explicit handling of Anki scheduler-version differences.
- Imported cards keep their Anki phase, step, interval, ease, and lapse count where compatible; full Anki review history is kept for later FSRS use.
- Imported cards are not burned automatically; the import preview reports cards at or above the burn threshold and offers to burn them.
- No silent reset of learning progress.
- Verified local backups and restore.
- Structured export including media and review history.
- Investigate Anki export where feasible.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Anki as a source | One-time migration; no incremental or two-way exchange | Decided |
| Anki templates | Converted to Memuki templates; styling and scripts not imported | Decided |
| Scheduling state | Phase, step, interval, ease, and lapse count kept where compatible | Decided |
| Burning on import | Not automatic; preview reports cards at or above the burn threshold and offers to burn them | Proposed |

### Acceptance Criteria — Milestone B

- Representative Anki collections import correctly.
- Review history is preserved to the extent supported.
- Unsupported content is reported.
- A verified backup can be restored.
- Desktop studying, dictionary lookup, editing, and mining work without Anki Desktop.

**Milestone B complete: Memuki has a complete desktop study and mining workflow.**

---

# Milestone C — Synchronization

## Phase 7 — Sync Server and Protocol

**Status:** Not started

**Goal:** Synchronize installations without compromising offline operation.

### Backend

- Content-agnostic relay server with PostgreSQL; clients perform all merging.
- Per-collection access control.
- Collection snapshot storage for device bootstrap.
- Account registration and authentication.
- Device identities.
- Authorization and access control.
- Versioned sync protocol.
- Database migrations.
- Secure transport.
- Logging and basic monitoring.

### Synchronization

- Push/pull of the local change outbox.
- Change cursors and pagination.
- Idempotency.
- Retry with exponential backoff.
- Initial device bootstrap.
- Media transfer.
- Version compatibility.

Synchronized data:

- Collections, decks, notes, cards, note types, templates, tags.
- Review history. Scheduling state is rebuilt from it on each device.
- Mining profiles and relevant preferences.
- Media metadata and content.
- Dictionary package references and preferences.

Third-party dictionary databases are not synced. Each device installs packages independently.

### Decisions

| Decision | Status |
|---|---|
| Server relays change batches; clients merge | Decided |
| Server implementation language (Go or Dart) | Open |
| End-to-end encryption: default, optional, or deferred | Open |
| Self-hosting support | Enabled by relay design; packaging open |
| Protocol schema format in `contracts/sync` | Open |
| Authentication method | Open |

### Acceptance Criteria

- Two desktop installations synchronize.
- Offline changes upload after reconnecting.
- Retried operations do not create duplicates.
- Media references remain valid.
- Reviewing never waits for a server response.
- Protocol compatibility tests pass.

---

## Phase 8 — Conflict Resolution and Reliability

**Status:** Not started

**Goal:** Trustworthy sync under network failures and concurrent changes.

### Implementation

- Conflict-resolution policy per entity type.
- Concurrent review events preserved and merged.
- Deterministic scheduling-state reconciliation.
- Concurrent note and template edits.
- Deletion conflicts.
- Out-of-order and duplicate operations.
- Device clock drift.
- Resumable media sync with integrity validation.
- Reconnection after extended offline periods.
- Sync status and diagnostics.
- Manual conflict resolution where automatic merging is unsafe.
- Server backup and recovery.
- Cross-version client/server compatibility tests.
- Account deletion and data export.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Conflict policy per entity type | Builds on Phase 1 merge granularity | Open |
| Conditions for manual conflict resolution | — | Open |
| Parent cycles from concurrent moves | Two devices can each move a deck or tag under the other. After a merge, a cycle is broken deterministically: the node in the cycle whose parent change has the highest HLC becomes a root | Proposed |
| Tombstone purging and review history of deleted cards | Deleting a card keeps its review events, so a recreated card keeps its history. When and how tombstones are removed for good, and whether a card's events are removed with its tombstone. Rows below a tombstone are hidden, not tombstoned, so purging a row must also remove the rows it hides (see `views.drift`) | Open |

### Test scenarios

- Two devices edit the same note offline.
- Two devices review the same card offline.
- A device disconnects during sync.
- Operations arrive out of order.
- A device reconnects weeks later.
- A media upload is interrupted.
- The server is restored from backup.
- A client performs a full rebootstrap.

### Acceptance Criteria — Milestone C

- Concurrent offline activity does not silently lose notes or review history.
- Recovery and conflict tests pass.
- Clients converge to a consistent state.
- Server outages do not prevent studying.

**Milestone C complete: Memuki has reliable offline-first synchronization.**

---

# Milestone D — Mobile and Anki Replacement

## Phase 9 — Android and iOS Study Client

**Status:** Not started

**Goal:** Daily reviews on mobile.

### Implementation

- Android and iOS runners in the existing Flutter app.
- Adaptive mobile navigation.
- Touch-friendly review controls.
- Safe areas and screen sizes.
- Shared SRS engine, domain, and persistence.
- Offline review queues and local persistence.
- Review undo.
- Media playback.
- Mobile sync.
- App suspension and resumption.
- Native conventions where beneficial.
- Android build and test workflows.
- macOS CI for iOS builds and TestFlight.
- Testing on physical devices.

### Acceptance Criteria

- Study offline on Android and iOS.
- Mobile reviews sync to desktop.
- Review history and scheduling stay consistent.
- No review operation requires an internet connection.

---

## Phase 10 — Mobile Management and Dictionary Mining

**Status:** Not started

**Goal:** Mobile as a complete client.

### Implementation

- Collection and deck management.
- Note browsing and search.
- Note creation and editing.
- Template management.
- Supported bulk operations.
- Mining profile management.
- Dictionary installation and updates.
- Offline dictionary search and Quick Lookup.
- Dictionary entry inspection.
- Duplicate detection.
- Note and card previews.
- Search-based note generation.
- File import and export.
- Backup and restore.
- Japanese IME and furigana support.
- Robust handling of lifecycle interruptions.

Desktop may use denser multi-panel layouts; mobile exposes the same functionality through touch-optimized screens.

### Acceptance Criteria

- Create and edit notes entirely on mobile.
- Search offline dictionaries.
- Generate cards from dictionary entries.
- Manage templates and mining profiles.
- Review without desktop access.

---

## Phase 11 — Mobile Parity and Production Readiness

**Status:** Not started

**Goal:** A reliable daily Anki replacement across desktop and mobile.

### Implementation

- Feature-parity audit and missing mobile workflows.
- Startup, memory, and battery optimization.
- Database migration validation.
- Offline media caching hardening.
- Sync diagnostics.
- Accessibility validation.
- Japanese keyboard input testing.
- Lifecycle interruption, low-storage, and network-transition testing.
- Android release automation.
- iOS signing and TestFlight workflows.
- Crash diagnostics.
- Windows and macOS desktop validation before claiming support.
- Final migration from Anki, with Anki kept available as a fallback.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Crash diagnostics provider | Reports exclude study content | Open |

### Final acceptance test

**30 consecutive days without opening Anki on desktop or mobile.**

The trial covers:

- Regular reviews.
- Dictionary mining.
- Note editing.
- Synchronization.
- Offline use.
- Media handling.
- Collection management.

### Acceptance Criteria — Milestone D

- All core learning workflows function across desktop and mobile.
- Sync is reliable.
- No critical migration or review blockers remain.
- The 30-day trial completes successfully.

**Milestone D complete: Memuki replaces Anki for everyday use.**

---

# Milestone E — Web Application

## Phase 12 — Browser Runtime and Storage

**Status:** Not started

**Goal:** The core Memuki application in browsers, from the existing Flutter codebase.

### Implementation

- Flutter Web target in `apps/client/`.
- Shared domain, scheduling, mining, and UI.
- Web persistence using the approach validated in the Phase 1 spike.
- Browser storage compatibility and fallbacks.
- Transactional operations and browser migration validation.
- Local dictionary indexing.
- Web-compatible media storage.
- Dictionary package imports.
- File import/export through browser APIs.
- Storage quota and eviction handling, including a persistent storage request.
- Explicit handling of private-browsing limitations.
- Browser navigation and keyboard shortcuts.
- Responsive desktop and mobile-browser layouts.
- Authentication and sync.
- Secure sessions and cross-origin policies.
- Browser integration and smoke tests.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Browser persistence | Drift on OPFS; IndexedDB fallback with a warning; persistent storage requested | Decided |
| Cross-origin isolation | COOP/COEP headers (D25); `COEP: credentialless` evaluated for cross-origin media | Decided |
| Sign-in flow | Redirect-based, since `COOP: same-origin` breaks popups | Proposed |
| Safari storage behaviour | Not covered by the Phase 1 spike, including seven-day eviction | To verify |
| Supported browsers | — | Open |

### Acceptance Criteria

- Open Memuki in a browser.
- Create and edit notes.
- Search installed dictionaries.
- Generate cards.
- Study and store reviews locally.
- Sync with native installations.
- Data survives refreshes and restarts in supported browser modes.
- Unsupported browser features fail gracefully.

---

## Phase 13 — Offline Web and Production Deployment

**Status:** Not started

**Goal:** Launch `https://app.memuki.net`.

### Implementation

- Production Flutter Web builds.
- CI/CD deployment with release versioning and rollback.
- HTTPS and security headers.
- Caching and asset delivery.
- Explicit PWA/service-worker strategy; cached application shell.
- Safe upgrades with no mismatch between cached assets and database schema.
- Storage usage information.
- Documented browser data-loss risks.
- Recovery and export mechanisms.
- Tests for multiple tabs, offline study and reconnection, session expiry, storage pressure, Japanese IME, and large collections.
- Deployment and recovery documentation.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| PWA/service-worker strategy | — | Open |
| Hosting for app.memuki.net | — | Open |

### Acceptance Criteria — Milestone E

- `app.memuki.net` serves the Flutter Web client over HTTPS.
- Users can study, search, mine through lookup, edit, and sync.
- Supported browsers perform documented offline study workflows.
- Deployment and rollback are automated.
- Unsynced data is protected as far as browser capabilities permit.
- Storage limitations are communicated clearly.

**Milestone E complete: Memuki is accessible through the browser.**

---

# Milestone F — Advanced Mining (Horizon)

## Phase 14 — OCR and Image Capture

**Status:** Not started

**Goal:** Image-based mining through the existing capture pipeline.

### Implementation

- Camera and screenshot capture; image import.
- Image preprocessing where useful.
- Pluggable offline OCR providers.
- Text-region selection.
- OCR correction before mining.
- Language hints and confidence information.
- Reuse of dictionary lookup and enrichment.
- Source context and image references preserved.
- Camera permissions and privacy.
- Evaluation on Japanese, Latin-script, and complex scripts.
- Platform-specific OCR performance.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| OCR providers | Offline; platform OCR APIs or a bundled engine | Open |

### Acceptance Criteria

- Capture or import an image, extract and correct text, look it up, generate an editable note, and study the resulting cards.

---

## Phase 15 — Documents and Rich Media

**Status:** Not started

**Goal:** Mine from more types of source material.

### Implementation

- PDF text extraction.
- Clipboard and document ingestion.
- Subtitle-file processing with timestamp preservation.
- Optional local audio transcription; optional remote transcription providers.
- Source-context preservation and links to source locations.
- Contextual note previews.
- Media ownership and licensing considerations.
- Configurable storage and retention.
- Optional AI enrichment.

All capture providers feed the existing mining pipeline.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Local transcription engine | — | Open |

### Acceptance Criteria — Milestone F

- Multiple capture methods produce a common mining input.
- Extracted content can be enriched and converted into cards.
- Source context remains accessible where possible.
- Core mining works offline without AI.

**Milestone F complete: Memuki supports advanced knowledge capture.**

---

# Milestone G — Extension Ecosystem (Horizon)

## Phase 16 — Public Plugin SDK

**Status:** Not started

**Goal:** Extend Memuki without modifying the application.

### Implementation

Public APIs for notes and cards, knowledge providers, dictionary lookup, mining processors, capture providers, media access, configured UI extension points, and plugin settings.

Extension categories:

1. **Data packages:** dictionaries, knowledge datasets, template sets, language packs.
2. **Declarative extensions:** mining profiles, field mapping, processing rules, configurable workflows.
3. **Executable plugins:** sandboxed processing code, advanced enrichment, specialized functionality.

Requirements:

- Versioned plugin manifests and API compatibility constraints.
- Scoped permissions.
- Package integrity and signatures.
- Dependency declarations.
- Resource limits and error isolation.
- Install, update, disable, and uninstall.
- Developer documentation, example projects, and compatibility tests.

WASM or another portable sandbox is evaluated. Downloaded executable code may not be permitted on iOS.

### Decisions

| Decision | Status |
|---|---|
| Plugin licensing: AGPL-3.0 required, licence exception, or permissive SDK | Open |
| Executable plugin sandbox: WASM or another portable sandbox | Open |
| Executable plugins on iOS | To verify against App Store rules |

### Acceptance Criteria

- Third-party developers can build extensions against documented APIs.
- Plugin failures do not corrupt collections.
- Compatibility and permissions are enforced.
- Unsupported capabilities are reported clearly.

---

## Phase 17 — Browser Extension and Distribution

**Status:** Not started

**Goal:** First-party browser integration and extension distribution.

### Browser add-on

- Capture selected text, source URLs, and metadata.
- Dictionary lookup.
- Send captures into mining profiles, with note preview where appropriate.
- Multiple configured destinations or collections.
- Secure communication protocol; evaluate native messaging, localhost APIs, and authenticated handoff.
- Explicit user authorization, origin restrictions, scoped access, revocation, and replay protection.

### Extension distribution

- In-app extension manager.
- Install from files or a repository.
- Version compatibility checks and permission display.
- Updates and removal.
- Basic package catalog.
- Community-maintained language and subject packs.
- Independent third-party repositories.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Browser–app communication | Native messaging, localhost API, or authenticated handoff | Open |

### Out of scope

- AnkiConnect compatibility.
- Yomitan protocol compatibility.

### Acceptance Criteria — Milestone G

- Browser selections can be mined using Memuki's add-on.
- Users can install supported extensions.
- Plugins use documented, permission-controlled APIs.
- Cross-platform compatibility is communicated clearly.

**Milestone G complete: Memuki has a public extension ecosystem.**

---

# Milestone H — Education Platform (Horizon)

## Phase 18 — Courses and Classrooms

**Status:** Not started

**Goal:** Institution-managed learning alongside personal study.

### Implementation

- Organization model; teacher and student roles.
- Classroom management and enrollment.
- Courses, study materials, assignments, and deadlines.
- Content distribution through shared collections, which separate institution-managed material from personal material.
- Institutional tooling built as separate clients of the sync server; the server remains content-agnostic.
- Managed note types, templates, and recommended mining profiles.
- Assignment sync.
- Ownership and permission boundaries.
- Enrollment changes and access revocation.
- Privacy and consent requirements.
- Audit logging.
- Offline assignment workflows.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Course content delivery | Shared collections, written by separate institutional tools; server stays content-agnostic | Decided |

### Acceptance Criteria

- Teachers can create courses and assignments.
- Students receive material in the regular Memuki client.
- Personal collections remain separate.
- Leaving a course does not affect personal study data.

---

## Phase 19 — School Administration and Reporting

**Status:** Not started

**Goal:** Institutional management.

### Implementation

- Teacher dashboards and classroom progress views.
- Assignment tracking.
- Retention and learning analytics; cohort reporting.
- Student onboarding.
- Organization administration; role and permission management.
- Export and reporting tools.
- Privacy and data-retention controls.
- Operational monitoring, backup, and disaster recovery.
- Load and scalability testing.
- Optional institutional licensing and billing.
- School deployment documentation.

The personal application remains fully functional without a school subscription.

### Decisions

| Decision | Direction | Status |
|---|---|---|
| Institutional licensing and billing | Optional; relies on dual-licensing rights from the CLA | Open |

### Acceptance Criteria — Milestone H

- Schools can onboard students and teachers.
- Teachers can distribute assignments.
- Authorized progress data is visible.
- Administrators can manage classes and accounts.
- Personal learning data remains protected.

**Milestone H complete: Memuki supports institutional learning.**

---

# Cross-cutting requirements

## Performance budgets

Numeric targets are not fixed yet. Phase 4 establishes a reference collection and a measurement harness; budgets are set from those baselines and enforced from then on.

Reference collection (to be defined in Phase 4): a synthetic collection with a realistic number of notes, cards, and review events, plus installed dictionaries.

Tracked metrics:

| Metric | Target |
|---|---|
| Cold start to first usable screen | TBD |
| Card-to-card transition during review | TBD |
| Note browser search latency | TBD |
| Dictionary lookup latency | TBD |
| Memory use (desktop, mobile) | TBD |
| Battery use during a review session (mobile) | TBD |

Other rules:

- No network requests on the review path.
- No expensive synchronous work on the UI thread.

## Data integrity

- Stable entity identifiers.
- Transactional persistence.
- Versioned database migrations.
- Durable, append-only review history.
- Verified backups.
- Recoverable imports and synchronization.

## Cross-platform compatibility

- One shared Flutter client.
- Platform-neutral domain logic.
- Platform-specific integrations behind interfaces.
- Mobile feature parity.
- Browser storage and offline limitations handled explicitly.

## Localization

- Strings externalized from Phase 0.
- Locale-aware formatting.
- Translations added incrementally.

## Testing

- Unit tests for domain logic.
- Specification tests for each scheduler; reference-vector tests for FSRS once added.
- Database migration tests.
- Widget and integration tests.
- Sync conflict and recovery tests.
- Platform-specific smoke tests.
- Automated release validation.

## Security

- Validated inputs and imports.
- Scoped plugin permissions.
- Authenticated sync over secure transport.
- No credentials in Git.
- Safe media and template handling.
- Study content excluded from logs by default.

## Extensibility

- Internal extension interfaces established early.
- Public APIs versioned.
- Data packs separate from executable plugins.
- Dictionary licensing and attribution tracked.

## CI/CD

- Affected-component checks.
- Cached dependencies.
- Independent client and server workflows.
- Linux checks for routine development.
- macOS CI for iOS builds.
- Release signing separate from PR testing.
- Independent versioning of client, server, and extensions.

---

# Development conventions

- Small, testable vertical slices; every phase produces verifiable functionality.
- Explicit acceptance criteria.
- Major architectural decisions recorded in [ARCHITECTURE.md](ARCHITECTURE.md#decision-log).
- Commit messages follow Conventional Commits; see the [README](../README.md#commit-messages).
- Domain logic independent of presentation.
- No premature abstraction or package fragmentation; no empty packages.
- Libraries and protocols chosen after evaluating actual requirements.
- The same quality bar applies to all code regardless of author.
- Data portability preserved.
- Review-history integrity never traded for convenience.
- Independent client and server release cycles.

---

# Deferred functionality

- FSRS scheduling and parameter optimization: after Milestone D (not required for the Anki-replacement trial); exact placement TBD (proposed: before Web).
- OCR and camera mining: Milestone F.
- PDF, audio, and video mining: Milestone F.
- Browser extension and public executable plugins: Milestone G.
- School management: Milestone H.
- Apple Watch: not planned for any current milestone.
- AnkiConnect and Yomitan integration: not planned.
- AI-generated content: optional, never a core dependency.

Search-based dictionary mining is the only mining method through Milestone E.

---

# Current work

Open tasks are tracked as issues under [Milestone A — Functional SRS](https://github.com/rowan-vr/memuki/milestone/1).
