# AGENTS.md

Flutter 桌面 + Android 本地音声播放器 (ASMR voice works)。**Android 移植在 `android-port` 分支** (基于 main 分叉, 含桌面插件隔离等改造; main 保持 Windows 主开发线)。UI 文本和 commit 消息均为中文 — 保持该风格 (commit 前缀 `bugfix:`/`feat:`/`chore:`)。

## 构建环境 (本机)

- `JAVA_HOME=C:\Users\lzd\AndroidDev\jdk17\jdk-17.0.20+8`, `ANDROID_HOME=C:\Users\lzd\AndroidDev\sdk` (已写入用户环境变量; 新终端可用)。Android SDK 组件: platform-tools / platforms;android-36 / build-tools;36.0.0 / cmake;3.22.1。
- `android/local.properties` 的 `sdk.dir` 必须指向 `C:\Users\lzd\AndroidDev\sdk` — flutter create 曾误写成 `AppData\Local\Programs` (从 PATH 猜的), 会导致 "CMake not found" 诡异报错。
- 签名: `android/app/upload-keystore.jks` + `android/key.properties` (均 gitignored, 密码在 key.properties 里)。`build.gradle.kts` 无 key.properties 时回退 debug 签名。
- Android 打包用 CI 需要 4 个 secrets: `ANDROID_KEYSTORE_B64` (jks 的 base64) / `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` / `ANDROID_KEY_ALIAS` (again)。

## Commands

- `flutter pub get` — `flutter_lyric` is a git dependency, needs network.
- `flutter analyze` — runs flutter_lints + custom_lint (riverpod_lint). Run after edits.
- `dart run build_runner build` — required after editing `lib/services/database/db/database.dart` (drift); `database.g.dart` is generated and committed.
- `flutter test` — unit suite in `test/` (parsing logic, model map round-trips, `scanRoot` + full incremental sync with temp dirs). Run after touching those areas.
- `flutter build windows --release` — release build. CI (tag `v*`, `.github/workflows/windows-release.yml`, Flutter 3.41.3) zips `build/windows/x64/runner/Release/` and injects `APP_VERSION` for the self-updater.
- `flutter build apk --debug|--release` — Android build (android-port 分支)。`flutter build apk --release` 有 key.properties 时正式签名。Android CI: `.github/workflows/android-release.yml` (tag 触发出 APK, 4 个 secrets)。

## Architecture

