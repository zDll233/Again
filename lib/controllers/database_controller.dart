import 'dart:io';

import 'package:again/controllers/u_i_controller.dart';
import 'package:again/controllers/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:again/utils/json_storage.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class DatabaseController extends GetxController {
  final AppDatabase database = AppDatabase();
  VoiceUpdater? voiceUpdater;
  String? vkRootDirPath;
  late final JsonStorage storage;

  List<TVoiceWorkData> vkDataList = [];

  Future<void> initializeStorage() async {
    const directoryPath = 'config';
    const fileName = 'settings.json';
    final filePath = p.join(directoryPath, fileName);
    storage = JsonStorage(filePath: filePath);
    await _loadRootDirPath();
  }

  Future<void> _loadRootDirPath() async {
    final data = await storage.read();
    vkRootDirPath = data['vkRootDirPath'] ?? 'E:\\Media\\ACG\\音声';

    if (await Directory(vkRootDirPath!).exists()) {
      await _initializeVoiceUpdater();
      await updateDatabase();
    } else {
      await selectAndSaveDirectory();
    }
  }

  Future<void> _initializeVoiceUpdater() async {
    voiceUpdater = VoiceUpdater(vkRootDirPath!);
  }

  Future<void> selectAndSaveDirectory() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      vkRootDirPath = selectedDirectory;
      await _initializeVoiceUpdater();
      await _saveRootDirPath(vkRootDirPath!);
      await onUpdatePressed();
    }
  }

  Future<void> _saveRootDirPath(String path) async {
    await storage.write({'vkRootDirPath': path});
  }

  Future<void> updateDatabase() async {
    await voiceUpdater!.update();
    await updateViewList();
  }

  Future<void> updateViewList() async {
    await updateFilterLists();
    await updateVkTitleList();
    await updateSelectedViList();
  }

  Future<void> updateFilterLists() async {
    final cvDataList = await database.selectAllCv()
      ..sort((a, b) => compareNatural(a.cvName, b.cvName));
    final categoryDataList = await database.selectAllCategory()
      ..sort((a, b) => compareNatural(a.description, b.description));

    final ui = Get.find<UIController>();
    ui.cvNames
      ..clear()
      ..addAll(cvDataList.map((item) => item.cvName));

    ui.categories
      ..clear()
      ..addAll(categoryDataList.map((item) => item.description));
  }

  /// Updates the vkTitleList based on the selected category and cv.
  Future<void> updateVkTitleList() async {
    final ui = Get.find<UIController>();
    final cateIdx = ui.selectedCategoryIdx.value;
    final cvIdx = ui.selectedCvIdx.value;
    if (cateIdx < 0 || cvIdx < 0) return;

    final cate = ui.categories[cateIdx];
    final cv = ui.cvNames[cvIdx];

    vkDataList = await getVkDataList(cate, cv);
    sortVkLists();
  }

  /// update vkTitle & vkCoverPath lists
  void sortVkLists() {
    final ui = Get.find<UIController>();
    sortVkDataList();
    ui.vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
    ui.vkCoverPathList
      ..clear()
      ..addAll(vkDataList.map((item) => item.coverPath));
  }

  Future<List<TVoiceWorkData>> getVkDataList(String cate, String cv) async {
    if (cate == "All" && cv == "All") {
      return await database.selectAllVoiceWorks;
    } else if (cate == "All") {
      return await database.selectVkWithCv(cv);
    } else if (cv == "All") {
      return await database.selectVkWithCategory(cate);
    } else {
      return await database.selectVkWithCvAndCategory(cv, cate);
    }
  }

  void sortVkDataList({List<TVoiceWorkData>? ls, SortOrder? sortOrder}) {
    final ui = Get.find<UIController>();
    ls ??= vkDataList;
    sortOrder ??= ui.sortOrder.value;
    switch (sortOrder) {
      case SortOrder.byTitle:
        ls.sort((a, b) => compareNatural(a.title, b.title));
        break;
      case SortOrder.byCreatedAt:
        ls.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        break;
    }
  }

  Future<List<TVoiceWorkData>> getSortedVkDataList(String cate, String cv,
      {SortOrder? sortOrder}) async {
    final ui = Get.find<UIController>();
    sortOrder ??= ui.sortOrder.value;
    List<TVoiceWorkData> tempVkDataList = await getVkDataList(cate, cv);
    sortVkDataList(ls: tempVkDataList, sortOrder: sortOrder);
    return tempVkDataList;
  }

  Future<void> updateSelectedViList() async {
    final ui = Get.find<UIController>();
    final viDataList = await database
        .selectSingleWorkVoiceItemsWithString(ui.selectedVkTitle.value)
      ..sort((a, b) => compareNatural(a.title, b.title));

    ui.selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));

    ui.selectedViTitleList
      ..clear()
      ..addAll(viDataList.map((item) => item.title));
  }

  Future<void> onUpdatePressed() async {
    final ui = Get.find<UIController>();
    final playingData = await ui.playingStringMap;
    final selectedData = ui.selectedStringMap;

    await database.transaction(() async {
      final tables = database.allTables.toList().reversed;
      for (final table in tables) {
        await database.delete(table).go();
      }
    });
    await updateDatabase();

    ui.setPlayingIdxByString(
        playingData['category']!, playingData['cv']!, playingData['vk']!);
    ui.setSelectedIdxByString(
        selectedData['category']!, selectedData['cv']!, selectedData['vk']!);
  }
}
