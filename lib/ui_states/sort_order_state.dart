import 'package:again/controllers/database_controller.dart';
import 'package:again/ui_states/state_interface.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

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
  SortOrder get playingItem => values[playingIndex];

  @override
  SortOrder get selectedItem => values[selectedIndex];

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

class SortOrderNotifier extends ListStateNotifier<SortOrderState, SortOrder> {
  @override
  SortOrderState build() {
    Log.debug('SortOrderState rebuilded.');
    return SortOrderState();
  }

  @override
  void updateValues(List<SortOrder> newValues) {
    state = state.copyWith(values: newValues);
  }

  @override
  void updatePlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex);
  }

  @override
  void updateSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex);
  }

  @override
  void updateState(SortOrderState newState) {
    state = state.copyWith(
        values: newState.values,
        playingIndex: newState.playingIndex,
        selectedIndex: newState.playingIndex);
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    updateSelectedIndex(temp < length ? temp : 0);
    await Get.find<DatabaseController>().updateVkList();
    // TODO: await _filterSelected();
  }
}

final sortOrderProvider = NotifierProvider<SortOrderNotifier, SortOrderState>(SortOrderNotifier.new);
