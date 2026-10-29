# Spike: Browser Storage Feasibility

> **Date:** 2026-10-28
> **Issue:** [#17](https://github.com/rowan-vr/memuki/issues/17)
> **Code:** [`spike/browser-storage`](https://github.com/rowan-vr/memuki/tree/spike/browser-storage/spikes/browser-storage) (not merged)
> **Result:** Drift with SQLite WASM is viable for the web client. OPFS is the target storage; IndexedDB is a fallback.

## Question

Can the Phase 1 schema run unchanged on Drift with SQLite compiled to WASM, with acceptable performance, durability, and memory, including a dictionary-sized full-text index?

## Setup

- Drift 2.35.3, `sqlite3` 3.5.2, Flutter 3.47.8. Web builds use the Drift release `sqlite3.wasm` and `drift_worker.js`, opened through `drift_flutter`, which picks the storage implementation per browser.
- Schema: a subset of Phase 1 (collections, nested decks, per-collection note types, notes, cards, review events, change outbox) with UUIDv7 blob keys, HLC text columns, and tombstone flags. The dictionary is a separate database.
- Study data: 10,000 notes, 20,000 cards, 60,000 review events, 10,000 outbox entries, written in transactions of 1,000 notes.
- Dictionary: Jitendex 2026-10-03, 436,555 entries, imported from the Yomitan term banks. Each row stores headword, reading, sequence, score, and plain-text glosses; the full-content variant also stores the structured glossary JSON. An FTS5 table with the `trigram` tokenizer indexes headword, reading, and glosses.
- Browsers: Chrome 156 (headed), and Chromium 156 and Firefox in Playwright (headless). Each web configuration ran with and without COOP/COEP headers.

## Results

Plain-text glosses unless noted. Headless timings vary considerably between runs; the headed Chrome figures are the reference for web performance.

| | Native (Linux) | Chrome, IndexedDB | Chrome, OPFS | Headless Chromium, IndexedDB | Headless Chromium, OPFS | Firefox, OPFS |
|---|---|---|---|---|---|---|
| Drift implementation | native | `sharedIndexedDb` | `opfsLocks` | `sharedIndexedDb` | `opfsLocks` | `opfsShared` |
| Requires COOP/COEP | — | no | yes | no | yes | no |
| SQLite version | 3.53.4 | 3.54.1 | 3.54.1 | 3.54.1 | 3.54.1 | 3.54.1 |
| FTS5 trigram available | yes | yes | yes | yes | yes | yes |
| Study data writes | 1.6 s | 3.3 s | 3.0 s | 2.8 s | 3.3 s | 3.2–4.5 s |
| Dictionary insert | 5.3 s | 75 s | 38 s | 93–94 s | 159–162 s | 43–57 s |
| FTS rebuild | 3.2 s | 7.4 s | 6.4 s | 5.6–6.5 s | 11.5–15 s | 5.7–6.1 s |
| Dictionary database size | 126 MB | 126 MB | 126 MB | 126 MB | 126 MB | 126 MB |
| Exact, prefix, and trigram lookups | 0.13–0.26 ms | 0.3–0.7 ms | 1.3–2.1 ms | 0.2–0.7 ms | 1.0–1.7 ms | 0.6–1 ms |
| Two-character substring (full scan) | 17–28 ms | 28–48 ms | 32–51 ms | 26–48 ms | 26–45 ms | 26–48 ms |
| Failed transaction leaves no rows | yes | yes | yes | yes | yes | yes |
| Data survives reload | — | yes | yes | yes | yes | yes |
| Two tabs × 500 write transactions | — | — | — | 3.3 s, no errors | 11 s, no errors | 3.4 s, no errors |

### Memory

Headed Chrome, tab process including its workers, after the run: **287 MB** with IndexedDB, **164 MB** with OPFS.

Headless runs, total PSS of the browser processes. Only comparable between headless runs; headless Chromium renders in software, which raises the Flutter baseline.

| | Chromium, IndexedDB | Chromium, OPFS | Firefox, OPFS |
|---|---|---|---|
| Baseline (blank page) | 159 MB | 161 MB | 433 MB |
| Import peak | 1,417 MB | 1,015 MB | 1,352 MB |
| Reopen, settled | 753 MB | 615 MB | 614 MB |
| Reopen minus baseline | 594 MB | 454 MB | 181 MB |
| **Full content:** dictionary size | 654 MB | 654 MB | 654 MB |
| **Full content:** reopen minus baseline | 1,419 MB | not measured | 204 MB |

## Findings

1. **Drift on SQLite WASM works.** The same schema and queries run unchanged on native and web. FTS5 with the trigram tokenizer is available in the WASM build. Transactions roll back completely, data survives reloads, and concurrent writes from two tabs lose nothing.
2. **OPFS is the target storage.** Firefox uses OPFS (`opfsShared`) in all cases. Chromium-based browsers use OPFS (`opfsLocks`) only when the page is cross-origin isolated (COOP/COEP); otherwise Drift falls back to `sharedIndexedDb`.
3. **The IndexedDB fallback holds the whole database in memory.** Memory grows with database size; OPFS memory does not. The fallback works but is unsuitable for full-content dictionaries on memory-constrained devices.
4. **`opfsLocks` adds about 1–2 ms per transaction.** Irrelevant at review pace; bulk operations need large transactions.
5. **Row-by-row dictionary import is slow on the web.** 38–160 s for Jitendex, against 5 s natively, and JSON parsing peaks above 1 GB. Shipping dictionaries as prebuilt SQLite databases turns installation into a file copy on every platform.
6. **Trigram search needs at least three characters.** Two-character substrings fall back to a full scan at 30–50 ms. Exact and prefix lookups, which cover most two-character Japanese words, use B-tree indexes.
7. **Storage is not persistent by default.** All runs reported `navigator.storage.persisted()` as false, so the browser may evict data under storage pressure.
8. **Native and WASM SQLite versions differ** (3.53.4 and 3.54.1).

## Consequences

- Drift is the database access library on all platforms (D9).
- The web app is served with COOP/COEP headers (D25). Cross-origin resources must opt in through CORP or CORS, or the app uses `COEP: credentialless`; sign-in cannot rely on popups under `COOP: same-origin`.
- The web app requests persistent storage and shows a warning when running on the IndexedDB fallback.
- Dictionary packages are proposed as prebuilt SQLite databases (Phase 5a).

## Not covered

- **Safari/WebKit.** Playwright's WebKit build does not run on the test system (Arch Linux). Safari's storage behaviour, including eviction of data for sites unused for seven days, is verified in Phase 12.
- **Quota exhaustion.** Reported quota was about 10 GB in Chromium; behaviour when it runs out was not tested.
- **Mobile browsers.**
