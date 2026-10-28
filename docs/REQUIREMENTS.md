# Memuki — Requirements

This document lists what Memuki must do. Phasing is in [ROADMAP.md](ROADMAP.md); design is in [ARCHITECTURE.md](ARCHITECTURE.md).

## Platforms

| Platform | Introduced | Notes |
|---|---|---|
| Linux | Milestone A | Primary development platform |
| Android, iOS | Milestone D | Full feature parity with desktop |
| Windows, macOS | Milestone D | Validated before support is claimed |
| Web | Milestone E | `app.memuki.net`; browser storage limits apply |

## Functional requirements

### Collections and decks

- A user can have several collections.
- A collection contains decks; cards are organized into decks within their collection.
- Collections are the unit of separation between independent bodies of material (for example, personal study and course material).

### Notes, fields, and templates

- Users define note types with typed, validated fields.
- Fields support plain text, a restricted rich-text subset (including furigana/ruby), and media references.
- A note generates one or more cards from its note type's card templates.
- Each card has independent scheduling state.
- Templates define structure: which fields appear, where, and in which role. Visual styling is provided by Memuki's design system.
- Supported card types include basic, reversed, cloze, vocabulary, and typed answer.
- Editing a note or template preserves review history of unaffected cards.

### Scheduling

- Configurable deterministic learning steps (default 1m → 4h → 12h → 1d → 2d) and relearning steps (default 10m → 1h → 12h → 2d).
- Graduating and easy intervals for cards leaving learning.
- Review intervals for graduated cards from an SM-2-style ease multiplier.
- Grades: Again, Hard, Good, Easy.
- Leech detection, daily limits, suspending, burying, and sibling burying.
- Burning: cards whose next interval reaches a configurable threshold (default 1 year) leave normal scheduling and move to a burned category that can be reviewed separately. Cards can also be burned and unburned manually.
- Correct handling of time zones, day boundaries, and sub-day intervals.
- Review undo that preserves review-history integrity.
- Review history detailed enough to support FSRS later without data loss.
- FSRS scheduling with configurable desired retention and parameter optimization, in a later milestone.

### Study

- Keyboard-first reviewing with configurable shortcuts on desktop; touch-optimized reviewing on mobile.
- Audio and image rendering; clear feedback for missing media.
- Session progress and empty-queue states.
- Separate review sessions for burned cards.

### Management and statistics

- Note and card browser with search, filtering, editing, and bulk operations.
- Due/new counts, review activity, retention, streaks, and per-card review history.

### Dictionaries and mining

- Offline, indexed dictionary search across multiple installed providers.
- Japanese support: readings, deinflection, kanji information.
- At least one non-Japanese language supported through the same architecture.
- Installable, versioned dictionary packages with attribution and license metadata.
- Mining profiles map dictionary results into note fields.
- Duplicate detection, editable previews, and provenance preserved on created notes.
- No language-specific fields hardcoded into the SRS core.

### Import, export, and backup

- Import Anki `.apkg` (and `.colpkg` where compatible): notes, note types, cards, tags, media, review history, and scheduling state where compatible.
- Anki templates are converted to Memuki templates; styling and scripts are not imported, and anything dropped is reported.
- Verified local backups and restore.
- Structured export including media and review history.

### Synchronization

- Optional account-based sync between installations.
- Studying and editing never wait on the network.
- Concurrent offline changes never silently lose notes or review history.
- Third-party dictionary data is not synced; package references and preferences are.

### Later milestones

- OCR, image, document, subtitle, and audio capture feeding the same mining pipeline (Milestone F).
- Plugin SDK and first-party browser extension (Milestone G).
- Courses, classrooms, and institutional reporting (Milestone H).

## Non-functional requirements

### Performance

- No network requests on the review path.
- No expensive synchronous work on the UI thread.
- Performance is measured against a defined reference collection. Numeric budgets are set once baseline measurements exist (see [ROADMAP.md](ROADMAP.md#performance-budgets)).

Metrics to track:

- Cold start to first usable screen.
- Card-to-card transition time during review.
- Note browser search latency.
- Dictionary lookup latency.
- Memory use, and battery use on mobile.

### Data integrity

- Stable, client-generated entity identifiers.
- Transactional persistence; failed operations leave no partial state.
- Versioned, tested schema migrations.
- Append-only review history.
- Recoverable imports and synchronization.

### Security and privacy

- Validated inputs and imports.
- Authenticated sync over secure transport.
- No credentials in the repository.
- Study content excluded from logs by default.
- Scoped plugin permissions.

### Accessibility

- Keyboard focus navigation, scalable text, reduced-motion support, and screen-reader labels.

### Localization

- All user-facing strings are externalized from the start.
- Locale-aware dates, numbers, and plurals.
- Translations added incrementally; English is the initial locale.

### Web data safety

- Storage quota and eviction handling.
- Versioned caching and deployment that keeps assets and database schema compatible.
- User-facing backup and recovery information.
