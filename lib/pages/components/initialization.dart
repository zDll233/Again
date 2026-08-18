import 'dart:async';
import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/audio/again_audio_handler.dart';
import 'package:again/services/audio/audio_service_sync.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/history/history_manager.dart';
import 'package:again/services/key_event/key_event_handler.dart';
import 'package:again/services/system_tray.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/window_bounds_memory.dart';
import 'package:again/services/window_size_guard.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Initialization extends ConsumerStatefulWidget {
  const Initialization({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<Initialization> createState() => _InitializationState();
}

class _InitializationState extends ConsumerState<Initialization>
    with WidgetsBindingObserver {
  late final KeyEventHandler _keyEventHandler;
  WindowBoundsMemory? _windowBoundsMemory;
  WindowSizeGuard? _windowSizeGuard;

  @override
  void initState() {
    super.initState();
    // Android 上系统杀进程/返回退出前保存播放历史 (Windows 退出走 onExit)
    WidgetsBinding.instance.addObserver(this);
    _keyEventHandler = KeyEventHandler(ref);
    HardwareKeyboard.instance.addHandler(_keyEventHandler.handleKeyEvent);
    // 窗口位置/尺寸记忆 + view 尺寸守卫: Windows 专属
    if (Platform.isWindows) {
      _windowBoundsMemory = WindowBoundsMemory(ref.read(configJsonProvider));
      // view 尺寸守卫: 启动渲染完成后检查一次窗口与 view 尺寸同步,
      // 偶发不同步 (内容缩到角落) 时强制 resize 自愈
      _windowSizeGuard = WindowSizeGuard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(ref.read(historyManagerProvider).saveHistory());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _windowBoundsMemory?.dispose();
    _windowSizeGuard?.dispose();
    HardwareKeyboard.instance.removeHandler(_keyEventHandler.handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(_initProvider);

    if (result.isLoading) {
      return const Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (result.hasError) {
      // 注意: Initialization 在 MaterialApp 之外, Text 需要 Directionality
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Error initializing: ${result.error}'),
      );
    }

    return widget.child;
  }
}

final _initProvider = FutureProvider.autoDispose((ref) async {
  // 立即应用窗口背景效果 (transparent/acrylic/opaque), 不依赖后续初始化,
  // 避免启动后窗口先以默认效果显示, 过一会才切到亚克力
  final config = await ref.read(configJsonProvider).read();
  unawaited(ref
      .read(uiServiceProvider)
      .applyWindowEffect(resolveWindowEffect(config)));
  // 窗口位置恢复可并行; 历史加载依赖数据库和根目录初始化完成。
  await Future.wait([
    restoreWindowBounds(ref.read(configJsonProvider)),
    ref.read(dbNotifierProvider).initialize(),
  ]);
  await ref.read(historyManagerProvider).loadHistory();
  // 恢复作品/音轨排序设置 (config.json, 未知值回退默认)
  final sortOrder = config['sortOrder'];
  if (sortOrder is String) {
    await ref
        .read(sortOrderProvider.notifier)
        .setSortOrder(SortOrderExtension.fromString(sortOrder));
  }
  final voiceItemSort = config['voiceItemSort'];
  if (voiceItemSort is String) {
    ref
        .read(voiceItemProvider.notifier)
        .setSortOrder(VoiceItemSortExtension.fromString(voiceItemSort));
  }
  // 托盘初始化放在弹框(首次选择根目录)之后, 避免与文件选择对话框冲突; 仅 Windows
  if (Platform.isWindows) {
    await SystemTrayListener.init(ref);
  } else {
    // Android: 桥接 audio_service (媒体通知/锁屏控制) 到现有播放器状态。
    // AudioService.init 必须在首帧渲染之后调用 — runApp 前初始化会导致
    // FlutterView 尺寸停在 0x0 (真机黑屏)。
    await initAudioServiceAndroid(ref);
  }
  // 启动完成后再静默增量刷新, 不阻塞初始化
  unawaited(ref.read(dbNotifierProvider).silentRefresh());
});

/// Android: 初始化 audio_service 前台服务并桥接到现有播放器状态。
Future<void> initAudioServiceAndroid(Ref ref) async {
  await AudioService.init(
    builder: () => againAudioHandler,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.zdl.again.audio',
      androidNotificationChannelName: 'Again 播放',
      // 暂停时也保持前台服务: ColorOS AudioHardening 在播放器注册时检查
      // 前台服务, 暂停即撤下会让之后的播放再次被判定为后台播放而静音。
      // (androidNotificationOngoing 与 stopForegroundOnPause=false 互斥)
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
  // 先让前台服务进入前台, 再桥接 (播放器创建时 FGS 必须已在前台,
  // 否则 ColorOS AudioHardening 会把播放静音)。
  ensureAudioServiceForeground();
  initAudioServiceBridge(ref);
}
