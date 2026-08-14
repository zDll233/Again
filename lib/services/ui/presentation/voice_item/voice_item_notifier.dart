import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';

/// 音轨排序方式: 标题升/降序, 文件顺序 (数据库原始顺序) 升/降序。
enum VoiceItemSort {
  titleAsc,
  titleDesc,
  fileAsc,
  fileDesc,
}

extension VoiceItemSortExtension on VoiceItemSort {
  String get label => switch (this) {
        VoiceItemSort.titleAsc => '标题顺序',
        VoiceItemSort.titleDesc => '标题倒序',
        VoiceItemSort.fileAsc => '时间顺序',
        VoiceItemSort.fileDesc => '时间倒序',
      };
}

class VoiceItemNotifier
    extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  /// 当前音轨排序方式, 默认按标题升序。
  VoiceItemSort sort = VoiceItemSort.titleAsc;

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
    super.setValues(newValues);
  }

  /// 菜单选择排序方式, 保持选中与播放指向同一个音轨。
  void setSortOrder(VoiceItemSort newSort) {
    sort = newSort;
    final base = List.of(_originalOrder ?? state.values);
    final sorted = switch (newSort) {
      VoiceItemSort.titleAsc => base..sort((a, b) => compareNatural(a.title, b.title)),
      VoiceItemSort.titleDesc => base..sort((a, b) => compareNatural(b.title, a.title)),
      VoiceItemSort.fileAsc => base,
      VoiceItemSort.fileDesc => base.reversed.toList(),
    };
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
