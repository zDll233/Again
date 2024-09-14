import 'package:again/controllers/database_controller.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class CategoryState extends ListState<String> {
  CategoryState({
    super.values = const ["All"],
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  CategoryState copyWith({
    List<String>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return CategoryState(
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    await Get.find<DatabaseController>().updateVkList();
    await UIService(ref).filterSelected();
  }
}

final categoryProvider =
    NotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);
