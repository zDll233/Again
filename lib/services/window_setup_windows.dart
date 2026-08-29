import 'package:again/common/paths.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/utils/json_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

/// 视觉验证/截图用: 构建时传 --dart-define=OPAQUE_BG=true 得到不透明背景窗口。
const bool _opaqueBackground = bool.fromEnvironment('OPAQUE_BG');

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
  // 最小窗口尺寸: 放宽到能模拟手机窄屏的尺寸。
  // 布局自适应 (MediaQuery.sizeOf 断点 <600) 会随窗口调整自动切换,
  // 不再需要靠最小尺寸兜底, 保留 320 下限防止窄到无法使用。
  const minimumSize = Size(320, 480);
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    windowManager
      ..setMinimumSize(minimumSize)
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
