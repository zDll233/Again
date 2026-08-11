# AGENTS.md

Windows-only Flutter desktop app: local audio player for ASMR voice works. UI text and commit messages are Chinese — keep that style (commit prefixes like `bugfix:`/`feat:`/`chore:`).

## Commands

- `flutter pub get` — `flutter_lyric` is a git dependency, needs network.
- `flutter analyze` — runs flutter_lints + custom_lint (riverpod_lint). Run after edits.
- `dart run build_runner build` — required after editing `lib/services/database/db/database.dart` (drift); `database.g.dart` is generated and committed.
- `flutter build windows --release` — release build. CI (tag `v*`, `.github/workflows/windows-release.yml`, Flutter 3.41.3) zips `build/windows/x64/runner/Release/`.
- `flutter test` — small unit suite in `test/` (parsing logic, model map round-trips, `scanRoot` with temp dirs). Run after touching those areas.

## Architecture

- Entry: `lib/main.dart` → `setupWindow()` (acrylic/transparent window, hidden title bar, Windows-only) → `MyApp` (`lib/pages/my_app.dart`).
- State: Riverpod (flutter_riverpod). Logic lives in `lib/services/`: `audio/`, `database/`, `ui/presentation/` (notifier/state pairs), `history/`, `key_event/`. UI in `lib/pages/`.
- Startup (`lib/pages/components/initialization.dart`): init system tray (`lib/services/system_tray.dart`, tray_manager — setIcon path is relative to `flutter_assets`, icon lives in `assets/images/app_icon.ico`), init DB, load history, then a fire-and-forget `silentRefresh` (incremental DB sync so new works appear without a manual refresh).
- Close button / `onWindowClose` hides to tray (`UIService.hideToTray`); real exit is via tray menu → `onExit`.
- Drift SQLite DB at relative path `data/storage/again_voiceworks.db` — relative to CWD, so run the app from the repo root.
- DB refresh (`lib/services/database/voice_updater.dart`): `scanRoot` runs via `compute` in a background isolate and always enumerates audio files; the sync compares scanned item paths against existing DB rows per work and only writes differences. No mtime/signature skipping — Windows dir mtimes don't update on child add/remove, so they can't be trusted for change detection. The DB sync runs in one transaction. FK constraints are ON — deletions must respect order tVoiceCV → tVoiceItem → TVoiceWork → category. DB schema is at version 2 (legacy `scanSignature` column, unused; run `dart run build_runner build` after editing `database.dart`).
- `config/`, `data/`, `history/` are gitignored runtime state. `config/config.json` holds the scanned voice-work root dir; `history/last_played.json` is play-position memory.
- `scripts/delete.ps1` is auto-generated at first run by `lib/utils/generate_script.dart` (only if missing). To change the script, edit the Dart constant, not the file.

## Domain conventions (from README.md)

- Voice works live under `root/category/<name>/`; folder name format is `cv1&cv2&...&cvN-title`. First subdirectory name = sourceId; first image in the work folder = cover.
- Lyric files: same-named `.lrc`/`.webvtt` next to the audio file (also `audio.mp3.lrc` style); supported since a bugfix handling >100min lrc, uppercase extensions, and webvtt.
- File/folder operations go to the Recycle Bin via the generated PowerShell script, not hard delete.

## Quirks

- App is Windows-only (flutter_acrylic, window_manager, audioplayers); don't plan for other platforms.
- `custom_lint.log` at repo root is analyzer-plugin noise (gitignored); ignore it.
