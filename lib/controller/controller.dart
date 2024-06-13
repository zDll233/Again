import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final database = Get.put(DatabaseController());
  final ui = Get.put(UIController());

  // @override
  // void onInit() {
  //   super.onInit();
  //   database.updateDatabase();
  // }
}
