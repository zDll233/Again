import 'package:again/presentation/state_interface.dart';

class CvState extends ListState<String> {
  CvState({
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    super.values = const [],
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  CvState copyWith({
    String? cachedPlayingItem,
    String? cachedSelectedItem,
    List<String>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return CvState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
