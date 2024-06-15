import 'dart:io';

import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SortOrder {
  byTitle,
  byCreatedAt,
}

class UIController extends GetxController {
  var vkTitleList = <String>[].obs;
  var selectedVkTitle = "".obs;
  var selectedViPathList = <String>[];
  var selectedViTitleList = <String>[].obs;

  var playingVkIdx = (-1).obs;
  var selectedVkIdx = (-1).obs;

  var vkScrollController = ScrollController();
  var cvScrollController = ScrollController();
  var vkOffsetMap = <int, double>{0: 0.0};
  var cvOffsetMap = <int, double>{0: 0.0};

  var cvNames = ["All"].obs;
  var playingCvIdx = 0.obs;
  var selectedCvIdx = 0.obs;

  var categories = ["All"].obs;
  var playingCategoryIdx = 0.obs;
  var selectedCategoryIdx = 0.obs;

  var lastCategoryIdx = -1;
  var lastCvIdx = -1;
  var lastVkIdx = -1;

  var sortOrder = SortOrder.byTitle.obs;
  var playingSortOrder = SortOrder.byTitle;

  Future<void> onOpenSelectedVkFolder() async {
    if (selectedViPathList.isNotEmpty) {
      Directory directory = File(selectedViPathList[0]).parent;

      if (await directory.exists()) {
        Process.run('explorer', [directory.path]); // Windows
      }
    }
  }

  /// Toggles the sort order and updates the title list.
  Future<void> onSortOrderPressed() async {
    sortOrder.value = sortOrder.value == SortOrder.byTitle
        ? SortOrder.byCreatedAt
        : SortOrder.byTitle;

    Get.find<DatabaseController>().updateSortedVkTitleList();
    _updateSelectedVkIdx();
  }

  /// Resets the filters and scrolls to the top.
  Future<void> onRemoveFilterPressed() async {
    await _resetFilters();
    _scrollToTop();
  }

  /// Locates the playing item by updating the selection and scrolling to it.
  Future<void> onLocateBtnPressed() async {
    await _setPlayingSelection();
    scrollToPlayingOffsets();
  }

  Future<void> onCategorySelected(int idx) async {
    await updateWithCategorySelected(idx);
  }

  Future<void> updateWithCategorySelected(int selectedIdx) async {
    selectedCategoryIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    _updateSelectedVkIdx();
  }

  Future<void> onCvSelected(int idx) async {
    await updateWithCvSelected(idx);
    _updateOffset(cvScrollController, cvOffsetMap, idx);
  }

  Future<void> updateWithCvSelected(int selectedIdx) async {
    selectedCvIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    _updateSelectedVkIdx();
  }

  Future<void> onVkSelected(int idx) async {
    await updateWithVkSelected(idx);
    _storeLastSelection();
    _updateOffset(vkScrollController, vkOffsetMap, idx);
  }

  Future<void> updateWithVkSelected(int selectedIdx) async {
    selectedVkIdx.value = selectedIdx;
    selectedVkTitle.value = vkTitleList[selectedVkIdx.value];
    await Get.find<DatabaseController>().updateSelectedViLists();
  }

  Future<void> onViSelected(int idx) async {
    final AudioController audio = Get.find();
    audio.playingViIdx.value = idx;
    audio.playingViPathList = selectedViPathList.toList();

    _updatePlayingSelection();
    await audio.play(DeviceFileSource(audio.playingViPathList[idx]));
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

  Future<void> _resetFilters() async {
    await updateWithCategorySelected(0);
    await updateWithCvSelected(0);
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        scrollToOffset(cvScrollController, 0, duration: 200),
        scrollToOffset(vkScrollController, 0, duration: 200)
      ]);
    });
  }

  Future<void> _setPlayingSelection() async {
    sortOrder.value = playingSortOrder;
    await updateWithCategorySelected(playingCategoryIdx.value);
    await updateWithCvSelected(playingCvIdx.value);
    await updateWithVkSelected(playingVkIdx.value);
  }

  Future<void> scrollToPlayingOffsets() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (cvScrollController.hasClients && vkScrollController.hasClients) {
        await Future.wait([
          scrollToOffset(cvScrollController, cvOffsetMap[playingCvIdx.value],
              duration: 200),
          scrollToOffset(vkScrollController, vkOffsetMap[playingVkIdx.value],
              duration: 200)
        ]);
      }
    });
  }

  void _updateSelectedVkIdx() {
    selectedVkIdx.value = selectedCvIdx.value == playingCvIdx.value &&
            selectedCategoryIdx.value == playingCategoryIdx.value &&
            sortOrder.value == playingSortOrder
        ? playingVkIdx.value
        : -1;
  }

  void _updateOffset(
      ScrollController controller, Map<int, double> offsetMap, int idx) {
    if (controller.hasClients) {
      var offset = controller.offset;
      offsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
    }
  }

  void _storeLastSelection() {
    lastCategoryIdx = selectedCategoryIdx.value;
    lastCvIdx = selectedCvIdx.value;
    lastVkIdx = selectedVkIdx.value;
  }

  void _updatePlayingSelection() {
    // 不等于-1说明肯定点击了某个vk, 此时vi list变了
    if (selectedVkIdx.value != -1) {
      playingVkIdx.value = selectedVkIdx.value;
      playingCvIdx.value = selectedCvIdx.value;
      playingCategoryIdx.value = selectedCategoryIdx.value;
    } else {
      // 等于-1说明点击了Filter，且Filter对应非正在播放的vk, vi list是 *上次点击vk* 时list
      playingVkIdx.value = lastVkIdx;
      playingCvIdx.value = lastCvIdx;
      playingCategoryIdx.value = lastCategoryIdx;
    }
    playingSortOrder = sortOrder.value;
  }

  Future<void> loadCache(Map<String, dynamic> uiCache) async {
    if (uiCache.isEmpty) return;

    final filter = uiCache['filter'];
    final offset = uiCache['scrollOffset'];

    // filter
    sortOrder.value = playingSortOrder = SortOrder.values[filter['sortOrder']];
    playingCategoryIdx.value = filter['category'];
    playingCvIdx.value = filter['cv'];
    await onCategorySelected(playingCategoryIdx.value);
    await onCvSelected(playingCvIdx.value);

    // vk
    playingVkIdx.value = uiCache['vk'];
    await onVkSelected(playingVkIdx.value);

    // scroll
    cvOffsetMap.update(playingCvIdx.value, (value) => offset['cvOffset'],
        ifAbsent: () => offset['cvOffset']);
    vkOffsetMap.update(playingVkIdx.value, (value) => offset['vkOffset'],
        ifAbsent: () => offset['vkOffset']);
  }
}
