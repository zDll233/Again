import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/pages/lists/works_panel/works_list.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_notifier.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_state.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/json_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 作品面板左右拖拽: 宽屏开关筛选面板, 窄屏保持「右划开筛选 / 左划切音轨」,
/// 以及筛选面板展开状态的持久化 (config.json `filterExpanded`)。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  VoiceWork vw(String title) => VoiceWork(
        title: title,
        sourceId: 'RJ000000',
        directoryPath: '${tempDir.path}/$title',
        coverPath: '',
        category: 'cat',
        createdAt: null,
      );

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('again_filter_drag');
  });

  tearDown(() async {
    // 状态落盘是 fire-and-forget, 可能还有写句柄: 删除尽力而为, 不阻塞测试
    for (var i = 0; i < 6; i++) {
      try {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        return;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  });

  /// 逐段移动的横向/斜向拖拽 (避免 tester.dragFrom 的 touch slop 补偿
  /// 改变实际位移, 阈值与斜向判定要按真实 delta 累计)。
  Future<void> dragPath(
    WidgetTester tester,
    Offset start,
    Offset delta, {
    int steps = 8,
  }) async {
    final gesture = await tester.startGesture(start);
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(delta / steps.toDouble());
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }


  Future<ProviderContainer> pumpWorksList(
    WidgetTester tester, {
    required Size logicalSize,
    bool empty = false,
    bool searchEnabled = false,
  }) async {
    tester.view.physicalSize = logicalSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final configPath = '${tempDir.path}/config.json';
    if (searchEnabled) {
      File(configPath).writeAsStringSync('{"searchEnabled": true}');
    }

    final container = ProviderContainer(
      overrides: [
        configJsonProvider.overrideWithValue(
          JsonStorage(filePath: configPath),
        ),
        // 搜索总开关直接给值, 避免依赖真实文件 IO 的异步解析
        if (searchEnabled) searchEnabledProvider.overrideWith((ref) => true),
        voiceWorkProvider.overrideWith(
          () => _StubVoiceWorkNotifier(
            empty ? [] : ['a', 'b', 'c'].map(vw).toList(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: WorksListView())),
      ),
    );
    await tester.pump();
    return container;
  }

  testWidgets('宽屏: 作品面板右拖展开筛选, 左拖收起', (tester) async {
    final container =
        await pumpWorksList(tester, logicalSize: const Size(1200, 800));
    expect(container.read(miscUIProvider).filterExpanded, isFalse);

    await dragPath(tester, const Offset(500, 400), const Offset(140, 0));
    expect(container.read(miscUIProvider).filterExpanded, isTrue,
        reason: '右拖应展开筛选面板');

    await dragPath(tester, const Offset(500, 400), const Offset(-140, 0));
    expect(container.read(miscUIProvider).filterExpanded, isFalse,
        reason: '左拖应收起筛选面板');
  });

  testWidgets('宽屏: 位移小于阈值或斜向拖动不切换', (tester) async {
    final container =
        await pumpWorksList(tester, logicalSize: const Size(1200, 800));

    await dragPath(tester, const Offset(500, 400), const Offset(30, 0));
    expect(container.read(miscUIProvider).filterExpanded, isFalse,
        reason: '30px 小于开关阈值 (48px)');

    await dragPath(tester, const Offset(500, 400), const Offset(70, 220));
    expect(container.read(miscUIProvider).filterExpanded, isFalse,
        reason: '斜向拖动不触发');
  });

  testWidgets('宽屏: 作品列表为空时同样可以拖拽开关', (tester) async {
    final container = await pumpWorksList(
      tester,
      logicalSize: const Size(1200, 800),
      empty: true,
    );

    await dragPath(tester, const Offset(500, 400), const Offset(140, 0));
    expect(container.read(miscUIProvider).filterExpanded, isTrue);
  });

  testWidgets('宽屏: 搜索框内横向拖动不开关筛选, 列表里可以', (tester) async {
    final container = await pumpWorksList(
      tester,
      logicalSize: const Size(1200, 800),
      searchEnabled: true,
    );
    expect(find.byType(SearchableHeader), findsOneWidget,
        reason: '开启搜索后应有搜索头部');

    // 头部高 40, 这里拖在头部内 (搜索框/标题区域)
    await dragPath(tester, const Offset(300, 20), const Offset(140, 0));
    expect(container.read(miscUIProvider).filterExpanded, isFalse,
        reason: '搜索框里横向拖动是选文字, 不应触发筛选开关');

    await dragPath(tester, const Offset(500, 400), const Offset(140, 0));
    expect(container.read(miscUIProvider).filterExpanded, isTrue);
  });

  testWidgets('窄屏: 右划开筛选, 左划切音轨 (原行为不变)', (tester) async {
    final container =
        await pumpWorksList(tester, logicalSize: const Size(400, 800));

    await dragPath(tester, const Offset(200, 400), const Offset(120, 0));
    expect(container.read(miscUIProvider).filterExpanded, isTrue);

    container.read(miscUIProvider.notifier).setFilterExpanded(
          false,
          persist: false,
        );
    await tester.pumpAndSettle();

    await dragPath(tester, const Offset(200, 400), const Offset(-120, 0));
    expect(container.read(listsPanelPageProvider), 1,
        reason: '窄屏左划仍应切到音轨面板');
  });

  test('筛选面板状态写入 config.json; persist:false 不写', () async {
    final config = JsonStorage(filePath: '${tempDir.path}/config.json');
    final container = ProviderContainer(
      overrides: [configJsonProvider.overrideWithValue(config)],
    );
    addTearDown(container.dispose);

    container.read(miscUIProvider.notifier).setFilterExpanded(true);
    await _waitFor(() async => (await config.read())['filterExpanded'] == true);
    expect((await config.read())['filterExpanded'], isTrue,
        reason: '展开状态应落盘, 下次启动恢复');

    container
        .read(miscUIProvider.notifier)
        .setFilterExpanded(false, persist: false);
    expect(container.read(miscUIProvider).filterExpanded, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect((await config.read())['filterExpanded'], isTrue,
        reason: '启动恢复 (persist:false) 不应覆盖配置');
  });
}

/// 轮询等待条件成立 (落盘是 fire-and-forget, 无 Future 可 await)。
Future<void> _waitFor(
  Future<bool> Function() check, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await check()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('等待超时: 条件未成立');
}

class _StubVoiceWorkNotifier extends VoiceWorkNotifier {
  _StubVoiceWorkNotifier(this._values);

  final List<VoiceWork> _values;

  @override
  VoiceWorkState build() => VoiceWorkState(values: _values);
}
