import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
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

  var cvNames = ["All"].obs;
  var playingCvIdx = 0.obs;
  var selectedCvIdx = 0.obs;

  var categories = ["All"].obs;
  var playingCategoryIdx = 0.obs;
  var selectedCategoryIdx = 0.obs;

  Future<void> onRomoveFilterPressed() async {
    // cate
    await updateWithCategorySelected(0);
    // cv
    await updateWithCvSelected(0);

    // 确保在当前帧结束后执行滚动操作
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollToOffset(cvScrollController, 0, duration: 200);
      scrollToOffset(vkScrollController, 0, duration: 200);
    });
  }

  Future<void> onLocateBtnPressed() async {
    // cate
    await updateWithCategorySelected(playingCategoryIdx.value);
    // cv
    await updateWithCvSelected(playingCvIdx.value);
    // vk
    await updateWithVkSelected(playingVkIdx.value);

    // 确保在当前帧结束后执行滚动操作
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollToOffset(cvScrollController, cvOffsetMap[playingCvIdx.value],
          duration: 200);
      scrollToOffset(vkScrollController, vkOffsetMap[playingVkIdx.value],
          duration: 200);
    });
  }

  Future<void> updateVkTitleList() async {
    var cate = categories[selectedCategoryIdx.value];
    var cv = cvNames[selectedCvIdx.value];

    DatabaseController dc = Get.find<DatabaseController>();

    if (cate == "All" && cv == "All") {
      await dc.updateAllVkTitleList();
    } else if (cate == "All") {
      await dc.updateVkTitleListWithCv(cv);
    } else if (cv == "All") {
      await dc.updateVkTitleListWithCategory(cate);
    } else {
      await dc.updateVkTitleListWithCvAndCategory(cv, cate);
    }
  }

  Future<void> onCategorySelected(int idx) async {
    updateWithCategorySelected(idx);
  }

  Future<void> updateWithCategorySelected(int seletedIdx) async {
    selectedCategoryIdx.value = seletedIdx;

    // update vkTitleList
    await updateVkTitleList();

    // 点击别的cate后不会有相同位置的vk显示被选中，cv中同
    // vk idx
    selectedVkIdx.value = selectedCategoryIdx.value == playingCategoryIdx.value
        ? playingVkIdx.value
        : -1;
  }

  Future<void> onCvSelected(int idx) async {
    updateWithCvSelected(idx);

    var offset = cvScrollController.offset;
    cvOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
  }

  Future<void> updateWithCvSelected(int seletedIdx) async {
    selectedCvIdx.value = seletedIdx;

    // update vkTitleList
    await updateVkTitleList();
    // vk idx
    selectedVkIdx.value =
        selectedCvIdx.value == playingCvIdx.value ? playingVkIdx.value : -1;
  }

  Future<void> onVkSelected(int idx) async {
    updateWithVkSelected(idx);

    // update offset
    if (playingCvIdx.value == selectedCvIdx.value &&
        playingCategoryIdx.value == selectedCategoryIdx.value) {
      var offset = vkScrollController.offset;
      vkOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
    }
  }

  // update selected vk title/idx, selected Vi Path/title List
  Future<void> updateWithVkSelected(int seletedIdx) async {
    selectedVkIdx.value = seletedIdx;
    selectedVkTitle.value = vkTitleList[selectedVkIdx.value];

    // update vi lists
    Get.find<DatabaseController>().updateSelectedViLists();
  }

  Future<void> onViSelected(int idx) async {
    final AudioController ac = Get.find();
    // vi
    ac.playingViIdx.value = idx;
    ac.playingViPathList = selectedViPathList.toList();
    // vk
    playingVkIdx.value = selectedVkIdx.value;
    // cv
    playingCvIdx.value = selectedCvIdx.value;
    // cate
    playingCategoryIdx.value = selectedCategoryIdx.value;

    Source source = DeviceFileSource(ac.playingViPathList[idx]);
    ac.play(source);
  }

  Future<void> scrollToOffset(ScrollController controller, double? offset,
      {int duration = 200}) async {
    if (offset != null) {
      await controller.animateTo(
        offset,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
      );
    }
  }
}
