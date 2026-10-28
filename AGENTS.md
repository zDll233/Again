# AGENTS.md

Flutter 桌面 (Windows) + Android 本地音声播放器 (ASMR voice works)。**单一 main 分支同时开发两端** (Android 移植已合入 main, 平台差异用运行时守卫隔离, 无 android-port 并行分支)。UI 文本和 commit 消息均为中文 — 保持该风格 (commit 前缀 `bugfix:`/`feat:`/`chore:`)。

## 平台守卫约定 (必读)

跨平台改动的核心约定 — **每个改动必须想清楚它在另一端的表现**:

- 按**能力差异**守卫, 不按平台名字: 布局/断点用 `MediaQuery.sizeOf(context).width < 600` (窄屏), 只有桌面专属能力 (托盘/窗口效果/资源管理器定位/回收站/替换式应用更新) 才用 `Platform.isWindows` (检查更新两端都有, Android 走 APK 安装器)。
- 新增共享 UI 改动时必须写好守卫, 否则一个平台的改动会悄悄影响另一端 (历史教训: 歌词界面重构/悬浮胶囊曾无守卫泄漏到 Windows, 导致面板延伸进播放器、标题左对齐、封面倒影丢失; 修复见 `33c8014`)。
- 服务层用「入口 + 平台实现文件」隔离插件 (例: `lib/services/window_setup.dart` 判断平台, 真正初始化在 `window_setup_windows.dart`)。
- 修改 `lib/` 下 UI/服务文件前, 先检查该改动是否需要 `isNarrow` 或 `Platform.isWindows` 守卫。

## 构建环境 (本机)

- `JAVA_HOME=C:\Program Files\Java\jdk-21.0.10` (JDK 21); `ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk` (本机为 `C:\Users\zdl95\AppData\Local\Android\Sdk`)。Android SDK 组件: platform-tools / platforms;android-36 (AGP 自补 android-35) / build-tools;36.0.0 / cmake;3.22.1。
- `android/local.properties` 的 `sdk.dir` 必须指向真实 SDK 目录 — flutter create 曾误写成 `AppData\Local\Programs` (从 PATH 猜的), 会导致 "CMake not found" 诡异报错。
- 签名: `android/app/upload-keystore.jks` + `android/key.properties` (均 gitignored, 密码在 key.properties 里)。`build.gradle.kts` 无 key.properties 时回退 debug 签名。
- Android CI 签名只用 3 个 secrets: `ANDROID_KEYSTORE_B64` (jks 的 base64) / `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_PASSWORD` (keyAlias 在 workflow 硬编码 `again`, 无 `ANDROID_KEY_ALIAS`)。

## Commands

