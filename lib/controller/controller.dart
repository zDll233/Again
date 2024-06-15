import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final ui = Get.put(UIController());
  final db = Get.put(DatabaseController());

  @override
  void onInit() async {
    super.onInit();
    await _loadCache();
  }

  Future<void> _loadCache() async {
    await ui.loadCache();
    await db.initializeStorage();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 延迟滚动到保存的位置
      await ui.scrollToPlayingOffsets();
      // 恢复上次vi list
      await ui.onVkSelected(ui.playingVkIdx.value);

      await ui.onViSelected(audio.playingViIdx.value);
      await audio.pause();
    });
  }
}
