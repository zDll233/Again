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

/// 复现: 音轨列表倒序 (时间倒序) 时, 点击"定位到当前播放位置"后,
/// 列表顺序被反转、选中项错位。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ProviderContainer container;

  VoiceItem vi(String title) => VoiceItem(
        title: title,
        filePath: '/w/$title.mp3',
        voiceWorkPath: '/w',
      );

  // 音轨没有 createdAt → 时间排序按标题自然序兜底, 标题顺序即 a..e
  final dbOrder = ['a', 'b', 'c', 'd', 'e'].map(vi).toList();

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('again_locate_test');
    container = ProviderContainer(
      overrides: [
        audioProvider.overrideWith(() => _StubAudioNotifier()),
        configJsonProvider.overrideWithValue(
          JsonStorage(filePath: '${tempDir.path}/config.json'),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      tempDir.deleteSync(recursive: true);
    });
  });

  void setupAsIfDbLoaded({required VoiceItemSort sort}) {
    container.read(voiceItemProvider.notifier).setValues(List.of(dbOrder));
    container.read(voiceItemProvider.notifier).setSortOrder(sort);
  }

  /// 模拟点击某个音轨 (走真实 cacheAllPlayingState 的缓存逻辑, 但不播放)。
  void clickTrack(int index) {
    final viNotifier = container.read(voiceItemProvider.notifier);
    viNotifier.cacheSelectedIndexAndItem(index);
    container.read(sortOrderProvider.notifier).cachePlayingState();
    container.read(categoryProvider.notifier).cachePlayingState();
    container.read(cvProvider.notifier).cachePlayingState();
    container.read(voiceWorkProvider.notifier).cachePlayingState();
    container.read(voiceItemProvider.notifier).cachePlayingState();
  }

  /// 模拟浏览到另一个作品 (updateViList → setValues 会清掉选中/播放指向)。
  void browseToAnotherWork() {
    container
        .read(voiceItemProvider.notifier)
        .setValues(['x', 'y', 'z'].map(vi).toList());
  }

  /// 点击"定位到当前播放位置" (isSelectedVoiceWorkPlaying 为 false, 走 restore)。
  void clickLocate() {
    container.read(uiServiceProvider).onLocateBtnPressed();
  }

  test('倒序播放 → 浏览他作 → 定位: 选中应仍在播放音轨', () {
    // 1. 列表按"时间倒序"展示, 播放倒序下第二个 (d)
    setupAsIfDbLoaded(sort: VoiceItemSort.timeDesc);
    var st = container.read(voiceItemProvider);
    expect(st.values.map((e) => e.title).toList(), ['e', 'd', 'c', 'b', 'a']);

    clickTrack(1); // 播放倒序下第二个 (d)
    st = container.read(voiceItemProvider);
    expect(st.cachedPlayingItem?.title, 'd');
    expect(st.playingIndex, 1);
    expect(st.selectedIndex, 1);
    expect(
        st.playingValues.map((e) => e.title).toList(), ['e', 'd', 'c', 'b', 'a']);

    // 2. 浏览到其他作品
    browseToAnotherWork();

    // 3. 点击定位
    clickLocate();

    st = container.read(voiceItemProvider);
    // 期望: 列表仍为倒序 (restore 不得重新套用排序反转列表), 选中 = 播放 = d
    final titles = st.values.map((e) => e.title).toList();
    expect(titles, ['e', 'd', 'c', 'b', 'a'], reason: '定位不应改变列表顺序');
    expect(st.playingIndex, 1);
    expect(st.selectedIndex, st.playingIndex,
        reason: '选中应跟随播放音轨: selected=${st.selectedIndex} '
            'values=$titles');
    expect(st.cachedSelectedItem?.title, 'd');
  });

  test('正序播放 → 播放中切换倒序 → 浏览他作 → 定位: 列表不被反转', () {
    // 播放时是正序 (时间顺序), 播放 d (第 4 个)
    setupAsIfDbLoaded(sort: VoiceItemSort.timeAsc);
    clickTrack(3);
    var st = container.read(voiceItemProvider);
    expect(st.playingIndex, 3);

    // 播放过程中切到"时间倒序": 显示列表与播放队列都应变为倒序
    container
        .read(voiceItemProvider.notifier)
        .setSortOrder(VoiceItemSort.timeDesc);
    st = container.read(voiceItemProvider);
    expect(st.values.map((e) => e.title).toList(), ['e', 'd', 'c', 'b', 'a']);
    expect(st.playingValues.map((e) => e.title).toList(),
        ['e', 'd', 'c', 'b', 'a'], reason: '播放队列应跟随排序变化');
    expect(st.playingIndex, 1, reason: 'd 应为倒序下第二个');
    expect(st.selectedIndex, st.playingIndex,
        reason: '选中应跟随播放音轨: selected=${st.selectedIndex}');

    // 浏览走再定位: 倒序保持, 选中仍在 d
    browseToAnotherWork();
    clickLocate();

    st = container.read(voiceItemProvider);
    final titles = st.values.map((e) => e.title).toList();
    expect(titles, ['e', 'd', 'c', 'b', 'a'], reason: '列表应保持倒序');
    expect(st.selectedIndex, st.playingIndex,
        reason: '选中应跟随播放音轨: selected=${st.selectedIndex} '
            'playing=${st.playingIndex} values=$titles');
    expect(st.selectedIndex, 1);
    expect(st.cachedSelectedItem?.title, 'd');
  });
}

class _StubAudioNotifier extends AudioNotifier {
  @override
  AudioState build() {
    return AudioState(playbackMode: PlaybackMode.sequentialPlay);
  }
}