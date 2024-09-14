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
    final audio = ref.read(audioProvider.notifier);

    if (uiService.isVoiceItemPlaying && selectedIndex == state.playingIndex) {
      audio.switchPauseResume();
      return;
    }

    updatePlayingIndex(selectedIndex);
    uiService.cachePlayingState();
    audio.play(DeviceFileSource(state.playingVoiceItemPath));
  }
}
