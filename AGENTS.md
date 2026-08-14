# AGENTS.md

Windows-only Flutter desktop app: local audio player for ASMR voice works. UI text and commit messages are Chinese — keep that style (commit prefixes like `bugfix:`/`feat:`/`chore:`).

## Commands

- `flutter pub get` — `flutter_lyric` is a git dependency, needs network.
- `flutter analyze` — runs flutter_lints + custom_lint (riverpod_lint). Run after edits.
- `dart run build_runner build` — required after editing `lib/services/database/db/database.dart` (drift); `database.g.dart` is generated and committed.
- `flutter test` — unit suite in `test/` (parsing logic, model map round-trips, `scanRoot` + full incremental sync with temp dirs). Run after touching those areas.
- `flutter build windows --release` — release build. CI (tag `v*`, `.github/workflows/windows-release.yml`, Flutter 3.41.3) zips `build/windows/x64/runner/Release/`.
- 撤销提交按场景选: 未推送的本地提交用 `git reset --hard` (不留历史, 干净); 已推送/公共分支用 `git revert` (保留历史, 需审计)。

## Architecture

- Entry: `lib/main.dart` → `setupWindow()` (acrylic/transparent window, hidden title bar, Windows-only) → `MyApp` (`lib/pages/my_app.dart`).
- State: Riverpod (flutter_riverpod). Logic lives in `lib/services/`: `audio/`, `database/`, `ui/presentation/` (notifier/state pairs), `history/`, `key_event/`. UI in `lib/pages/`.
- Startup (`lib/pages/components/initialization.dart`): init DB, load history, then init system tray — deliberately after the first-run root-dir dialog, which must not race with the file picker — then a fire-and-forget `silentRefresh` (incremental DB sync so new works appear without a manual refresh).
- Global shortcuts (space, arrows, ctrl+arrows) are handled in `lib/services/key_event/key_event_handler.dart` via `HardwareKeyboard.instance.addHandler` (not the `Shortcuts` widget), registered in `initialization.dart`; they're skipped while a text field has focus (`_isTextInputFocused`) — keep that when adding shortcuts.
- System tray (`lib/services/system_tray.dart`, tray_manager): menu has show / play-pause / prev / next / exit. `setIcon` path is relative to `flutter_assets`, icon lives in `assets/images/app_icon.ico`. Close button / `onWindowClose` hides to tray (`UIService.hideToTray`); real exit is via tray menu → `onExit`.
- Settings page: `lib/pages/settings/settings_page.dart`; reads/writes `config/config.json` through `JsonStorage` (`lib/utils/json_storage.dart`).
- Drift SQLite DB at relative path `data/storage/again_voiceworks.db` — relative to CWD, so run the app from the repo root.
- DB refresh (`lib/services/database/voice_updater.dart`): `scanRoot` runs via `compute` in a background isolate and always enumerates audio files; the sync compares scanned item paths against existing DB rows per work and only writes differences. No mtime/signature skipping — Windows dir mtimes don't update on child add/remove, so they can't be trusted for change detection. The DB sync runs in one transaction. FK constraints are ON — deletions must respect order tVoiceCV → tVoiceItem → TVoiceWork → category. DB schema is at version 2 (legacy `scanSignature` column, unused; run `dart run build_runner build` after editing `database.dart`).
- `config/`, `data/`, `history/` are gitignored runtime state. `config/config.json` holds `voiceWorkRoot`, `closeToTray`, `windowEffect` (`transparent`/`acrylic`/`opaque`), `themeSeedColor` (`#RRGGBB`), `textColorMode` (`follow`/`custom`), `textColor` (`#RRGGBB`), `searchEnabled`, `recentColors` (最近使用主题色, 最多 10 个); legacy `liquidGlass`/`followCoverTheme`/`themeColorMode`/`accentColorMode`/`accentColor` keys are auto-migrated on read (`resolveWindowEffect`/`resolveTextColorMode`/`resolveTextColorHex` in `lib/services/ui/theme/theme_provider.dart`) and removed on write; `history/last_played.json` is play-position memory.
- `scripts/delete.ps1` is auto-generated at first run by `lib/utils/generate_script.dart` (only if missing). To change the script, edit the Dart constant, not the file.

## Domain conventions (from README.md)

- Voice works live under `root/category/<name>/`; folder name format is `cv1&cv2&...&cvN-title`. First subdirectory name = sourceId (regex `^(RJ|VJ|BJ)?\d+$`, uppercased); first image in the work folder = cover.
- Lyric files: same-named `.lrc`/`.webvtt` next to the audio file (also `audio.mp3.lrc` style); supported since a bugfix handling >100min lrc, uppercase extensions, and webvtt.
- File/folder operations go to the Recycle Bin via the generated PowerShell script, not hard delete.

## Quirks

- App is Windows-only (flutter_acrylic, window_manager, audioplayers); don't plan for other platforms.
- `--dart-define=OPAQUE_BG=true` builds an opaque window instead of transparent/acrylic — used for screenshots/visual verification (`lib/main.dart`, `lib/pages/my_app.dart`).
- Debug and release builds must NOT run simultaneously — the second instance crashes at startup (exit code 1). Kill the release app before `flutter run -d windows --debug`.
- Flutter MCP debugging (`flutter-mcp-toolkit`): server binary at `C:\Users\lzd\flutter-mcp-toolkit\fmtk-server.exe`, registered in `opencode.json`, `mcp_toolkit` initialized in `lib/main.dart` under `kDebugMode` — **must stay debug-only: in release builds it makes the window start minimized**. To debug: kill release instance → `flutter run -d windows --debug` → grab the VM service URI from the run log → use the `fmt_*` tools. Note: app view DPR is 1.5 on this machine — screenshots/coordinates must account for it. Screenshot capture needs an in-app permission bridge (not installed). Debug apps may crash on their own (audioplayers posts events from a non-platform thread — pre-existing bug).
- `custom_lint.log` at repo root is analyzer-plugin noise (gitignored); ignore it.
- **已知未修问题: 窗口内容偶发缩到窗口一角** — Flutter Windows 引擎的 view 尺寸偶发与窗口不同步 (窗口物理 1560x1035 时 view 停在 1252x967, 内容渲染在角落, 其余区域空白; 用户截图表现为"整体画面缩到左下角")。无法稳定复现 (程序化 SetWindowPos/最大化/还原均正常同步), 反复出现。`windows/runner/main.cpp` 的 DPI 注释提到同类根因 ("breaks the engine's initial DPI and makes window size/content misplaced")。曾加 `WindowSizeGuard` (10s 周期对比窗口尺寸×DPR 与 view 尺寸, 偏差时强制 resize 自愈) 验证可行, 但用户嫌臃肿已移除 (commit `f3554bf` 引入, `90e770a` 降频, 后又移除)。如需复修, 恢复该守卫或升级 Flutter 后验证是否消失。
- 亚克力毛玻璃效果 (`lib/pages/components/liquid_glass.dart`, 设置页 `windowEffect` 三档: 透明/毛玻璃/不透明, 实为 acrylic 毛玻璃而非液态玻璃): 背景模糊靠 **系统级 acrylic 窗口效果** (`UIService.applyWindowEffect`), 不要用 `BackdropFilter` — Windows 透明窗口上它拿不到桌面背景, 会渲染失败; LiquidGlass 的背景层必须用 `Positioned.fill` 而非 `StackFit.expand`, 后者在无限高度约束下崩溃 (`BoxConstraints forces an infinite height`)。面板/播放器在三种窗口效果下都统一使用 LiquidGlass 表面 (高亮细边), 仅着色深度不同。