- `flutter pub get` — `flutter_lyric` is a git dependency (`ref: v0.5.5`), needs network.
- `flutter analyze` — runs flutter_lints + custom_lint (riverpod_lint). Run after edits.
- `dart run build_runner build` — required after editing `lib/services/database/db/database.dart` (drift); `database.g.dart` is generated and committed.
- `flutter test` — unit suite in `test/` (parsing logic, model map round-trips, `scanRoot` + full incremental sync with temp dirs). Run after touching those areas.
- `flutter build windows --release` — release build. CI (tag `v*`, `.github/workflows/windows-release.yml`, Flutter 3.41.3) zips `build/windows/x64/runner/Release/` and injects `APP_VERSION` for the self-updater.
- `flutter build apk --debug|--release` — Android 构建。`flutter build apk --release` 有 key.properties 时正式签名。Android CI: `.github/workflows/android-release.yml` — **`push: tags: 'v*'` 自动触发** (ubuntu-latest, Flutter 3.41.3, APK 发布到 GitHub Release) + `workflow_dispatch` 手动入口 (输入版本号如 v0.5.0); 签名 secrets 已配置, 自 v0.5.1 起已实际跑通。
- 音频引擎冒烟测试 (Windows, 不参与 Flutter 构建): `cmake -S windows/engine_smoke -B build/engine_smoke -G "Visual Studio 17 2022" -A x64 && cmake --build build/engine_smoke --config Release`, 然后 `build/engine_smoke/Release/engine_smoke.exe <音频文件>`。覆盖声道交换字节级校验、加载/播放/进度/seek/暂停/播完/释放; **引擎音量强制 0 静音跑** (测试无声, 听感仍需手动确认)。
- 真机引擎自检 (Android, 临时入口): `flutter build apk --debug --target=tool/engine_probe.dart` → `adb install -r -g build/app/outputs/flutter-apk/app-debug.apk` → 启动后 `adb logcat -d | Select-String PROBE`, 看到 `RESULT: PASS` 即通过。同样全程静音 (生成 6s 立体声 WAV 走 加载/播放/进度/播放中切声道/seek/暂停/resume/release)。**改 Android 播放引擎后必跑** —— 2026-10 就是靠它发现 MediaCodec 输出 ByteBuffer 只读、原地换声道会把解码线程带崩。
- 本机 Android 构建环境: SDK 在 `%LOCALAPPDATA%\Android\Sdk` (`android/local.properties` 的 `sdk.dir`), `cmdline-tools/latest` 必须是 Java 版 sdkmanager (新版 `commandlinetools` 的 `sdkmanager.bat` 会去下载 android-cli 且经常失败); Gradle 走 `~/.gradle/gradle.properties` 里配置的本地代理 (127.0.0.1:7897), 否则 Maven Central 读超时。**debug 构建带 `.dev` 后缀** (`applicationIdSuffix ".dev"`), 与上传密钥签名的正式版共存, 因此 `flutter run -d <device>` 不会覆盖日用的正式版; Manifest 里 Activity 必须写全限定名 `com.zdl.again.MainActivity` (相对名 `.MainActivity` 在 `.dev` 包名下解析不到)。

## Architecture

- Entry: `lib/main.dart` → `setupWindow()` (acrylic/transparent window, hidden title bar, Windows-only) → `MyApp` (`lib/pages/my_app.dart`).
- State: Riverpod (flutter_riverpod). Logic lives in `lib/services/`: `audio/`, `database/`, `ui/presentation/` (notifier/state pairs), `history/`, `key_event/`. UI in `lib/pages/`.
- **播放引擎是自研的** (`lib/services/audio/audio_engine.dart` + 两端原生实现), 不用 audioplayers/just_audio: 「播放中实时对调左右声道」必须拿到解码后的 PCM, 这两个插件都是黑盒解码 + 直接输出, 只暴露整体音量, 没有左右声道路由能力。Dart 侧统一走 `again/audio` MethodChannel (方法: `setSource`/`play`/`pause`/`stop`/`release`/`seek`/`setVolume`/`setChannelSwap`/`status`):
  - Windows: `windows/runner/again_audio_engine.cpp` (Media Foundation Source Reader 解码成设备混音格式 + WASAPI 共享模式输出) + `windows/runner/again_audio_channel.cpp` (频道注册, 在 `flutter_window.cpp` 里创建)。
  - Android: `android/app/src/main/kotlin/com/zdl/again/AgainAudioEngine.kt` (MediaExtractor + MediaCodec 解码 + AudioTrack 输出), 频道在 `MainActivity.configureFlutterEngine` 注册, 引擎是 companion 单例 (Activity 重建不丢播放)。
  - **线程约定**: 所有 COM/MF/WASAPI 调用都在原生音频线程; Flutter 平台线程只读写原子量, `setSource` 立即返回 (loading 通过 `status` 反映), `AudioNotifier` 用 200ms 定时器轮询 `status` 回填 `AudioState` (位置/时长/播放状态/completed)。改引擎时不要改成在平台线程上阻塞等解码器/设备初始化。
  - 左右声道对调 = 输出前按帧交换前两个声道的采样 (`SwapStereoChannels`), 播放中切换立即生效、不断音频; 状态存 `config.json` 的 `channelSwap`。
