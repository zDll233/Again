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
  /// update `playingIndex` and `selectedIndex` both
  void updatePlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex, selectedIndex: newIndex);
  }

  @override
  @Deprecated('`updatePlayingIndex` updates `playingIndex` and `selectedIndex` both, use `updatePlayingIndex` instead')
  void updateSelectedIndex(int newIndex) {
    updatePlayingIndex(newIndex);
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    final uiService = ref.read(uiServiceProvider);
    final audioNotifier = ref.read(audioProvider.notifier);

    /// 选中的VoiceItem正在播放则暂停并返回
    if (uiService.isVoiceWorkPlaying && state.playingIndex == selectedIndex) {
      audioNotifier.switchPauseResume();
      return;
    }

    updatePlayingIndex(selectedIndex);
    uiService.cachePlayingState();
    audioNotifier.play(DeviceFileSource(state.playingVoiceItemPath));
  }
}
