import 'package:again/models/voice_work.dart';
import 'package:again/presentation/state_interface/state_interface.dart';
import 'package:again/presentation/state_interface/variable_list_state/variable_list_state.dart';

class VoiceWorkState extends VariableListState<VoiceWork> {
  VoiceWorkState({
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    super.playingValues = const [],
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceWorkState copyWith({
    VoiceWork? cachedPlayingItem,
    VoiceWork? cachedSelectedItem,
    List<VoiceWork>? playingValues,
    List<VoiceWork>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceWorkState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      playingValues: playingValues ?? this.playingValues,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  bool get cachedSelectedVoiceWorkExist => cachedSelectedItem?.exist ?? false;

  String? get cachedPlayingVoiceWorkPath => cachedPlayingItem?.directoryPath;

  String? get cachedSelectedVoiceWorkPath => cachedSelectedItem?.directoryPath;
}
