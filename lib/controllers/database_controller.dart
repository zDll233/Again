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
  late final JsonStorage config;

  List<TVoiceWorkData> vkDataList = [];

  /// initialize updater to update db
  Future<void> initializeStorage() async {
    const directoryPath = 'config';
    const fileName = 'config.json';
    final filePath = p.join(directoryPath, fileName);
    config = JsonStorage(filePath: filePath);

    final data = await config.read();
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
    final selectedDirectory =
        await FilePicker.platform.getDirectoryPath(dialogTitle: "请选择音声作品根目录");
    if (selectedDirectory != null) {
      vkRootDirPath = selectedDirectory;
      await _initializeVoiceUpdater();
      await _saveRootDirPath(vkRootDirPath!);
      await onUpdatePressed();
    }
  }

  Future<void> _saveRootDirPath(String path) async {
    await config.write({'vkRootDirPath': path});
  }

  Future<void> updateDatabase() async {
    await voiceUpdater!.update();
  }

  Future<void> updateViewList() async {
    await updateFilterLists();
    await updateVkLists();
    await updateViLists();
  }

  /// update [ui.categories], [ui.cvNames]. If cateLs or cvLs is null, get null ls from db.
  Future<void> updateFilterLists(
      {List<TVoiceWorkCategoryData>? cateLs, List<TCVData>? cvLs}) async {
    final ui = Get.find<UIController>();
    cateLs ??= await getCategoryDataList;
    cvLs ??= await getCvDataList;
    ui.categories
      ..clear()
      ..add("All")
      ..addAll(cateLs
          .where((item) => item.description != "All")
          .map((item) => item.description));

    ui.cvNames
      ..clear()
      ..add("All")
      ..addAll(cvLs
          .where((item) => item.cvName != "All")
          .map((item) => item.cvName));
  }

  Future<List<TVoiceWorkCategoryData>> get getCategoryDataList async {
    return await database.selectAllCategory()
      ..sort((a, b) => compareNatural(a.description, b.description));
  }

  Future<List<TCVData>> get getCvDataList async {
    return await database.selectAllCv()
      ..sort((a, b) => compareNatural(a.cvName, b.cvName));
  }

  /// sort and update [ui.selectedVkTitleList], [ui.vkCoverPathList]. If vkLs is null, get it from db according to playing filters.
  Future<void> updateVkLists({List<TVoiceWorkData>? vkLs}) async {
    final ui = Get.find<UIController>();
    final cateIdx = ui.selectedCategoryIdx.value;
    final cvIdx = ui.selectedCvIdx.value;
    if (cateIdx < 0 || cvIdx < 0) return;

    final cate = ui.categories[cateIdx];
    final cv = ui.cvNames[cvIdx];

    vkDataList = vkLs ?? await _getVkDataList(cate, cv);
    setSortedVkLists();
  }

  Future<List<TVoiceWorkData>> _getVkDataList(String cate, String cv) async {
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

  /// update vkTitle & vkCoverPath lists
  void setSortedVkLists({List<TVoiceWorkData>? ls}) {
    final ui = Get.find<UIController>();
    ls ??= vkDataList;
    sortVkDataList(ls: ls);
    ui.selectedVkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
    ui.selectedVkCoverPathList
      ..clear()
      ..addAll(vkDataList.map((item) => item.coverPath));
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
    List<TVoiceWorkData> tempVkDataList = await _getVkDataList(cate, cv);
    sortVkDataList(ls: tempVkDataList, sortOrder: sortOrder);
    return tempVkDataList;
  }

  /// update [ui.selectedViPathList], [ui.selectedViTitleList]. If viLs is null, get it from db
  Future<void> updateViLists({List<TVoiceItemData>? viLs}) async {
    final ui = Get.find<UIController>();
    viLs ??= await getSelectedViList;
    ui.selectedViPathList
      ..clear()
      ..addAll(viLs.map((item) => item.filePath));
    ui.selectedViTitleList
      ..clear()
      ..addAll(viLs.map((item) => item.title));
  }

  /// select viDataList from db according to [selectedVkTitle]
  Future<List<TVoiceItemData>> get getSelectedViList async {
    final ui = Get.find<UIController>();
    return await database
        .selectSingleWorkVoiceItemsWithString(ui.selectedVkTitle.value)
      ..sort((a, b) => compareNatural(a.title, b.title));
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
    await updateViewList();

    if (playingData.isNotEmpty) {
      ui.setPlayingIdxByString(
          playingData['category']!, playingData['cv']!, playingData['vk']!);
    }
    if (selectedData.isNotEmpty) {
      ui.setSelectedIdxByString(
          selectedData['category']!, selectedData['cv']!, selectedData['vk']!);
    }
  }
}
