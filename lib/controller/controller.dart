import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final audioController = Get.put(AudioController());
  final databaseController = Get.put(DatabaseController());
  final uiController = Get.put(UIController());

  @override
  void onInit() {
    super.onInit();
    databaseController.updateVkTitleList();
  }
}
