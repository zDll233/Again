import 'dart:async';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';

class VoiceItemNotifier
    extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  /// 最近一次数据刷新 (updateViList) 的原始顺序, 作为"时间顺序"基准。
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
    super.setValues(_applySort(List.of(newValues), state.sort));
    // 排序后重定位选中/播放指向
    setSelectedIndexByValue(state.cachedSelectedItem);
    setCachedSelectedItem(state.cachedSelectedItem);
    setPlayingIndexByValue(state.cachedPlayingItem);
    setCachedPlayingItem(state.cachedPlayingItem);
  }

  List<VoiceItem> _applySort(List<VoiceItem> base, VoiceItemSort sort) {
    switch (sort) {
      case VoiceItemSort.titleAsc:
        base.sort((a, b) => compareNatural(a.title, b.title));
        return base;
      case VoiceItemSort.titleDesc:
        base.sort((a, b) => compareNatural(b.title, a.title));
        return base;
      case VoiceItemSort.fileAsc:
        return base;
      case VoiceItemSort.fileDesc:
        return base.reversed.toList();
    }
  }

  /// 菜单选择排序方式, 保持选中与播放指向同一个音轨。
  void setSortOrder(VoiceItemSort newSort) {
    final sorted = _applySort(
        List.of(_originalOrder ?? state.values), newSort);
    final selected = state.cachedSelectedItem;
    final playing = state.cachedPlayingItem;
    // 用 super.setValues 避免覆盖 _originalOrder
    super.setValues(sorted);
    setSelectedIndexByValue(selected);
    setCachedSelectedItem(selected);
    setPlayingIndexByValue(playing);
    setCachedPlayingItem(playing);
    state = state.copyWith(sort: newSort);
    // 持久化排序到 config.json
    unawaited(_persistSort(newSort));
  }

  Future<void> _persistSort(VoiceItemSort sort) async {
    final config = await ref.read(configJsonProvider).read();
    await ref
        .read(configJsonProvider)
        .write({...config, 'voiceItemSort': sort.toString()});
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    final uiService = ref.read(uiServiceProvider);
    final audioNotifier = ref.read(audioProvider.notifier);
    final voiceWorkPlaying = ref.read(isSelectedVoiceWorkPlaying);

    /// 选中的VoiceItem正在播放则暂停播放并返回
    if (state.playingIndex == selectedIndex && voiceWorkPlaying) {
      audioNotifier.switchPauseResume();
      return;
    }

    cacheSelectedIndexAndItem(selectedIndex);
    uiService.cacheAllPlayingState();
    audioNotifier.play(DeviceFileSource(state.cachedPlayingVoiceItemPath!));
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
