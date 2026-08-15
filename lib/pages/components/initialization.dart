import 'dart:async';
import 'dart:io';

import 'package:again/common/const.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Initialization extends ConsumerStatefulWidget {
  const Initialization({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<Initialization> createState() => _InitializationState();
}

class _InitializationState extends ConsumerState<Initialization> {
  late final KeyEventHandler _keyEventHandler;
  WindowBoundsMemory? _windowBoundsMemory;
  WindowSizeGuard? _windowSizeGuard;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
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
      return const Text('Error initializing.');
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
  // 窗口位置恢复 / 数据库初始化 / 历史加载互不依赖, 并行执行
  await Future.wait([
    restoreWindowBounds(ref.read(configJsonProvider)),
    ref.read(dbNotifierProvider).initialize(),
    ref.read(historyManagerProvider).loadHistory(),
  ]);
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
  }
  // 启动完成后再静默增量刷新, 不阻塞初始化
  unawaited(ref.read(dbNotifierProvider).silentRefresh());
});
