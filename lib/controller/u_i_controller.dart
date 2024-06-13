import 'package:again/controller/audio_controller.dart';
import 'package:again/database/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UIController extends GetxController {
  var vkTitleList = [].obs;
  var selectedVkTitle = "".obs;
  var selectedViPathList = [];
  var selectedViTitleList = [].obs;

  var playingVkIdx = 0.obs;
  var selectedVkIdx = 0.obs;

  var vkScrollController = ScrollController();
  var vkOffsetMap = {};

  void onLocateBtnPressed() {
    vkScrollController.animateTo(vkOffsetMap[playingVkIdx],
        duration: const Duration(microseconds: 300), curve: Curves.bounceIn);

    selectedVkIdx.value = playingVkIdx.value;
    updateSelectedVkTitle(vkTitleList[playingVkIdx.value]);
  }

  void onVkSelected(int idx) {
    // update selected vk title, idx
    updateSelectedVkTitle(vkTitleList[idx]);
    selectedVkIdx.value = idx;

    // update offset
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

  void updateSelectedVkTitle(String title) async {
    selectedVkTitle.value = title;

    // selected vi path, title list
    var viDataList = await database
        .selectSingleWorkVoiceItemsWithString(selectedVkTitle.value);
    selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));
    selectedViTitleList
      ..clear()
      ..addAll(viDataList.map((item) => item.title));
  }
}
