import 'package:again/models/voice_item.dart';
import 'package:again/presentation/state_interface.dart';

class VoiceItemState extends VariableListState<VoiceItem> {
  VoiceItemState({
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    super.playingValues = const [],
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceItemState copyWith({
    VoiceItem? cachedPlayingItem,
    VoiceItem? cachedSelectedItem,
    List<VoiceItem>? playingValues,
    List<VoiceItem>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceItemState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      playingValues: playingValues ?? this.playingValues,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  String? get cachedPlayingVoiceItemPath => cachedPlayingItem?.filePath;

  String get selectedVoiceItemPath => selectedItem.filePath;
}
