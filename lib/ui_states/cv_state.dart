import 'package:again/controllers/database_controller.dart';
import 'package:again/ui_states/state_interface.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CvState extends ListState<String> {
  CvState({
    super.values = const ["All"],
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  String get playingItem => values[playingIndex];

  @override
  String get selectedItem => values[selectedIndex];

  @override
  CvState copyWith({
    List<String>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return CvState(
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    Log.debug('CvState rebuilded.');
    return CvState();
  }

  @override
  void updateValues(List<String> newValues) {
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
  void updateState(CvState newState) {
    state = state.copyWith(
        values: newState.values,
        playingIndex: newState.playingIndex,
        selectedIndex: newState.playingIndex);
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    await Get.find<DatabaseController>().updateVkList();
    // TODO: await _filterSelected();
  }
}

final cvProvider = NotifierProvider<CvNotifier, CvState>(CvNotifier.new);
