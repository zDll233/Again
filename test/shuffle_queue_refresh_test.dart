import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/services/audio/audio_notifier.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 复现: 重启后播放顺序为「随机播放」, 实际却按顺序播放。
///
/// 启动流程: 历史恢复把播放队列打乱 (HistoryManager._loadAudioHistory →
/// UIService.shufflePlayingState), 随后静默刷新 (DatabaseNotifier.silentRefresh
/// → updatePlayingValues) 又按排序重建了 playingValues, 随机队列被冲掉,
/// 再次点击随机播放 (重新执行 shufflePlayingState) 才会恢复乱序。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  VoiceItem vi(String title) => VoiceItem(
        title: title,
        filePath: '/w/$title.mp3',
        voiceWorkPath: '/w',
      );

  List<String> titlesOf(List<VoiceItem> items) =>
      items.map((item) => item.title).toList();

  ProviderContainer makeContainer(PlaybackMode mode) {
    final container = ProviderContainer(
      overrides: [
        audioProvider.overrideWith(() => _StubAudioNotifier(mode)),
        configJsonProvider.overrideWithValue(
          JsonStorage(filePath: '${tempDir.path}/config.json'),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// 复刻启动恢复: updateViList 写入列表 → 恢复选中音轨 → 缓存播放状态
  /// → (随机模式) 打乱播放队列。
  void restoreStartupState(
    ProviderContainer container, {
    required List<VoiceItem> dbValues,
    required int selectedIndex,
    required PlaybackMode mode,
  }) {
    final viNotifier = container.read(voiceItemProvider.notifier);
    viNotifier.setValues(List.of(dbValues));
    viNotifier.cacheSelectedIndexAndItem(selectedIndex);
    viNotifier.cachePlayingState();
    if (mode == PlaybackMode.shufflePlay) {
      container.read(uiServiceProvider).shufflePlayingState();
    }
  }

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('again_shuffle_refresh');
    addTearDown(() => tempDir.deleteSync(recursive: true));
  });

  test('随机播放: 启动静默刷新后随机队列保持原顺序', () {
    final container = makeContainer(PlaybackMode.shufflePlay);
    final dbOrder = ['a', 'b', 'c', 'd', 'e', 'f'].map(vi).toList();
    restoreStartupState(container,
        dbValues: dbOrder, selectedIndex: 2, mode: PlaybackMode.shufflePlay);
    final shuffled =
        titlesOf(container.read(voiceItemProvider).playingValues);
    expect(shuffled.toSet(), {'a', 'b', 'c', 'd', 'e', 'f'});

    // 静默刷新: 音轨未变, 数据库按当前排序返回 (顺序) 列表
    final refreshed = ['a', 'b', 'c', 'd', 'e', 'f'].map(vi).toList();
    final sortedRefreshed = applyVoiceItemSort(
        List.of(refreshed), container.read(voiceItemProvider).sort);
    container
        .read(voiceItemProvider.notifier)
        .setRefreshedPlayingValues(sortedRefreshed);
    container
        .read(voiceItemProvider.notifier)
        .setPlayingIndexByValue(
            container.read(voiceItemProvider).cachedPlayingItem);

    final state = container.read(voiceItemProvider);
    final queue = titlesOf(state.playingValues);
    expect(queue, shuffled, reason: '静默刷新不应把随机队列重排成顺序: $queue');
    expect(state.playingIndex, queue.indexOf(state.cachedPlayingItem!.title),
        reason: '队列坐标应仍指向当前播放音轨');
  });

  test('随机播放: 刷新只做增删合并, 新音轨随机插回队列', () {
    final container = makeContainer(PlaybackMode.shufflePlay);
    final viNotifier = container.read(voiceItemProvider.notifier);
    final dbOrder = ['a', 'b', 'c', 'd', 'e'].map(vi).toList();
    viNotifier.setValues(List.of(dbOrder));
    viNotifier.cacheSelectedIndexAndItem(2);
    // 已知的乱序队列 (相当于随机播放打乱后的快照)
    const shuffledOrder = ['c', 'a', 'e', 'b', 'd'];
    viNotifier.cachePlayingState(
      playingIndex: shuffledOrder.indexOf('c'),
      playingValues: shuffledOrder.map(vi).toList(),
    );

    // 刷新: b 被删除, 新增 f
    final refreshed = ['a', 'c', 'd', 'e', 'f'].map(vi).toList();
    final sortedRefreshed = applyVoiceItemSort(
        List.of(refreshed), container.read(voiceItemProvider).sort);
    viNotifier.setRefreshedPlayingValues(sortedRefreshed);
    viNotifier.setPlayingIndexByValue(
        container.read(voiceItemProvider).cachedPlayingItem);

    final state = container.read(voiceItemProvider);
    final queue = titlesOf(state.playingValues);
    expect(queue.toSet(), {'a', 'c', 'd', 'e', 'f'});
    expect(queue.length, 5);
    expect(queue.where((title) => title != 'f').toList(), ['c', 'a', 'e', 'd'],
        reason: '既有音轨的随机顺序应保留, 实际: $queue');
    expect(state.cachedPlayingItem?.title, 'c');
    expect(state.playingIndex, queue.indexOf('c'));
  });

  test('顺序播放: 刷新仍按排序重建队列 (原行为不变)', () {
    final container = makeContainer(PlaybackMode.sequentialPlay);
    final viNotifier = container.read(voiceItemProvider.notifier);
    final dbOrder = ['a', 'b', 'c', 'd', 'e'].map(vi).toList();
    viNotifier.setValues(List.of(dbOrder));
    viNotifier.cacheSelectedIndexAndItem(0);
    viNotifier.cachePlayingState();

    final refreshed = ['a', 'c', 'd', 'e', 'f'].map(vi).toList();
    final sortedRefreshed = applyVoiceItemSort(
        List.of(refreshed), container.read(voiceItemProvider).sort);
    viNotifier.setRefreshedPlayingValues(sortedRefreshed);

    expect(titlesOf(container.read(voiceItemProvider).playingValues),
        ['a', 'c', 'd', 'e', 'f']);
  });
}

class _StubAudioNotifier extends AudioNotifier {
  _StubAudioNotifier(this.mode);

  final PlaybackMode mode;

  @override
  AudioState build() => AudioState(playbackMode: mode);
}
