import 'package:again/controllers/database_controller.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:get/get.dart';

class SortOrderNotifier extends ListStateNotifier<SortOrderState, SortOrder> {
  @override
  SortOrderState build() {
    return SortOrderState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    // TODO: DatabaseController
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    updateSelectedIndex(temp < length ? temp : 0);
    await Get.find<DatabaseController>().updateVkList();
    await UIService(ref).filterSelected();
  }
}