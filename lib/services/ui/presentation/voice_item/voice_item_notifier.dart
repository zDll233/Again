import 'dart:async';

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
