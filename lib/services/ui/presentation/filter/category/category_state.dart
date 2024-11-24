import 'package:again/services/ui/presentation/state_interface/list_state/list_state.dart';
import 'package:again/services/ui/presentation/state_interface/state_interface.dart';

class CategoryState extends ListState<String> {
  CategoryState({
    super.cachedPlayingItem = 'All',
    super.cachedSelectedItem = 'All',
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
