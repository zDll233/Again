import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final ui = Get.put(UIController());
  final db = Get.put(DatabaseController());
}