- Startup (`lib/pages/components/initialization.dart`): 立即应用窗口效果; DB 初始化与窗口位置恢复 (`restoreWindowBounds`) 并行, 然后 load history + 恢复 `sortOrder`/`voiceItemSort`, 再初始化托盘 (Windows, 故意放在首次根目录对话框之后, 避免与文件选择器竞争) / `initAudioServiceAndroid` (Android), 最后 fire-and-forget `silentRefresh` (incremental DB sync so new works appear without a manual refresh).
- Global shortcuts (space, arrows, ctrl+arrows) are handled in `lib/services/key_event/key_event_handler.dart` via `HardwareKeyboard.instance.addHandler` (not the `Shortcuts` widget), registered in `initialization.dart`; they're skipped while a text field has focus (`_isTextInputFocused`) — keep that when adding shortcuts.
- System tray (`lib/services/system_tray.dart`, tray_manager): menu has show / play-pause / prev / next / exit. `setIcon` path is relative to `flutter_assets`, icon lives in `assets/images/app_icon.ico`. Close button / `onWindowClose` hides to tray (`UIService.hideToTray`); real exit is via tray menu → `onExit`.
- Settings page: `lib/pages/settings/settings_page.dart`; reads/writes `config/config.json` through `JsonStorage` (`lib/utils/json_storage.dart`).
- Drift SQLite DB at `data/storage/again_voiceworks.db` — Windows 相对 CWD (从仓库根目录运行), Android 在应用文档目录 (见 `lib/common/paths.dart`)。
- DB refresh (`lib/services/database/voice_updater.dart`): `scanRoot` runs via `compute` in a background isolate and always enumerates audio files; the sync compares scanned item paths against existing DB rows per work and only writes differences. No mtime/signature skipping — Windows dir mtimes don't update on child add/remove, so they can't be trusted for change detection. The DB sync runs in one transaction. FK constraints are ON — deletions must respect order tVoiceCV → tVoiceItem → TVoiceWork → category (TCV 行须在 tVoiceCV 清理后再删). DB schema is at version 3 (v2 加的 `scanSignature` 列已弃用保留; v3 加 4 个索引: `tVoiceItemVoiceWorkPathIndex`/`tVoiceWorkCategoryIndex`/`tVoiceCVVoiceWorkPathIndex`/`tVoiceCVCvNameIndex`; `beforeOpen` 开 FK + WAL)。改 `database.dart` 后跑 `dart run build_runner build`。
- `config/`, `data/`, `history/` are gitignored runtime state. `config/config.json` holds `voiceWorkRoot`, `closeToTray`, `windowEffect` (`transparent`/`acrylic`/`opaque`), `themeSeedColor` (`#RRGGBB`), `searchEnabled` (搜索总开关, 默认关), `searchFilter`/`searchWorks`/`searchTracks` (各面板搜索子开关, 总开关子项, 缺失视为开), `recentColors` (最近使用主题色, 最多 10 个), `rememberWindowPos`/`rememberWindowSize` + `windowBounds` (窗口位置/尺寸记忆), `sortOrder`/`voiceItemSort` (排序持久化; 筛选面板 CV 列表默认标题自然排序, 见 `database_notifier.updateCvList`), `listDensity`, `coverTilt`, `coverReflection`, `channelSwap` (左右声道对调, 见 `AudioNotifier.setChannelSwap`), 滑块类 (`showSliderThumb`/`sliderThickness`/`sliderThumbSize`), 文字(颜色/字号/字重)键 + `hoverTimeColor` (见 `lib/services/ui/theme/text_settings.dart`), `showHoverTime`/`hoverTimeSize`/`showCoverLyric` 等歌词外观键 (见 `lib/services/ui/theme/ui_settings.dart`); legacy `liquidGlass` key 读时经 `resolveWindowEffect` 迁移 (见 `lib/services/ui/theme/theme_provider.dart`), `themeColorMode`/`followCoverTheme` 写时移除; `history/last_played.json` is play-position memory.
- `scripts/delete.ps1` is auto-generated at first run by `lib/utils/generate_script.dart` (only if missing). To change the script, edit the Dart constant, not the file.

## Platform split (Android port)

