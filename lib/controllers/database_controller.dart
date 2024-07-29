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

  var vkDataList = [];

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

    if (cate == "All" && cv == "All") {
      await updateAllVkTitleList();
    } else if (cate == "All") {
      await updateVkTitleListWithCv(cv);
    } else if (cv == "All") {
      await updateVkTitleListWithCategory(cate);
    } else {
      await updateVkTitleListWithCvAndCategory(cv, cate);
    }
  }

  Future<void> updateAllVkTitleList() async {
    vkDataList = await database.selectAllVoiceWorks;
    updateSortedVkLists();
  }

  Future<void> updateVkTitleListWithCv(String cvName) async {
    vkDataList = await database.selectVkWithCv(cvName);
    updateSortedVkLists();
  }

  Future<void> updateVkTitleListWithCategory(String category) async {
    vkDataList = await database.selectVkWithCategory(category);
    updateSortedVkLists();
  }

  Future<void> updateVkTitleListWithCvAndCategory(
      String cvName, String category) async {
    vkDataList = await database.selectVkWithCvAndCategory(cvName, category);
    updateSortedVkLists();
  }

  void updateSortedVkLists() {
    final ui = Get.find<UIController>();
    switch (ui.sortOrder.value) {
      case SortOrder.byTitle:
        vkDataList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.byCreatedAt:
        vkDataList.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        break;
    }

    ui.vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
    ui.vkCoverPathList
      ..clear()
      ..addAll(vkDataList.map((item) => item.coverPath));
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
    await database.transaction(() async {
      final tables = database.allTables.toList().reversed;
      for (final table in tables) {
        await database.delete(table).go();
      }
    });
    await updateDatabase();
  }
}
