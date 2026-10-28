# Browser storage spike (Phase 1, #17)

Throwaway app that runs a representative subset of the Phase 1 schema on Drift,
natively and in browsers, with Jitendex as a dictionary-sized index. Results are
recorded in `docs/spikes/browser-storage.md` on `main`.

Not maintained and not part of the build.

## Setup

Download and extract Jitendex (Yomitan format) outside the repository:

```sh
curl -LO https://github.com/stephenmk/stephenmk.github.io/releases/latest/download/jitendex-yomitan.zip
unzip jitendex-yomitan.zip -d <jitendex dir>
fvm flutter pub get
```

`web/sqlite3.wasm` and `web/drift_worker.js` are the Drift 2.35.3 release assets.

## Native

```sh
fvm dart run bin/native_bench.dart <jitendex dir> <out dir> [--content]
```

## Web

```sh
fvm flutter build web
python3 serve.py 8790 <jitendex dir>             # default headers
python3 serve.py 8791 <jitendex dir> --isolate   # COOP/COEP headers
```

Open `http://localhost:8790/?phase=full` (see `lib/main.dart` for parameters). Results
are logged to the console as `SPIKE_RESULT <json>`.

`tool/drive.py` (full run, reload, two tabs) and `tool/drive_mem.py` (memory) drive
the same pages with Playwright:

```sh
python3 tool/drive.py <chromium|firefox|webkit> <port> [banks] [content]
python3 tool/drive_mem.py <chromium|firefox> <port> <content 0|1>
```
