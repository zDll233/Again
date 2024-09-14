import 'package:again/ui/state_interface.dart';

enum SortOrder {
  byTitle,
  byCreatedAt,
}

class SortOrderState extends ListState<SortOrder> {
  SortOrderState(
      {super.values = SortOrder.values,
      super.playingIndex = 0,
      super.selectedIndex = 0});


  @override
  SortOrderState copyWith(
      {List<SortOrder>? values, int? playingIndex, int? selectedIndex}) {
    return SortOrderState(
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}