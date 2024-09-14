import 'package:again/models/voice_work.dart';
import 'package:again/feature/state_interface.dart';

class VoiceWorkState extends VariableListState<VoiceWork> {
  VoiceWorkState({
    super.playingValues = const [],
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceWorkState copyWith({
    List<VoiceWork>? playingValues,
    List<VoiceWork>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceWorkState(
      playingValues: playingValues ?? this.playingValues,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  List<String> get playingVoiceWorkPathList =>
      playingValues.map((voiceWork) => voiceWork.directoryPath).toList();

  List<String> get selectedVoiceWorkPathList =>
      values.map((voiceWork) => voiceWork.directoryPath).toList();

  String get playingVoiceWorkPath => playingItem.directoryPath;

  String get selectedVoiceWorkPath => selectedItem.directoryPath;
}

