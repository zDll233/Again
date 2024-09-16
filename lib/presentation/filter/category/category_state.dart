import 'package:again/presentation/state_interface.dart';

class CategoryState extends ListState<String> {
  CategoryState({
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    super.values = const [],
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  CategoryState copyWith({
    String? cachedPlayingItem,
    String? cachedSelectedItem,
    List<String>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return CategoryState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
