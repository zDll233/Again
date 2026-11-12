import 'dart:async';
import 'dart:math';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';

class VoiceItemNotifier
    extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  /// 最近一次数据刷新 (updateViList) 的原始顺序。四种排序都是全序,
  /// 换排序时直接对这份基准重排, 不受上一次排序结果影响。
  List<VoiceItem>? _originalOrder;

  /// 随机播放队列合并时, 给新增音轨随机插入位置用。
  final Random _random = Random();

  @override
  VoiceItemState build() {
    return VoiceItemState();
  }

  @override
  void setValues(List<VoiceItem> newValues) {
    // 记录数据库返回的原始顺序, 供排序切换回退
    _originalOrder = List.of(newValues);
    // 刷新时保持当前排序方式, 避免列表顺序跳变
    super.setValues(applyVoiceItemSort(List.of(newValues), state.sort));
    // 排序后重定位选中/播放指向
    setSelectedIndexByValue(state.cachedSelectedItem);
    setCachedSelectedItem(state.cachedSelectedItem);
    setPlayingIndexByValue(state.cachedPlayingItem);
    setCachedPlayingItem(state.cachedPlayingItem);
  }

  /// 恢复播放状态时直接采用播放列表顺序, 不再套用当前排序:
  /// `playingValues` 是播放时刻的已排序快照, 重新排序会改变队列顺序,
  /// 并导致 `playingIndex` (队列坐标) 与显示列表坐标错位, 定位选中错项。
  @override
  void restoreValues({List<VoiceItem>? values}) {
    final restored = values ?? state.playingValues;
    _originalOrder = List.of(restored);
    // 直接调基类 setValues, 绕过本类的排序重定位
    super.setValues(restored);
  }

  /// 菜单选择排序方式, 保持选中与播放指向同一个音轨。
  void setSortOrder(VoiceItemSort newSort) {
    final sorted =
        applyVoiceItemSort(List.of(_originalOrder ?? state.values), newSort);
    final selected = state.cachedSelectedItem;
    final playing = state.cachedPlayingItem;
    // 用 super.setValues 避免覆盖 _originalOrder
    super.setValues(sorted);
    setSelectedIndexByValue(selected);
    setCachedSelectedItem(selected);
    // 播放队列跟随新排序, 保证队列与显示顺序一致 (否则恢复播放状态时
    // playingIndex 的队列坐标会被当作显示坐标, 定位/选中错位)。
    // 随机播放时队列是特意打乱的, 不跟随排序变化。
    if (state.playingValues.isNotEmpty &&
        !ref.read(audioProvider).isShufflePlay) {
      setPlayingValues(
          applyVoiceItemSort(List.of(state.playingValues), newSort));
    }
    setPlayingIndexByValue(playing);
    setCachedPlayingItem(playing);
    state = state.copyWith(sort: newSort);
    // 持久化排序到 config.json
    unawaited(_persistSort(newSort));
  }

  Future<void> _persistSort(VoiceItemSort sort) async {
    await ref
        .read(configJsonProvider)
        .mutate((config) => {...config, 'voiceItemSort': sort.toString()});
  }

  /// 数据刷新 (重启后的静默刷新 / 手动刷新) 后同步播放队列。
  ///
  /// 顺序播放: 队列跟随当前排序, 与显示列表一致。
  /// 随机播放: [playingValues] 是开启随机时特意打乱的快照, 刷新时若按排序
  /// 重新生成, 随机播放就会退化成顺序播放 (重启后历史恢复的随机队列先被
  /// 打乱, 随后静默刷新又把它重排回顺序, 表现为"随机模式实际按顺序播")。
  /// 因此这里只做增删合并: 保留原有随机顺序, 剔除已消失的音轨, 新增音轨
  /// 随机插回队列。
  void setRefreshedPlayingValues(List<VoiceItem> freshValues) {
    if (!ref.read(audioProvider).isShufflePlay) {
      setPlayingValues(freshValues);
      return;
    }

    final previous = state.playingValues;
    if (previous.isEmpty) {
      setPlayingValues(List.of(freshValues)..shuffle(_random));
      return;
    }

    final freshByPath = <String, VoiceItem>{
      for (final item in freshValues) item.filePath: item,
    };
    // 保留随机队列中仍存在的音轨 (用刷新后的对象换掉旧对象)
    final merged = <VoiceItem>[];
    final mergedPaths = <String>{};
    for (final old in previous) {
      final fresh = freshByPath[old.filePath];
      if (fresh != null && mergedPaths.add(fresh.filePath)) {
        merged.add(fresh);
      }
    }

    // 新增音轨随机插回队列, 而不是集中追加到末尾
    final added = [
      for (final fresh in freshValues)
        if (!mergedPaths.contains(fresh.filePath)) fresh,
    ]..shuffle(_random);
    for (final item in added) {
      merged.insert(_random.nextInt(merged.length + 1), item);
    }

    setPlayingValues(merged);
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    final uiService = ref.read(uiServiceProvider);
    final audioNotifier = ref.read(audioProvider.notifier);
    final voiceWorkPlaying = ref.read(isSelectedVoiceWorkPlaying);

    // 只有点击的确实是当前播放音轨才暂停; 排序变化后索引相同不代表同一音轨。
    final tappedItem = state.values[selectedIndex];
    if (voiceWorkPlaying &&
        state.cachedPlayingItem != null &&
        state.cachedPlayingItem == tappedItem) {
      audioNotifier.switchPauseResume();
      return;
    }

    cacheSelectedIndexAndItem(selectedIndex);
    uiService.cacheAllPlayingState();
    audioNotifier.play(state.cachedPlayingVoiceItemPath!);
  }

  void changeTrack(int playingIndex) {
    cachePlayingIndex(playingIndex: playingIndex);

    // calc selectedIndex according to playingItem in values
    final selectedIndex = ref.read(audioProvider).isShufflePlay
        ? state.values.indexOf(state.playingItem)
        : playingIndex;
    setSelectedIndex(selectedIndex);

    // changeTrack必然是在playingValues中
    setCachedSelectedItem(state.isPlayingIndexValid ? state.playingItem : null);
    cachePlayingItem();
  }
}
