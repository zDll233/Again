import 'package:again/controllers/database_controller.dart';
import 'package:again/presentation/filter/cv/cv_state.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:get/get.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    // TODO: DatabaseController
    updateSelectedIndex(selectedIndex);
    await Get.find<DatabaseController>().updateVkList();
    await UIService(ref).filterSelected();
  }
}
