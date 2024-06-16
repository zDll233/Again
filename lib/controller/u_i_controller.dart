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
  var selectedVkTitle = ''.obs;
  var selectedViPathList = <String>[];
  var selectedViTitleList = <String>[].obs;

  var playingVkIdx = (-1).obs;
  var selectedVkIdx = (-1).obs;

  var vkScrollController = ScrollController();
  var cvScrollController = ScrollController();
  var vkOffsetMap = <int, double>{0: 0.0};
  var cvOffsetMap = <int, double>{0: 0.0};

  var cvNames = ['All'].obs;
  var playingCvIdx = 0.obs;
  var selectedCvIdx = 0.obs;

  var categories = ['All'].obs;
  var playingCategoryIdx = 0.obs;
  var selectedCategoryIdx = 0.obs;

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
    await _filterSelected();
  }

  /// Resets the filters and scrolls to the top.
  Future<void> onRemoveFilterPressed() async {
    await _resetFilters();
    await _scrollToTop();
  }

  /// Locates the playing item by updating the selection and scrolling to it.
  Future<void> onLocateBtnPressed() async {
    if (!_isFilterPlaying() || selectedVkIdx.value != playingVkIdx.value) {
      await _setPlayingSelection();
    }
    await scrollToPlayingOffsets();
  }

  Future<void> onCategorySelected(int idx) async {
    await updateWithCategorySelected(idx);
  }

  Future<void> updateWithCategorySelected(int selectedIdx) async {
    selectedCategoryIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    await _filterSelected();
  }

  Future<void> onCvSelected(int idx) async {
    _updateOffset(cvScrollController, cvOffsetMap, idx);

    // locate 用到了此函数，为了offset不被覆盖，分开执行
    await updateWithCvSelected(idx);
  }

  Future<void> updateWithCvSelected(int selectedIdx) async {
    selectedCvIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    await _filterSelected();
  }

  Future<void> onVkSelected(int idx) async {
    _updateOffset(vkScrollController, vkOffsetMap, idx);
    await updateWithVkSelected(idx);
  }

  Future<void> updateWithVkSelected(int selectedIdx) async {
    selectedVkIdx.value = selectedIdx;
    selectedVkTitle.value = vkTitleList[selectedVkIdx.value];
    await Get.find<DatabaseController>().updateSelectedViLists();
  }

  Future<void> onViSelected(int idx) async {
    final AudioController audio = Get.find();
    if (isCurrentViIdxPlaying(idx)) {
      audio.playerState.value == PlayerState.playing
          ? await audio.pause()
          : await audio.resume();
      return;
    }

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

  Future<void> _scrollToTop() async {
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

  bool isCurrentViIdxPlaying(int selectedViIdx) {
    return _isFilterPlaying() &&
        playingVkIdx.value == selectedVkIdx.value &&
        selectedViIdx == Get.find<AudioController>().playingViIdx.value;
  }

  bool _isFilterPlaying() {
    return selectedCvIdx.value == playingCvIdx.value &&
        selectedCategoryIdx.value == playingCategoryIdx.value &&
        sortOrder.value == playingSortOrder;
  }

  /// 在播放的：vk select, vi show;
  /// 不在播放的：vk not select, vi clear;
  Future<void> _filterSelected() async {
    if (_isFilterPlaying()) {
      await updateWithVkSelected(playingVkIdx.value);
    } else {
      selectedVkIdx.value = -1;
      selectedViTitleList.clear();
    }
  }

  void _updateOffset(
      ScrollController controller, Map<int, double> offsetMap, int idx) {
    if (controller.hasClients) {
      var offset = controller.offset;
      offsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
    }
  }

  void _updatePlayingSelection() {
    playingVkIdx.value = selectedVkIdx.value;
    playingCvIdx.value = selectedCvIdx.value;
    playingCategoryIdx.value = selectedCategoryIdx.value;
    playingSortOrder = sortOrder.value;
  }

  Future<void> loadHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;

    final filter = uiHistory['filter'];
    final offset = uiHistory['scrollOffset'];

    // filter vk
    sortOrder.value = playingSortOrder = SortOrder.values[filter['sortOrder']];
    playingCategoryIdx.value = filter['category'];
    playingCvIdx.value = filter['cv'];
    playingVkIdx.value = uiHistory['vk'];
    await onCategorySelected(playingCategoryIdx.value);
    await onCvSelected(playingCvIdx.value);
    await onVkSelected(playingVkIdx.value);

    // scroll
    cvOffsetMap.update(playingCvIdx.value, (value) => offset['cvOffset'],
        ifAbsent: () => offset['cvOffset']);
    vkOffsetMap.update(playingVkIdx.value, (value) => offset['vkOffset'],
        ifAbsent: () => offset['vkOffset']);
  }
}
