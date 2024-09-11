import 'package:again/models/voice_item.dart';
import 'package:again/ui/states/state_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceItemState extends ListState<VoiceItem> {
  VoiceItemState({
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceItem get playingItem => values[playingIndex];

  @override
  VoiceItem get selectedItem => values[selectedIndex];

  @override
  VoiceItemState copyWith({
    List<VoiceItem>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceItemState(
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  List<String> get selectedViPathList {
    // TODO: implement the method.
    throw UnimplementedError();
  }
}

class VoiceItemNotifier extends ListStateNotifier<VoiceItemState, VoiceItem> {
  @override
  VoiceItemState build() {
    return VoiceItemState();
  }

  @override
  void updateValues(List<VoiceItem> newValues) {
    state = state.copyWith(values: newValues);
  }

  @override
  void updatePlayingIdx(int newIndex) {
    state = state.copyWith(playingIndex: newIndex);
  }

  @override
  void updateSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex);
  }

  @override
  void updateState(VoiceItemState newState) {
    state = state.copyWith(
        values: newState.values,
        playingIndex: newState.playingIndex,
        selectedIndex: newState.playingIndex);
  }

  Future<void> onVkSelected(int selectedIndex) async {}

  @override
  Future<void> onItemSelected(int selectedIndex) async {
    // TODO: onItemSelected
      
/*     final AudioController audio = Get.find();
    if (isCurrentViIdxPlaying(idx)) {
      audio.switchPauseResume();
      return;
    }

    audio.playingViIdx.value = idx;
    audio.playingViPathList = selectedViPathList;

    _updatePlayingIdx(sortOrder.value, selectedCategoryIdx.value,
        selectedCvIdx.value, selectedVkIdx.value);
    audio.play(DeviceFileSource(audio.playingViPath)); */
  }
}

final voiceItemProvider =
    NotifierProvider<VoiceItemNotifier, VoiceItemState>(VoiceItemNotifier.new);
