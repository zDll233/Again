import 'dart:io';

import 'package:again/controller/u_i_controller.dart';
import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:again/utils/json_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class DatabaseController extends GetxController {
  AppDatabase database = AppDatabase();
  VoiceUpdater? voiceUpdater;
  String? vkRootDirPath;
  late JsonStorage storage;
  final currentDir = Directory.current;
  final directoryPath = 'data/storage';

  var vkDataList = [];

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    const fileName = 'settings.json';
    final filePath =
        p.normalize(p.join(currentDir.path, directoryPath, fileName));
    storage = JsonStorage(filePath: filePath);
    await _loadrootDirPath();
  }

  Future<void> _loadrootDirPath() async {
    final data = await storage.read();
    vkRootDirPath = data.containsKey('vkRootDirPath')
        ? data['vkRootDirPath']
        : 'E:\\Media\\ACG\\音声';

    if (await Directory(vkRootDirPath!).exists()) {
      voiceUpdater = VoiceUpdater(vkRootDirPath!);
      updateDatabase();
    } else {
      selectDirectory();
    }
  }

  Future<void> _saverootDirPath(String path) async {
    await storage.write({'vkRootDirPath': path});
  }

  Future<void> selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      vkRootDirPath = selectedDirectory;
      voiceUpdater = VoiceUpdater(vkRootDirPath!);
      await _saverootDirPath(vkRootDirPath!);
      await onUpdatePressed();
    }
  }

  Future<void> updateDatabase() async {
    await voiceUpdater!.update();
    await updateViewList();
  }

  // view: filter, vk
  Future<void> updateViewList() async {
    await updateFilterLists();
    Get.find<UIController>().updateVkTitleList();
  }

  int _extractNumber(String title) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(title);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return -1; // 返回-1，表示没有找到序号的标题
  }

  int _compareTitle(String a, String b) {
    final numA = _extractNumber(a);
    final numB = _extractNumber(b);
    if (numA == -1 || numB == -1) {
      return a.compareTo(b);
    }
    return numA.compareTo(numB);
  }

  void updateVkTitleList() {
    // 排序逻辑
    switch (Get.find<UIController>().sortOrder.value) {
      case SortOrder.byTitle:
        vkDataList.sort((a, b) => _compareTitle(a.title, b.title));
        break;
      case SortOrder.byCreatedAt:
        vkDataList.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970))); // descend
        break;
    }

    // 更新UIController中的vkTitleList
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateAllVkTitleList() async {
    vkDataList = await database.selectAllVoiceWorks;
    updateVkTitleList();
  }

  Future<void> updateVkTitleListWithCv(String cvName) async {
    vkDataList = await database.selectVkWithCv(cvName);
    updateVkTitleList();
  }

  Future<void> updateVkTitleListWithCategory(String category) async {
    vkDataList = await database.selectVkWithCategory(category);
    updateVkTitleList();
  }

  Future<void> updateVkTitleListWithCvAndCategory(
      String cvName, String category) async {
    vkDataList = await database.selectVkWithCvAndCategory(cvName, category);
    updateVkTitleList();
  }

  Future<void> updateFilterLists() async {
    var cvDataList = await database.selectAllCv();
    var categoryDataList = await database.selectAllCategory();

    Get.find<UIController>().cvNames
      ..clear()
      ..addAll(cvDataList.map((item) => item.cvName));

    Get.find<UIController>().categories
      ..clear()
      ..addAll(categoryDataList.map((item) => item.description));
  }

  Future<void> updateSelectedViLists() async {
    // selected vi path, title list
    var viDataList = await database.selectSingleWorkVoiceItemsWithString(
        Get.find<UIController>().selectedVkTitle.value)
      ..sort((a, b) => _compareTitle(a.title, b.title));

    Get.find<UIController>().selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));

    Get.find<UIController>().selectedViTitleList
      ..clear()
      ..addAll(viDataList.map((item) => item.title));
  }

  Future<void> onUpdatePressed() async {
    await database.transaction(() async {
      // Deleting tables in reverse topological order to avoid foreign-key conflicts
      final tables = database.allTables.toList().reversed;

      for (final table in tables) {
        await database.delete(table).go();
      }
    });
    updateDatabase();
  }
}