已完成 (Android 移植, 已合入 main):
- 路径抽象: `lib/common/paths.dart` — Windows 保持 CWD 相对路径, Android 用 path_provider 文档目录 (`config/`/`history/`/`data/` 布局不变)。`JsonStorage` 支持懒路径 (filePath/pathResolver 二选一)。
- 桌面插件隔离: `lib/services/window_setup.dart` (入口, `Platform.isWindows` 守卫) + `window_setup_windows.dart` (真实实现, 唯一持有 flutter_acrylic/window_manager 初始化的文件)。`MoveWindow`/`WindowTitleBar`/设置页在 Android 自动降级 (无标题栏/无窗口设置/无更新入口/无资源管理器按钮)。
- 平台守卫 (运行时, 非条件编译): 托盘 (`initialization.dart` 仅 Windows init)、`UIService.onExit/hideToTray/applyWindowEffect`、`restoreWindowBounds`、`window_size_guard`、`deleteVoiceWork` (Android 直删, 无回收站)、explorer 定位、`file_time.dart` 创建时间 (Android 返回 null, 回退 mtime)、`update_checker.dart` (懒加载 shell32 FFI, `applyUpdate` 仅 Windows)。
- 存储权限: `lib/services/storage_permission.dart` — MANAGE_EXTERNAL_STORAGE (file_picker 11 在 Android 11+ 返回真实路径, 配合全文件权限 dart:io 可直接读写)。
- 后台播放: `lib/services/audio/again_audio_handler.dart` (BaseAudioHandler 桥接, 控制回调转发 AudioNotifier) + `audio_service_sync.dart` (状态镜像到媒体通知) + `initialization.dart` 的 `initAudioServiceAndroid` (AudioService.init 必须在首帧渲染后调用, runApp 前会黑屏)。Manifest 有前台 service/媒体按钮 receiver/FOREGROUND_SERVICE_MEDIA_PLAYBACK; `MainActivity` 必须 `override provideFlutterEngine` 返回 `AudioServicePlugin.getFlutterEngine(context)` (audio_service 共享 engine 的硬性要求), 并注册 `again/installer` MethodChannel (APK 安装, FileProvider) 和自研播放引擎的 `again/audio` 频道 (见 Architecture; 引擎实例是 companion 单例)。
- 生命周期: `initialization.dart` 监听 detached 保存播放历史 (系统杀进程不丢进度)。

真机验证状况:
- 权限申请 → 选根目录 → 全量扫描流程: **已通过** (小米 HyperOS/Android 16; 注意: 权限未授予时 FUSE 对 `.nomedia` 目录隐藏全部文件, 扫描只有目录骨架, 因此选目录前必须先完成「所有文件访问」授权)。
- 后台播放/锁屏控制: 媒体通知/MediaSession/前台服务**已通过**; **音频焦点 (来电) 行为未验证**。
- Android CI (`android-release.yml`): 已实际跑通 (v0.5.1 起, tag 自动触发)。
- 竖屏布局可用性 (filter 默认收起) 未精调。

真机踩坑记录 (小米 HyperOS / Android 16 / Mali GPU):
- **黑屏两连坑**: ① `AudioService.init` 必须在首帧渲染后调用 — runApp 前初始化会让 FlutterView 尺寸停在 0x0 (Dart 正常、日志正常、0 帧渲染); ② MainActivity 必须 `override provideFlutterEngine` 返回 `AudioServicePlugin.getFlutterEngine(context)`, 否则 audio_service 报 "Activity class wrong or has not provided the correct FlutterEngine"。
- **MCPToolkit 仅 Windows debug**: Android 上初始化疑会阻塞首帧, `main.dart` 已限定 `kDebugMode && Platform.isWindows`。
- **设备渲染**: 该设备需开发者选项关闭「HW 叠加层」(`settings put global disable_hw_overlays 1`), 否则 Flutter 应用 (含官方 hello world) 黑屏; Impeller/Skia 都受影响, 是设备 ROM 问题非 app 问题。
- **adb 调试坑**: PowerShell 重定向会破坏二进制 (截图/DB 拉取必须 `cmd /c "adb exec-out ... > file"`); 中文路径参数经 PowerShell → adb 会编码损坏 (用不带中文参数的命令或 find 验证)。

## Domain conventions (from README.md)

