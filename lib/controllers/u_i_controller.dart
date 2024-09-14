import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:again/controllers/audio_controller.dart';
import 'package:again/controllers/database_controller.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/utils/log.dart';
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
  // category
  final categories = ["All"].obs;
  final playingCategoryIdx = 0.obs;
  final selectedCategoryIdx = 0.obs;
  String get playingCate => categories[playingCategoryIdx.value];
  String get selectedCate => categories[selectedCategoryIdx.value];

  // cv
  final cvNames = ["All"].obs;
  final playingCvIdx = 0.obs;
  final selectedCvIdx = 0.obs;
  String get playingCv => cvNames[playingCvIdx.value];
  String get selectedCv => cvNames[selectedCvIdx.value];

  // sort
  final sortOrder = SortOrder.byTitle.obs;
  SortOrder playingSortOrder = SortOrder.byTitle;

  // vk
  final selectedVkList = <VoiceWork>[].obs;
  final playingVkIdx = (-1).obs;
  final selectedVkIdx = (-1).obs;

  Future<List<String>> get playingVkPathList async => await Get.find<
          DatabaseController>()
      .getSortedVkDataList(playingCate, playingCv, sortOrder: playingSortOrder)
      .then((vkDataList) => vkDataList.map((vk) => vk.directoryPath).toList());

  List<String> get selectedVkPathList =>
      selectedVkList.map((vkData) => vkData.directoryPath).toList();

  Future<String> get playingVkPath async => playingVkIdx.value >= 0
      ? await playingVkPathList.then((vkPathList) =>
          playingVkIdx.value < vkPathList.length
              ? vkPathList[playingVkIdx.value]
              : "")
      : "";

  String get selectedVkPath =>
      selectedVkIdx.value >= 0 ? selectedVkPathList[selectedVkIdx.value] : "";

  // vi
  final selectedViList = <VoiceItem>[].obs;
  List<String> get selectedViPathList =>
      selectedViList.map((vi) => vi.filePath).toList();

  final cateScrollController = ItemScrollController();
  final cvScrollController = ItemScrollController();
  final vkScrollController = ItemScrollController();
  final viScrollController = ItemScrollController();
  late Completer viCompleter;

  final showLrcPanel = false.obs;

  Future<void> revealInExplorerView() async {
    final db = Get.find<DatabaseController>();
    VoiceWork vk = await db.getVkByPath(selectedVkPath);

    if (_isSelectedVkPlaying) {
      selectPlayingViFile();
    } else {
      Process.run('explorer /select, "${vk.directoryPath}"', []);
    }
  }

  void selectPlayingViFile() {
    // flutter will replace " with /" in arg list. weird
    // code below doesn't work
    // Process.run('explorer', ['/select,', '"$playingViPath"']); // wrap path in "" so that Windows can resolve it
    Process.run(
        'explorer /select, "${Get.find<AudioController>().playingViPath}"', []);
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
      await _setFilterPlaying();
    }
    scrollToPlayingIdx();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex(cateScrollController, 0);
      scrollToIndex(cvScrollController, 0);
      scrollToIndex(vkScrollController, 0);
    });
  }

  void scrollToPlayingIdx() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await viCompleter.future;
        scrollToIndex(cateScrollController, playingCategoryIdx.value);
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

    Get.find<DatabaseController>().setSortedVkList();
    await _filterSelected();
  }

  Future<void> onCategorySelected(int selectedIdx) async {
    selectedCategoryIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkList();
    await _filterSelected();
  }

  Future<void> onCvSelected(int selectedIdx) async {
    selectedCvIdx.value = selectedIdx;
    await Get.find<DatabaseController>().updateVkList();
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
      selectedViList.clear();
    }
  }

  Future<void> onVkSelected(int selectedIdx) async {
    if (selectedIdx < 0) return;

    final DatabaseController db = Get.find();
    selectedVkIdx.value = selectedIdx;
    await db.updateViList();
  }

  void onViSelected(int idx) {
    final AudioController audio = Get.find();
    if (isCurrentViIdxPlaying(idx)) {
      audio.switchPauseResume();
      return;
    }

    audio.playingViIdx.value = idx;
    audio.playingViPathList = selectedViPathList;

    _updatePlayingIdx(sortOrder.value, selectedCategoryIdx.value,
        selectedCvIdx.value, selectedVkIdx.value);
    audio.play(DeviceFileSource(audio.playingViPath));
  }

  void _updatePlayingIdx(
      SortOrder sortOrder, int cateIdx, int cvIdx, int vkIdx) {
    playingSortOrder = sortOrder;
    playingCategoryIdx.value = cateIdx;
    playingCvIdx.value = cvIdx;
    playingVkIdx.value = vkIdx;
  }

  Future<Map<String, String>> get playingStringMap async {
    try {
      return {
        'category': playingCate,
        'cv': playingCv,
        'vk': await playingVkPath,
      };
    } catch (e) {
      Log.debug('Error getting playingStringMap.\n$e.\n'
          'playingCategoryIdx: ${playingCategoryIdx.value}\n'
          'playingCvIdx: ${playingCvIdx.value}');
      return {};
    }
  }

  Map<String, String> get selectedStringMap {
    try {
      return {
        'category': selectedCate,
        'cv': selectedCv,
        'vk': selectedVkPath,
      };
    } catch (e) {
      Log.debug('Error getting selectedStringMap.\n$e');
      return {};
    }
  }

  Future<void> setPlayingIdxByString(String cate, String cv, String vk,
      {SortOrder? sort}) async {
    playingSortOrder = sort ?? sortOrder.value;
    playingCategoryIdx.value = max(categories.indexOf(cate), 0);
    playingCvIdx.value = max(cvNames.indexOf(cv), 0);
    playingVkIdx.value = (await playingVkPathList).indexOf(vk);
  }

  void setSelectedIdxByString(String cate, String cv, String vk) {
    selectedCategoryIdx.value = max(categories.indexOf(cate), 0);
    selectedCvIdx.value = max(cvNames.indexOf(cv), 0);
    selectedVkIdx.value = selectedVkPathList.indexOf(vk);
  }

  bool isCurrentViIdxPlaying(int selectedViIdx) {
    return _isSelectedVkPlaying &&
        selectedViIdx == Get.find<AudioController>().playingViIdx.value;
  }

  Future<bool> isCurrentVkPlaying(String vkPath) async =>
      await playingVkPath == vkPath;

  bool get _isSelectedVkPlaying =>
      _isFilterPlaying && playingVkIdx.value == selectedVkIdx.value;

  bool get _isFilterPlaying =>
      selectedCvIdx.value == playingCvIdx.value &&
      selectedCategoryIdx.value == playingCategoryIdx.value &&
      sortOrder.value == playingSortOrder &&
      Get.find<AudioController>().playingViIdx.value >= 0;

  Future<void> loadHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;

    final filter = uiHistory['filter'];

    // filter vk
    await setPlayingIdxByString(
        filter['category'], filter['cv'], uiHistory['vk'],
        sort: SortOrder.values[filter['sortOrder']]);

    // vi
    Get.find<AudioController>().playingViIdx.value = uiHistory['vi'];

    await onLocateBtnPressed();
  }
}
