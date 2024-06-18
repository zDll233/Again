import 'dart:io';

import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

enum SortOrder {
  byTitle,
  byCreatedAt,
}

class UIController extends GetxController {
  final vkTitleList = <String>[].obs;
  final selectedVkTitle = ''.obs;
  final selectedViPathList = <String>[];
  final selectedViTitleList = <String>[].obs;

  final playingVkIdx = (-1).obs;
  final selectedVkIdx = (-1).obs;

  final cvScrollController = ItemScrollController();
  final vkScrollController = ItemScrollController();
  final viScrollController = ItemScrollController();

  final cvNames = ['All'].obs;
  final playingCvIdx = 0.obs;
  final selectedCvIdx = 0.obs;

  final categories = ['All'].obs;
  final playingCategoryIdx = 0.obs;
  final selectedCategoryIdx = 0.obs;

  final sortOrder = SortOrder.byTitle.obs;
  SortOrder playingSortOrder = SortOrder.byTitle;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await scrollToPlayingIdx();
    });
  }

  Future<void> onCategorySelected(int selectedIdx) async {
    selectedCategoryIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    await _filterSelected();
  }

  Future<void> onCvSelected(int selectedIdx) async {
    selectedCvIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkTitleList();
    await _filterSelected();
  }

  Future<void> onVkSelected(int selectedIdx) async {
    selectedVkIdx.value = selectedIdx;
    selectedVkTitle.value = vkTitleList[selectedVkIdx.value];
    await Get.find<DatabaseController>().updateSelectedViLists();
  }

  Future<void> onViSelected(int idx) async {
    final AudioController audio = Get.find();
    if (isCurrentViIdxPlaying(idx)) {
      await audio.switchPauseResume();
      return;
    }

    audio.playingViIdx.value = idx;
    audio.playingViPathList = selectedViPathList.toList();

    _updatePlayingIdx(sortOrder.value, selectedCategoryIdx.value,
        selectedCvIdx.value, selectedVkIdx.value);
    await audio.play(DeviceFileSource(audio.playingViPathList[idx]));
  }

  Future<void> scrollToOffset(ScrollController controller, double? offset,
      {int duration = 200}) async {
    if (offset != null && controller.hasClients) {
      await controller.animateTo(
        offset,
        duration: Duration(milliseconds: duration),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> scrollToIndex(ItemScrollController controller, int? index,
      {int duration = 200}) async {
    if (index != null && controller.isAttached) {
      await controller.scrollTo(
        index: index,
        duration: Duration(milliseconds: duration),
        curve: Curves.ease,
      );
    }
  }

  /// reset category & cv, except sortOrder
  Future<void> _resetFilters() async {
    selectedCategoryIdx.value = 0;
    await onCvSelected(0);
  }

  Future<void> _scrollToTop() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        scrollToIndex(cvScrollController, 0, duration: 200),
        scrollToIndex(vkScrollController, 0, duration: 200),
      ]);
    });
  }

  Future<void> _setPlayingSelection() async {
    sortOrder.value = playingSortOrder;
    selectedCategoryIdx.value = playingCategoryIdx.value;
    await onCvSelected(playingCvIdx.value);
    await onVkSelected(playingVkIdx.value);
  }

  Future<void> scrollToPlayingIdx() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        scrollToIndex(cvScrollController, playingCvIdx.value, duration: 200),
        scrollToIndex(vkScrollController, playingVkIdx.value, duration: 200),
        scrollToIndex(
            viScrollController, Get.find<AudioController>().playingViIdx.value,
            duration: 200)
      ]);
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
      await onVkSelected(playingVkIdx.value);
    } else {
      selectedVkIdx.value = -1;
      selectedViTitleList.clear();
    }
  }

  void _updatePlayingIdx(
      SortOrder sortOrder, int cateIdx, int cvIdx, int vkIdx) {
    playingSortOrder = sortOrder;
    playingCategoryIdx.value = cateIdx;
    playingCvIdx.value = cvIdx;
    playingVkIdx.value = vkIdx;
  }

  Future<void> loadHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;

    final filter = uiHistory['filter'];

    // filter vk
    _updatePlayingIdx(SortOrder.values[filter['sortOrder']], filter['category'],
        filter['cv'], uiHistory['vk']);
    await _setPlayingSelection();
  }
}
