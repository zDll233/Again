import 'package:again/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/voice_item/voice_item_state.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceItemNotifier
    extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  @override
  VoiceItemState build() {
    return VoiceItemState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    final uiService = ref.read(uiServiceProvider);
    final audioNotifier = ref.read(audioProvider.notifier);

    /// 选中的VoiceItem正在播放则暂停播放并返回
    if (state.playingIndex == selectedIndex &&
        uiService.isSelectedVoiceWorkPlaying) {
      audioNotifier.switchPauseResume();
      return;
    }

    setPlayingIndex(selectedIndex);

    uiService.cacheAllPlayingState();
    audioNotifier.play(DeviceFileSource(state.cachedPlayingVoiceItemPath!));
  }

  @override
  void setPlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex, selectedIndex: newIndex);
  }

  @override
  @Deprecated(
      '`updatePlayingIndex` updates `playingIndex` and `selectedIndex` both, use `updatePlayingIndex` instead')
  void setSelectedIndex(int newIndex) {
    setPlayingIndex(newIndex);
  }
}
