import 'package:again/audio/audio_state_notifier.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceItemState extends VariableListState<VoiceItem> {
  VoiceItemState({
    super.playingValues = const [],
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceItemState copyWith({
    List<VoiceItem>? playingValues,
    List<VoiceItem>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceItemState(
      playingValues: playingValues ?? this.playingValues,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  List<String> get playingVoiceItemPathList =>
      playingValues.map((voiceItem) => voiceItem.filePath).toList();

  List<String> get selectedVoiceItemPathList =>
      values.map((voiceItem) => voiceItem.filePath).toList();

  String get playingVoiceItemPath => playingItem.filePath;

  String get selectedVoiceItemPath => selectedItem.filePath;
}

class VoiceItemNotifier extends VariableListStateNotifier<VoiceItemState, VoiceItem> {
  @override
  VoiceItemState build() {
    return VoiceItemState();
  }


  @override
  Future<void> onSelected(int selectedIndex) async {
    final uiService = UIService(ref);
    final audio = ref.read(audioProvider.notifier);

    if (uiService.isVoiceItemPlaying && selectedIndex == state.playingIndex) {
      audio.switchPauseResume();
      return;
    }

    updatePlayingIndex(selectedIndex);

    // TODO: update playingValues

    uiService.setAllSelectedIndex2Playing();
    audio.play(
        DeviceFileSource(ref.read(voiceItemProvider).playingVoiceItemPath));
  }
}

final voiceItemProvider =
    NotifierProvider<VoiceItemNotifier, VoiceItemState>(VoiceItemNotifier.new);
