import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UIController extends GetxController {
  var selectedVkTitle = "".obs;
  var selectedViPathList = [];

  var playingVkIdx = 0.obs;
  var selectedVkIdx = 0.obs;

  var vkScrollController = ScrollController();
  var vkOffsetMap = {};

  void onLocateBtnPressed() {
    vkScrollController.animateTo(vkOffsetMap[playingVkIdx],
        duration: const Duration(microseconds: 300), curve: Curves.bounceIn);

    selectedVkIdx.value = playingVkIdx.value;
    setSelectedVkTitle(
        Get.find<DatabaseController>().vkTitleList[playingVkIdx.value]);
  }

  void onVkSelected(int idx) {
    setSelectedVkTitle(Get.find<DatabaseController>().vkTitleList[idx]);
    selectedVkIdx.value = idx;

    var offset = vkScrollController.offset;
    vkOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
  }

  void onViSelected(int idx) {
    Get.find<AudioController>().playingViIdx.value = idx;
    Get.find<UIController>().playingVkIdx.value = selectedVkIdx.value;
    Get.find<AudioController>().playingViPathList = selectedViPathList.toList();

    Source source =
        DeviceFileSource(Get.find<AudioController>().playingViPathList[idx]);
    Get.find<AudioController>().play(source);
  }

  void setSelectedVkTitle(String title) {
    selectedVkTitle.value = title;
  }
}
