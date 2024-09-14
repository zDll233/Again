import 'package:again/models/voice_item.dart';
import 'package:again/ui/state_interface.dart';

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


