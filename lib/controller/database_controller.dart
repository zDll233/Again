import 'dart:io';

import 'package:again/controller/u_i_controller.dart';
import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:again/utils/json_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class DatabaseController extends GetxController {
  final AppDatabase database = AppDatabase();
  VoiceUpdater? voiceUpdater;
  String? vkRootDirPath;
  late JsonStorage storage;

  var vkDataList = [];

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    const String directoryPath = 'config';
    const fileName = 'settings.json';
    final filePath = p.join(directoryPath, fileName);
    storage = JsonStorage(filePath: filePath);
    await _loadRootDirPath();
  }

  Future<void> _loadRootDirPath() async {
    final data = await storage.read();
    vkRootDirPath = data['vkRootDirPath'] ?? 'E:\\Media\\ACG\\音声';

    if (await Directory(vkRootDirPath!).exists()) {
      _initializeVoiceUpdater();
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
    Get.find<UIController>().updateVkTitleList();
  }

  int _extractNumber(String title) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(title);
    return match != null ? int.parse(match.group(1)!) : -1;
  }

  int _compareTitle(String a, String b) {
    final numA = _extractNumber(a);
    final numB = _extractNumber(b);
    if (numA == -1 || numB == -1) {
      return a.compareTo(b);
    }
    return numA.compareTo(numB);
  }

  void updateSortedVkTitleList() {
    final uiController = Get.find<UIController>();
    switch (uiController.sortOrder.value) {
      case SortOrder.byTitle:
        vkDataList.sort((a, b) => _compareTitle(a.title, b.title));
        break;
      case SortOrder.byCreatedAt:
        vkDataList.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        break;
    }

    uiController.vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateAllVkTitleList() async {
    vkDataList = await database.selectAllVoiceWorks;
    updateSortedVkTitleList();
  }

  Future<void> updateVkTitleListWithCv(String cvName) async {
    vkDataList = await database.selectVkWithCv(cvName);
    updateSortedVkTitleList();
  }

  Future<void> updateVkTitleListWithCategory(String category) async {
    vkDataList = await database.selectVkWithCategory(category);
    updateSortedVkTitleList();
  }

  Future<void> updateVkTitleListWithCvAndCategory(
      String cvName, String category) async {
    vkDataList = await database.selectVkWithCvAndCategory(cvName, category);
    updateSortedVkTitleList();
  }

  Future<void> updateFilterLists() async {
    final cvDataList = await database.selectAllCv();
    final categoryDataList = await database.selectAllCategory();

    final uiController = Get.find<UIController>();
    uiController.cvNames
      ..clear()
      ..addAll(cvDataList.map((item) => item.cvName));

    uiController.categories
      ..clear()
      ..addAll(categoryDataList.map((item) => item.description));
  }

  Future<void> updateSelectedViLists() async {
    final uiController = Get.find<UIController>();
    final viDataList = await database.selectSingleWorkVoiceItemsWithString(
        uiController.selectedVkTitle.value)
      ..sort((a, b) => _compareTitle(a.title, b.title));

    uiController.selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));

    uiController.selectedViTitleList
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
