// dart:ffi 的 Size 与 dart:ui 的 Size 撞名, 窗口尺寸要用后者
import 'dart:ffi' hide Size;

import 'package:again/common/paths.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/utils/json_storage.dart';
import 'package:again/utils/log.dart';
import 'package:ffi/ffi.dart';
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

// ---------------------------------------------------------------------------
// DWM 残留清理: 修复「亚克力 → 透明」切换后窗口上边界 1px 亮边
// ---------------------------------------------------------------------------

/// 顶层窗口类名 (同 windows/runner/win32_window.cpp 的 kWindowClassName,
/// main.cpp 的单实例检查也用它, 全进程唯一)。
const String _kWindowClassName = 'FLUTTER_RUNNER_WIN32_WINDOW';

/// DWMWA_SYSTEMBACKDROP_TYPE: Win11 22H2+ 的系统背景材质 (mica/acrylic)
const int _kDwmwaSystemBackdropType = 38;

/// DWMWA_MICA_EFFECT: Win11 21H2 的 mica 开关 (兜底关闭用)
const int _kDwmwaMicaEffect = 1029;

/// DWMSBT_NONE: 关闭系统背景材质
const int _kDwmsbtNone = 1;

final class _DwmMargins extends Struct {
  @Int32()
  external int cxLeftWidth;
  @Int32()
  external int cxRightWidth;
  @Int32()
  external int cyTopHeight;
  @Int32()
  external int cyBottomHeight;
}

typedef _DwmSetWindowAttributeNative = Int32 Function(
    IntPtr hwnd, Uint32 attribute, Pointer<Void> value, Uint32 size);
typedef _DwmSetWindowAttributeDart = int Function(
    int hwnd, int attribute, Pointer<Void> value, int size);

typedef _DwmExtendFrameIntoClientAreaNative = Int32 Function(
    IntPtr hwnd, Pointer<_DwmMargins> margins);
typedef _DwmExtendFrameIntoClientAreaDart = int Function(
    int hwnd, Pointer<_DwmMargins> margins);

typedef _FindWindowNative = IntPtr Function(
    Pointer<Utf16> className, Pointer<Utf16> windowName);
typedef _FindWindowDart = int Function(
    Pointer<Utf16> className, Pointer<Utf16> windowName);

// 顶层 final 惰性初始化: 只有 Windows 上真正调用时才加载 DLL
DynamicLibrary? _dwmapi;
DynamicLibrary? _user32;

DynamicLibrary get _dwmapiLib => _dwmapi ??= DynamicLibrary.open('dwmapi.dll');
DynamicLibrary get _user32Lib => _user32 ??= DynamicLibrary.open('user32.dll');

final _DwmSetWindowAttributeDart _dwmSetWindowAttribute = _dwmapiLib
    .lookupFunction<_DwmSetWindowAttributeNative, _DwmSetWindowAttributeDart>(
        'DwmSetWindowAttribute');
final _DwmExtendFrameIntoClientAreaDart _dwmExtendFrameIntoClientArea =
    _dwmapiLib.lookupFunction<_DwmExtendFrameIntoClientAreaNative,
        _DwmExtendFrameIntoClientAreaDart>('DwmExtendFrameIntoClientArea');
final _FindWindowDart _findWindowW =
    _user32Lib.lookupFunction<_FindWindowNative, _FindWindowDart>(
        'FindWindowW');

/// 归零 DWM 的 frame 扩展、系统背景材质与深色边框标记, 让窗口回到「冷启动
/// 直接应用该效果」时的状态。仅透明/不透明效果需要调用 (亚克力本身就要
/// frame 扩展与材质)。
///
/// 根因: flutter_acrylic 1.1.4 从亚克力 (WindowEffect index 4) 切走时进
/// 「恢复原窗口样式」分支, 做了三件事:
/// 1. 把 DwmExtendFrameIntoClientArea 的 MARGINS 设成 {0, 0, 1, 0} —— 顶部
///    留 1px 玻璃 frame 以保住 DWM 窗口阴影; 这 1px 在透明窗口上会被渲染成
///    一条**纯白线** (实测 #FFFFFF), 就是用户看到的「上边界亮边」;
/// 2. 只关了旧的 mica 开关, 没有清 Win11 的 DWMWA_SYSTEMBACKDROP_TYPE;
/// 3. 把 DWMWA_USE_IMMERSIVE_DARK_MODE 置成 FALSE (那是切走 mica 才需要的),
///    深色系统上窗口 1px 边框会因此改按浅色主题绘制, 比冷启动亮一档。
/// 冷启动时前一个效果为空、不经过该分支, 所以表现为「切换后顶部有亮边,
/// 重启就消失」。这里把三项都恢复, 实测与冷启动画面逐像素一致。
Future<void> resetBackdropResidue() async {
  try {
    final hwnd = _mainWindowHandle();
    if (hwnd == 0) {
      Log.debug('resetBackdropResidue: 未找到顶层窗口, 跳过');
      return;
    }
    // 1) frame 扩展归零 (亮边的直接来源)
    final margins = calloc<_DwmMargins>();
    try {
      _dwmExtendFrameIntoClientArea(hwnd, margins);
    } finally {
      calloc.free(margins);
    }
    // 2) 关掉 Win11 系统背景材质 (插件的恢复分支漏清)
    final none = calloc<Int32>()..value = _kDwmsbtNone;
    final off = calloc<Int32>();
    try {
      _dwmSetWindowAttribute(
          hwnd, _kDwmwaSystemBackdropType, none.cast<Void>(), sizeOf<Int32>());
      _dwmSetWindowAttribute(
          hwnd, _kDwmwaMicaEffect, off.cast<Void>(), sizeOf<Int32>());
    } finally {
      calloc.free(none);
      calloc.free(off);
    }
    // 3) 按系统偏好恢复深色边框标记 (应用 UI 恒为深色), 等价于冷启动时
    //    runner 的 UpdateTheme: 只在系统深色时点亮。插件已改成 channel 调用。
    await windowManager.setBrightness(Brightness.dark);
    Log.debug('resetBackdropResidue: done');
  } catch (e, s) {
    Log.error('resetBackdropResidue failed.\n$e.\n$s');
  }
}

int _mainWindowHandle() {
  final className = _kWindowClassName.toNativeUtf16();
  try {
    return _findWindowW(className, nullptr);
  } finally {
    calloc.free(className);
  }
}
