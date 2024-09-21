import 'package:again/presentation/state_interface/base_state.dart';

/// `SortOrder`, `Category`, `Cv` 正在播放的列表和选中的列表均为`values`
abstract class ListState<ValueType> extends BaseState {
  final List<ValueType> values;
  final int playingIndex;
  final int selectedIndex;
  final ValueType? cachedPlayingItem;
  final ValueType? cachedSelectedItem;
  ListState({
    required this.cachedPlayingItem,
    required this.cachedSelectedItem,
    required this.values,
    required this.playingIndex,
    required this.selectedIndex,
  });

  ValueType get playingItem => values[playingIndex];
  ValueType get selectedItem => values[selectedIndex];

  bool get isPlayingIndexValid =>
      playingIndex >= 0 && playingIndex < values.length;

  bool get isSelectedIndexValid =>
      selectedIndex >= 0 && selectedIndex < values.length;

  bool get isPlaying => isPlayingIndexValid && cachedPlayingItem != null;

  bool get isSelectedItemPlaying =>
      isPlaying && cachedPlayingItem == cachedSelectedItem;

  @override
  ListState<ValueType> copyWith({
    ValueType? cachedPlayingItem,
    ValueType? cachedSelectedItem,
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}
