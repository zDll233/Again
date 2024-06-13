import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
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

  var cvNames = [].obs;
  var playingCvIdx = 0.obs;
  var selectedCvIdx = 0.obs;

  var categories = [];

  void onRomoveFilterPressed() {
    selectedCvIdx.value = 0;
  }

  Future<void> onLocateBtnPressed() async {
    // cv
    await onCvSelected(playingCvIdx.value);

    // 确保在当前帧结束后执行滚动操作
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // vk
      selectedVkIdx.value = playingVkIdx.value;
      updateSelectedVkTitle(vkTitleList[playingVkIdx.value]);
      await vkScrollController.animateTo(
        vkOffsetMap[playingVkIdx.value]!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    });
  }

  Future<void> onCvSelected(int idx) async {
    selectedCvIdx.value = idx;

    // update vkTitleList
    if (idx == 0) {
      await Get.find<DatabaseController>().updateVkTitleList();
    } else {
      await Get.find<DatabaseController>()
          .updateVkTitleListWithCv(cvNames[idx]);
    }
    selectedVkIdx.value =
        selectedCvIdx.value == playingCvIdx.value ? playingCvIdx.value : -1;
  }

  void onVkSelected(int idx) {
    // update selected vk title, idx
    updateSelectedVkTitle(vkTitleList[idx]);
    selectedVkIdx.value = idx;

    // update offset
    if (playingCvIdx.value == selectedCvIdx.value) {
      var offset = vkScrollController.offset;
      vkOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
    }
  }

  void onViSelected(int idx) {
    // vi
    Get.find<AudioController>().playingViIdx.value = idx;
    Get.find<AudioController>().playingViPathList = selectedViPathList.toList();
    // vk
    playingVkIdx.value = selectedVkIdx.value;
    // cv
    playingCvIdx.value = selectedCvIdx.value;

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
