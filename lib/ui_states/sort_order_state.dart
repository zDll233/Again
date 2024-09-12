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
  Future<void> onSelected(int selectedIndex) async {
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    updateSelectedIndex(temp < length ? temp : 0);
    await Get.find<DatabaseController>().updateVkList();
    // TODO: await _filterSelected();
  }
}

final sortOrderProvider = NotifierProvider<SortOrderNotifier, SortOrderState>(SortOrderNotifier.new);