- Entry: `lib/main.dart` → `setupWindow()` (acrylic/transparent window, hidden title bar, Windows-only) → `MyApp` (`lib/pages/my_app.dart`).
- State: Riverpod (flutter_riverpod). Logic lives in `lib/services/`: `audio/`, `database/`, `ui/presentation/` (notifier/state pairs), `history/`, `key_event/`. UI in `lib/pages/`.
- Startup (`lib/pages/components/initialization.dart`): init DB, load history, then init system tray — deliberately after the first-run root-dir dialog, which must not race with the file picker — then a fire-and-forget `silentRefresh` (incremental DB sync so new works appear without a manual refresh).
- Global shortcuts (space, arrows, ctrl+arrows) are handled in `lib/services/key_event/key_event_handler.dart` via `HardwareKeyboard.instance.addHandler` (not the `Shortcuts` widget), registered in `initialization.dart`; they're skipped while a text field has focus (`_isTextInputFocused`) — keep that when adding shortcuts.
- System tray (`lib/services/system_tray.dart`, tray_manager): menu has show / play-pause / prev / next / exit. `setIcon` path is relative to `flutter_assets`, icon lives in `assets/images/app_icon.ico`. Close button / `onWindowClose` hides to tray (`UIService.hideToTray`); real exit is via tray menu → `onExit`.
- Settings page: `lib/pages/settings/settings_page.dart`; reads/writes `config/config.json` through `JsonStorage` (`lib/utils/json_storage.dart`).
- Drift SQLite DB at relative path `data/storage/again_voiceworks.db` — relative to CWD, so run the app from the repo root.
- DB refresh (`lib/services/database/voice_updater.dart`): `scanRoot` runs via `compute` in a background isolate and always enumerates audio files; the sync compares scanned item paths against existing DB rows per work and only writes differences. No mtime/signature skipping — Windows dir mtimes don't update on child add/remove, so they can't be trusted for change detection. The DB sync runs in one transaction. FK constraints are ON — deletions must respect order tVoiceCV → tVoiceItem → TVoiceWork → category. DB schema is at version 2 (legacy `scanSignature` column, unused; run `dart run build_runner build` after editing `database.dart`).
- `config/`, `data/`, `history/` are gitignored runtime state. `config/config.json` holds `voiceWorkRoot`, `closeToTray`, `windowEffect` (`transparent`/`acrylic`/`opaque`), `themeSeedColor` (`#RRGGBB`), `textColorMode` (`follow`/`custom`), `textColor` (`#RRGGBB`), `searchEnabled` (搜索总开关), `searchFilter`/`searchWorks`/`searchTracks` (各面板搜索子开关, 总开关子项, 缺失视为开), `recentColors` (最近使用主题色, 最多 10 个); legacy `liquidGlass`/`followCoverTheme`/`themeColorMode`/`accentColorMode`/`accentColor` keys are auto-migrated on read (`resolveWindowEffect`/`resolveTextColorMode`/`resolveTextColorHex` in `lib/services/ui/theme/theme_provider.dart`) and removed on write; `history/last_played.json` is play-position memory.
- `scripts/delete.ps1` is auto-generated at first run by `lib/utils/generate_script.dart` (only if missing). To change the script, edit the Dart constant, not the file.

## Platform split (Android port)

已完成 (android-port 分支):
- 路径抽象: `lib/common/paths.dart` — Windows 保持 CWD 相对路径, Android 用 path_provider 文档目录 (`config/`/`history/`/`data/` 布局不变)。`JsonStorage` 支持懒路径 (filePath/pathResolver 二选一)。
- 桌面插件隔离: `lib/services/window_setup.dart` (入口, `Platform.isWindows` 守卫) + `window_setup_windows.dart` (真实实现, 唯一持有 flutter_acrylic/window_manager 初始化的文件)。`MoveWindow`/`WindowTitleBar`/设置页在 Android 自动降级 (无标题栏/无窗口设置/无更新入口/无资源管理器按钮)。
- 平台守卫 (运行时, 非条件编译): 托盘 (`initialization.dart` 仅 Windows init)、`UIService.onExit/hideToTray/applyWindowEffect`、`restoreWindowBounds`、`window_size_guard`、`deleteVoiceWork` (Android 直删, 无回收站)、explorer 定位、`file_time.dart` 创建时间 (Android 返回 null, 回退 mtime)、`update_checker.dart` (懒加载 shell32 FFI, `applyUpdate` 仅 Windows)。
- 存储权限: `lib/services/storage_permission.dart` — MANAGE_EXTERNAL_STORAGE (file_picker 11 在 Android 11+ 返回真实路径, 配合全文件权限 dart:io 可直接读写)。
- 后台播放: `lib/services/audio/again_audio_handler.dart` (BaseAudioHandler 桥接, 控制回调转发 AudioNotifier) + `audio_service_sync.dart` (状态镜像到媒体通知) + `main.dart` AudioService.init (仅 Android)。Manifest 有前台 service/媒体按钮 receiver/FOREGROUND_SERVICE_MEDIA_PLAYBACK。
- 生命周期: `initialization.dart` 监听 detached 保存播放历史 (系统杀进程不丢进度)。

未验证 (需要真机):
- 权限申请 → 选根目录 → 全量扫描流程 (file_picker 目录选择在部分厂商 ROM 可能返回不可读路径, 兜底是手动输入路径)。
- 后台播放/锁屏控制/音频焦点 (来电) 行为。
- 竖屏布局可用性 (filter 默认收起, 不精调)。
- CI (`android-release.yml`) 未实际跑过 (需要配 4 个 secrets)。

