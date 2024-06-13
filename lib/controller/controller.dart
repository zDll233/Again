import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final caudio = Get.put(AudioController());
  final cdb = Get.put(DatabaseController());
  final cui = Get.put(UIController());
}
