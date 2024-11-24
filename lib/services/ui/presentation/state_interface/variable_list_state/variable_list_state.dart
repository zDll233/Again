import 'package:again/services/ui/presentation/state_interface/list_state/list_state.dart';

/// `VoiceWork`和`VoiveItem`正在播放的列表可以不和选中列表`values`相同，故需要`playingValues`和`cachedPlayingItem`
abstract class VariableListState<ValueType> extends ListState<ValueType> {
  final List<ValueType> playingValues;
  VariableListState({
    required this.playingValues,
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    required super.values,
    required super.playingIndex,
    required super.selectedIndex,
  });

  @override
  ValueType get playingItem => playingValues[playingIndex];

  @override
  bool get isPlayingIndexValid =>
      playingIndex >= 0 && playingIndex < playingValues.length;

  @override
  bool get isPlaying => isPlayingIndexValid && cachedPlayingItem != null;

  @override
  bool get isSelectedItemPlaying =>
      isPlaying && cachedPlayingItem == cachedSelectedItem;

  @override
  VariableListState<ValueType> copyWith({
    ValueType? cachedPlayingItem,
    ValueType? cachedSelectedItem,
    List<ValueType>? playingValues,
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}
