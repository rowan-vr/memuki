# Memuki — Vision

Memuki is a free, open-source, offline-first, cross-platform spaced-repetition and knowledge-mining application.

It starts with language learning, especially dictionary-based vocabulary mining, while keeping the underlying SRS and mining architecture subject-independent.

## Product principles

1. **Cross-platform first.** One Flutter client for Linux, Windows, macOS, Android, iOS, and Web.
2. **Offline-first.** Studying, editing, searching installed dictionaries, and creating cards work without a server.
3. **Performance.** Fast startup, responsive navigation, and no network dependency during reviews.
4. **Data ownership.** Local storage, open export, backups, and migration from Anki.
5. **Flexible learning.** Custom note types, fields, templates, and independently scheduled cards.
6. **Consistent presentation.** Templates define what a card shows; Memuki's design system defines how it looks. Cards stay readable and coherent regardless of who authored the template.
7. **Mining as a core feature.** Search → Enrich → Preview → Create.
8. **Extensibility.** Dictionary providers, mining profiles, data packs, and eventually executable plugins.
9. **AI-optional.** Core features never require paid AI services.
10. **Native where beneficial.** Follow platform conventions without fragmenting the application's identity.
11. **Mobile feature parity.** Every core workflow is available on mobile, even when its layout differs from desktop.
12. **Web as a first-class target.** `app.memuki.net` provides the core learning experience, with explicit browser storage and offline limitations.
13. **Localized.** The interface is translatable; English is not assumed to be the user's language.

## Non-goals

- **Not an Anki clone.** Anki import is a migration path. Memuki does not aim to reproduce Anki's feature set, template system, or add-on ecosystem.
- **No arbitrary card styling.** User-supplied HTML, CSS, and JavaScript in templates are not supported.
- **No AnkiConnect or Yomitan protocol compatibility.**
- **No mandatory AI or accounts.** Sync and AI features are optional.

## North Star

Memuki should make capturing, organizing, and remembering knowledge effortless, regardless of device, connectivity, language, or subject.
