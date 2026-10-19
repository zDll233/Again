import 'package:again/common/paths.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/utils/json_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

/// 视觉验证/截图用: 构建时传 --dart-define=OPAQUE_BG=true 得到不透明背景窗口。
const bool _opaqueBackground = bool.fromEnvironment('OPAQUE_BG');

/// 调试用最小窗口解锁: 允许把窗口缩到手机窄屏尺寸 (窄屏断点 <600) 以便
/// 本地模拟移动端布局。正式发布不生效:
/// - flutter run 调试构建 (kDebugMode) 自动解锁;
/// - 本地 release 构建传 --dart-define=MIN_WINDOW_UNLOCK=true 解锁 (如 _build.bat);
/// - CI/正式发布不传该 define, 保持 1040x690 原限制。
const bool _minWindowUnlock =
    bool.fromEnvironment('MIN_WINDOW_UNLOCK') || kDebugMode;

/// Windows 专属窗口初始化 (由 [setupWindow] 在 Windows 平台调用)。
Future<void> setupWindowWindows() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for window acrylic, mica or transparency effects
  await Window.initialize();
  if (!_opaqueBackground) {
    Window.setEffect(
      effect: WindowEffect.transparent,
      color: const Color(0xCC222222),
    );
  }

  const initialSize = Size(1040, 690);
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    // 去掉原生系统菜单/标题栏按钮 (最小化/最大化/关闭) — 本应用标题栏是
    // Flutter 自绘的 CaptionButtons, 原生按钮在最大化时会被 DWM 画进客户区
    // 右上角, 与自绘按钮重叠成两套图标。
    // 顺序不能反: hideWindowControls 只改 GWL_STYLE 位不重画, 必须紧接着由
    // setTitleBarStyle 内部的 SetWindowPos(SWP_FRAMECHANGED) 让 DWM 重算
    // 非客户区; 反过来写则要等下一次窗口尺寸变化才生效。
    await Window.hideWindowControls();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

    windowManager
      // 正式版保持初始尺寸下限; 调试场景见上方 _minWindowUnlock 说明
      ..setMinimumSize(_minWindowUnlock ? const Size(320, 480) : initialSize)
      ..setTitle('Again')
      ..setPreventClose(true);
    // 窗口显示前应用配置的窗口背景效果
    final config = await JsonStorage(filePath: await configFilePath()).read();
    final effect = resolveWindowEffect(config);
    await applyWindowEffectStandalone(effect);
    windowManager.show();
    // DWM 在窗口可见并首次绘制后才真正合成 backdrop (SYSTEMBACKDROP_TYPE),
    // 显示后立即重设一次, 消除启动时几十 ms 的延迟
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      applyWindowEffectStandalone(effect);
    });
  });
}