## Domain conventions (from README.md)

- Voice works live under `root/category/<name>/`; folder name format is `cv1&cv2&...&cvN-title`. First subdirectory name = sourceId (regex `^(RJ|VJ|BJ)?\d+$`, uppercased); first image in the work folder = cover.
- Lyric files: same-named `.lrc`/`.webvtt` next to the audio file (also `audio.mp3.lrc` style); supported since a bugfix handling >100min lrc, uppercase extensions, and webvtt.
- File/folder operations go to the Recycle Bin via the generated PowerShell script, not hard delete.

## Quirks

- App is Windows-first; desktop-only plugins are listed in the Platform split above — before touching them, check whether the change must stay Windows-only or needs an Android fallback. 移植相关改动只提交到 `android-port` 分支, main 保持 Windows 开发线 (用户会在 main 并行提交功能 — 改动前先 fetch 并 merge main)。
- `--dart-define=OPAQUE_BG=true` builds an opaque window instead of transparent/acrylic — used for screenshots/visual verification (`lib/main.dart`, `lib/pages/my_app.dart`).
- Debug and release builds must NOT run simultaneously — the second instance crashes at startup (exit code 1). Kill the release app before `flutter run -d windows --debug`.
- Flutter MCP debugging (`flutter-mcp-toolkit`): server binary at `C:\Users\lzd\flutter-mcp-toolkit\fmtk-server.exe`, registered in `opencode.json`, `mcp_toolkit` initialized in `lib/main.dart` under `kDebugMode` — **must stay debug-only: in release builds it makes the window start minimized**. To debug: kill release instance → `flutter run -d windows --debug` → grab the VM service URI from the run log → use the `fmt_*` tools. Note: app view DPR is 1.5 on this machine — screenshots/coordinates must account for it. Screenshot capture needs an in-app permission bridge (not installed). Debug apps may crash on their own (audioplayers posts events from a non-platform thread — pre-existing bug).
- `custom_lint.log` at repo root is analyzer-plugin noise (gitignored); ignore it.
- **已知未修问题: 窗口内容偶发缩到窗口一角** — Flutter Windows 引擎的 view 尺寸偶发与窗口不同步 (窗口物理 1560x1035 时 view 停在 1252x967, 内容渲染在角落, 其余区域空白; 用户截图表现为"整体画面缩到左下角")。无法稳定复现 (程序化 SetWindowPos/最大化/还原均正常同步), 反复出现。`windows/runner/main.cpp` 的 DPI 注释提到同类根因 ("breaks the engine's initial DPI and makes window size/content misplaced")。当前方案: `lib/services/window_size_guard.dart` — 启动后 2 秒 (渲染稳定) 检查一次窗口尺寸×DPR 与 view 尺寸, 偏差时先 +1px 再恢复强制 resize 自愈 (一次性, 不做周期轮询; 原周期版 `f3554bf` 引入/`90e770a` 降频/`62b354e` 移除, 现按用户要求恢复为一次性)。
- 亚克力毛玻璃效果 (`lib/pages/components/liquid_glass.dart`, 设置页 `windowEffect` 三档: 透明/毛玻璃/不透明, 实为 acrylic 毛玻璃而非液态玻璃): 背景模糊靠 **系统级 acrylic 窗口效果** (`UIService.applyWindowEffect`), 不要用 `BackdropFilter` — Windows 透明窗口上它拿不到桌面背景, 会渲染失败; LiquidGlass 的背景层必须用 `Positioned.fill` 而非 `StackFit.expand`, 后者在无限高度约束下崩溃 (`BoxConstraints forces an infinite height`)。面板/播放器在三种窗口效果下都统一使用 LiquidGlass 表面 (高亮细边), 仅着色深度不同。
