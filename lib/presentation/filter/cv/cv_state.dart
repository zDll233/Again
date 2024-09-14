import 'package:again/controllers/database_controller.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CvState extends ListState<String> {
  CvState({
    super.values = const ["All"],
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

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
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    await Get.find<DatabaseController>().updateVkList();
    await UIService(ref).filterSelected();
  }
}

final cvProvider = NotifierProvider<CvNotifier, CvState>(CvNotifier.new);
