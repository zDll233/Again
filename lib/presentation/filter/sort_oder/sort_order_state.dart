import 'package:again/presentation/state_interface.dart';

enum SortOrder {
  byTitle,
  byCreatedAt,
}

extension SortOrderExtension on SortOrder {
  static SortOrder fromString(String value) {
    return SortOrder.values.firstWhere(
      (e) => e.toString() == value,
    );
  }
}

class SortOrderState extends ListState<SortOrder> {
  SortOrderState({
    super.cachedPlayingItem = SortOrder.byTitle,
    super.cachedSelectedItem = SortOrder.byTitle,
    super.values = SortOrder.values,
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  SortOrderState copyWith({
    SortOrder? cachedPlayingItem,
    SortOrder? cachedSelectedItem,
    List<SortOrder>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return SortOrderState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
