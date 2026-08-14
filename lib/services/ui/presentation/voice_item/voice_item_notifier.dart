import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';

class VoiceItemNotifier
    extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  /// 音轨排序状态: true=按标题自然排序, false=文件原始顺序。
  bool byTitleSort = true;

  /// 最近一次数据刷新 (updateViList) 的原始顺序, 切回"文件顺序"时使用。
  List<VoiceItem>? _originalOrder;

  @override
  VoiceItemState build() {
    return VoiceItemState();
  }

  @override
  void setValues(List<VoiceItem> newValues) {
    // 记录数据库返回的原始顺序, 供排序切换回退
    _originalOrder = List.of(newValues);
    super.setValues(newValues);
  }

  /// 切换音轨排序: 按标题自然序 <-> 文件原始顺序。
  /// 排序后保持选中与播放指向同一个音轨。
  void toggleSortOrder() {
    byTitleSort = !byTitleSort;
    final sorted = List.of(_originalOrder ?? state.values);
    if (byTitleSort) {
      sorted.sort((a, b) => compareNatural(a.title, b.title));
    }
    final selected = state.cachedSelectedItem;
    final playing = state.cachedPlayingItem;
    // 用 super.setValues 避免覆盖 _originalOrder
    super.setValues(sorted);
    setSelectedIndexByValue(selected);
    setCachedSelectedItem(selected);
    setPlayingIndexByValue(playing);
    setCachedPlayingItem(playing);
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
