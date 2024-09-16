import 'package:again/models/voice_work.dart';
import 'package:again/presentation/state_interface.dart';

class VoiceWorkState extends VariableListState<VoiceWork> {
  VoiceWork? cachedSelectedItem;
  VoiceWorkState({
    super.cachedPlayingItem,
    this.cachedSelectedItem,
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

  String? get cachedPlayingVoiceWorkPath => cachedPlayingItem?.directoryPath;

  String? get cachedSelectedVoiceWorkPath => cachedSelectedItem?.directoryPath;


}
