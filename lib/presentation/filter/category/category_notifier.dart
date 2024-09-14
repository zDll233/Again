import 'package:again/controllers/database_controller.dart';
import 'package:again/presentation/filter/category/category_state.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:get/get.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    // TODO: DatabaseController
    updateSelectedIndex(selectedIndex);
    await Get.find<DatabaseController>().updateVkList();
    await UIService(ref).filterSelected();
  }
}