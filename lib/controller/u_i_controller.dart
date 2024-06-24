import 'dart:async';
import 'dart:io';

import 'package:again/controller/audio_controller.dart';
import 'package:again/controller/database_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:path/path.dart' as p;

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
  late Completer viCompleter;

  final cvNames = ['All'].obs;
  final playingCvIdx = 0.obs;
  final selectedCvIdx = 0.obs;

  final categories = ['All'].obs;
  final playingCategoryIdx = 0.obs;
  final selectedCategoryIdx = 0.obs;

  final sortOrder = SortOrder.byTitle.obs;
  SortOrder playingSortOrder = SortOrder.byTitle;

  final showLrcPanel = false.obs;

  void openSelectedVkFolder() {
    if (selectedViPathList.isNotEmpty) {
      if (_isSelectedVkPlaying) {
        slectPlayingViFile();
      } else {
        Process.run('explorer', [p.dirname(selectedViPathList[0])]);
      }
    }
  }

  void slectPlayingViFile() {
    final AudioController audio = Get.find();
    final playingViPath = audio.playingViPathList[audio.playingViIdx.value];
    Process.run('explorer', ['/select,', playingViPath]);
  }

  /// Resets the filters and scrolls to the top.
  Future<void> onRemoveFilterPressed() async {
    await _resetFilters();
    _scrollToTop();
  }

  /// reset category & cv, except sortOrder
  Future<void> _resetFilters() async {
    selectedCategoryIdx.value = 0;
    await onCvSelected(0);
  }

  /// Locates the playing item by updating the selection and scrolling to it.
  Future<void> onLocateBtnPressed() async {
    if (!_isSelectedVkPlaying) {
      // locate = true;
      await _setFilterPlaying();
    }
    scrollToPlayingIdx();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex(cvScrollController, 0);
      scrollToIndex(vkScrollController, 0);
    });
  }

  void scrollToPlayingIdx() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await viCompleter.future;
        scrollToIndex(cvScrollController, playingCvIdx.value);
        scrollToIndex(vkScrollController, playingVkIdx.value);
        scrollToIndex(
            viScrollController, Get.find<AudioController>().playingViIdx.value);
      });
    });
  }

  void scrollToIndex(ItemScrollController controller, int index,
      {int duration = 200, Curve curve = Curves.linear}) {
    if (index >= 0 && controller.isAttached) {
      controller.scrollTo(
        index: index,
        duration: Duration(milliseconds: duration),
        curve: curve,
      );
    }
  }

  /// set filter playing idx value, update vk list
  ///
  /// filterSelected will open vi list when filter is playing
  Future<void> _setFilterPlaying() async {
    sortOrder.value = playingSortOrder;
    selectedCategoryIdx.value = playingCategoryIdx.value;
    await onCvSelected(playingCvIdx.value);
  }

  /// Toggles the sort order and updates the title list.
  Future<void> onSortOrderPressed() async {
    sortOrder.value = sortOrder.value == SortOrder.byTitle
        ? SortOrder.byCreatedAt
        : SortOrder.byTitle;

    Get.find<DatabaseController>().updateSortedVkTitleList();
    await _filterSelected();
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

  /// 在播放的：vk select, vi show;
  ///
  /// 不在播放的：vk not select, vi clear;
  Future<void> _filterSelected() async {
    if (_isFilterPlaying) {
      await onVkSelected(playingVkIdx.value);
    } else {
      selectedVkIdx.value = -1;
      selectedVkTitle.value = '';
      selectedViTitleList.clear();
    }
  }

  Future<void> onVkSelected(int selectedIdx) async {
    selectedVkIdx.value = selectedIdx;
    selectedVkTitle.value = vkTitleList[selectedVkIdx.value];
    await Get.find<DatabaseController>().updateSelectedViList();
  }

  void onViSelected(int idx) {
    final AudioController audio = Get.find();
    if (isCurrentViIdxPlaying(idx)) {
      audio.switchPauseResume();
      return;
    }

    audio.playingViIdx.value = idx;
    audio.playingViPathList = selectedViPathList.toList();

    _updatePlayingIdx(sortOrder.value, selectedCategoryIdx.value,
        selectedCvIdx.value, selectedVkIdx.value);
    audio.play(DeviceFileSource(audio.playingViPathList[idx]));
  }

  void _updatePlayingIdx(
      SortOrder sortOrder, int cateIdx, int cvIdx, int vkIdx) {
    playingSortOrder = sortOrder;
    playingCategoryIdx.value = cateIdx;
    playingCvIdx.value = cvIdx;
    playingVkIdx.value = vkIdx;
  }

  bool isCurrentViIdxPlaying(int selectedViIdx) {
    return _isSelectedVkPlaying &&
        selectedViIdx == Get.find<AudioController>().playingViIdx.value;
  }

  bool get _isSelectedVkPlaying {
    return _isFilterPlaying && playingVkIdx.value == selectedVkIdx.value;
  }

  bool get _isFilterPlaying {
    return selectedCvIdx.value == playingCvIdx.value &&
        selectedCategoryIdx.value == playingCategoryIdx.value &&
        sortOrder.value == playingSortOrder;
  }

  Future<void> loadHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;

    final filter = uiHistory['filter'];

    // filter vk
    _updatePlayingIdx(SortOrder.values[filter['sortOrder']], filter['category'],
        filter['cv'], uiHistory['vk']);
    await onLocateBtnPressed();
  }
}