- Voice works live under `root/category/<name>/`; folder name format is `cv1&cv2&...&cvN-title`. First subdirectory name = sourceId (regex `^(RJ|VJ|BJ)?\d+$`, uppercased); first image in the work folder = cover.
- Lyric files: same-named `.lrc`/`.webvtt` next to the audio file (also `audio.mp3.lrc` style); supported since a bugfix handling >100min lrc, uppercase extensions, and webvtt.
- File/folder operations go to the Recycle Bin via the generated PowerShell script, not hard delete.

## Quirks

- App is Windows-first; desktop-only plugins are listed in the Platform split above — before touching them, check whether the change must stay Windows-only or needs an Android fallback. **单一 main 分支开发两端**: 共享 UI/服务改动直接提交 main, 平台差异用守卫隔离 (见顶部「平台守卫约定」); release tag 一律打在 main, CI 会校验 tag 归属 (防止误从平台分支发布)。
- `--dart-define=OPAQUE_BG=true` builds an opaque window instead of transparent/acrylic — used for screenshots/visual verification (`lib/services/window_setup_windows.dart`, `lib/services/ui/ui_service.dart`, `lib/pages/my_app.dart`).
- Debug and release builds must NOT run simultaneously — the second instance crashes at startup (exit code 1). Kill the release app before `flutter run -d windows --debug`.
- Flutter MCP debugging (`flutter-mcp-toolkit`): server binary at `C:\Users\lzd\flutter-mcp-toolkit\fmtk-server.exe`, registered in `opencode.json`, `mcp_toolkit` initialized in `lib/main.dart` under `kDebugMode` — **must stay debug-only: in release builds it makes the window start minimized**. To debug: kill release instance → `flutter run -d windows --debug` → grab the VM service URI from the run log → use the `fmt_*` tools. Note: app view DPR is 1.5 on this machine — screenshots/coordinates must account for it. Screenshot capture needs an in-app permission bridge (not installed).
- `custom_lint.log` at repo root is analyzer-plugin noise (gitignored); ignore it.
- **已知未修问题: 窗口内容偶发缩到窗口一角** — Flutter Windows 引擎的 view 尺寸偶发与窗口不同步 (窗口物理 1560x1035 时 view 停在 1252x967, 内容渲染在角落, 其余区域空白; 用户截图表现为"整体画面缩到左下角")。无法稳定复现 (程序化 SetWindowPos/最大化/还原均正常同步), 反复出现。`windows/runner/main.cpp` 的 DPI 注释提到同类根因 ("breaks the engine's initial DPI and makes window size/content misplaced")。当前方案: `lib/services/window_size_guard.dart` — 启动后 2 秒 (渲染稳定) 检查一次窗口尺寸×DPR 与 view 尺寸, 偏差时先 +1px 再恢复强制 resize 自愈 (一次性, 不做周期轮询; 原周期版 `f3554bf` 引入/`90e770a` 降频/`62b354e` 移除, 现按用户要求恢复为一次性)。
- 液态玻璃效果 (`lib/pages/components/liquid_glass.dart`, 克制式: 极淡半透明着色 + 顶部 1px 亮边 + 底部 2px 收边; 设置页 `windowEffect` 三档: 透明/毛玻璃/不透明): 模糊效果靠 **系统级 acrylic 窗口效果** (`UIService.applyWindowEffect`), 组件内**不要**用 BackdropFilter (Windows 透明窗口拿不到桌面背景, 会渲染失败); 背景层必须用 `Positioned.fill` 而非 `StackFit.expand`, 后者在无限高度约束下崩溃 (`BoxConstraints forces an infinite height`)。面板 `voice_panel` 用 `tintAlpha 0.14`(毛玻璃)/`0.35`、圆角 12, 宽屏播放器贴底无圆角 (`showTopHighlight:false`), 胶囊见 `player_widget._buildNarrow`。**注意**: 2026-09 有一份「iOS 26 式强玻璃」(rim/环境光/elevated/blur/tintColor + dialogTheme/popupMenuTheme 玻璃化) 的重写改稿, 因观感变化过大已回退, 备份在 `%TEMP%\again_glass_wip_files\` 与 `%TEMP%\again_liquid_glass_wip.patch` (未提交, 需要时再评估)。
