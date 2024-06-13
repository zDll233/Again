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

  var playingVkIdx = (-1).obs;
  var selectedVkIdx = (-1).obs;

  var vkScrollController = ScrollController();
  var cvScrollController = ScrollController();
  var vkOffsetMap = {};
  var cvOffsetMap = {};

  var cvNames = [].obs;
  var playingCvIdx = 0.obs;
  var selectedCvIdx = 0.obs;

  var categories = [].obs;
  var playingCategoryIdx = 0.obs;
  var selectedCategoryIdx = 0.obs;

  void onRomoveFilterPressed() {
    selectedCvIdx.value = 0;
    selectedCategoryIdx.value = 0;
  }

  Future<void> onLocateBtnPressed() async {
    // cate
    await onCategorySelected(playingCategoryIdx.value);
    // cv
    await onCvSelected(playingCvIdx.value);

    // 确保在当前帧结束后执行滚动操作
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // vk
      selectedVkIdx.value = playingVkIdx.value;
      updateSelectedVkTitle(vkTitleList[playingVkIdx.value]);

      if (vkOffsetMap.containsKey(playingVkIdx.value) &&
          vkOffsetMap[playingVkIdx.value] != null) {
        await vkScrollController.animateTo(
          vkOffsetMap[playingVkIdx.value]!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }

      if (cvOffsetMap.containsKey(playingCvIdx.value) &&
          cvOffsetMap[playingCvIdx.value] != null) {
        await cvScrollController.animateTo(
          cvOffsetMap[playingCvIdx.value]!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> updateVkTitleList() async {
    var cate = categories[selectedCategoryIdx.value];
    var cv = cvNames[selectedCvIdx.value];

    if (cate == "All" && cv == "All") {
      await Get.find<DatabaseController>().updateAllVkTitleList();
    } else if (cate == "All" && cv != "All") {
      await Get.find<DatabaseController>().updateVkTitleListWithCv(cv);
    } else if (cate != "All" && cv == "All") {
      await Get.find<DatabaseController>().updateVkTitleListWithCategory(cate);
    } else {
      await Get.find<DatabaseController>()
          .updateVkTitleListWithCvAndCategory(cv, cate);
    }
  }

  Future<void> onCategorySelected(int idx) async {
    selectedCategoryIdx.value = idx;

    // update vkTitleList
    await updateVkTitleList();
    // vk idx
    selectedVkIdx.value = selectedCategoryIdx.value == playingCategoryIdx.value
        ? playingVkIdx.value
        : -1;
  }

  Future<void> onCvSelected(int idx) async {
    selectedCvIdx.value = idx;

    // update vkTitleList
    await updateVkTitleList();
    // vk idx
    selectedVkIdx.value =
        selectedCvIdx.value == playingCvIdx.value ? playingVkIdx.value : -1;

    if (playingCvIdx.value != selectedCvIdx.value) {
      var offset = cvScrollController.offset;
      cvOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
    }
    // print("cvOffsetMap: ${cvOffsetMap[selectedCvIdx.value]}"); // 添加调试信息
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
