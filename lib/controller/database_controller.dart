import 'package:again/controller/u_i_controller.dart';
import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  Future<void> updateDatabase() async {
    await voiceUpdater.update();
    await updateViewList();
  }

  // view: filter, vk
  Future<void> updateViewList() async {
    Get.find<UIController>().updateVkTitleList();
    await updateFilterLists();
  }

  void updateVkTitleList(List<TVoiceWorkData> vkDataList) {
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateAllVkTitleList() async {
    var vkDataList = await database.selectAllVoiceWorks;
    updateVkTitleList(vkDataList);
  }

  Future<void> updateVkTitleListWithCv(String cvName) async {
    var vkDataList = await database.selectVkWithCv(cvName);
    updateVkTitleList(vkDataList);
  }

  Future<void> updateVkTitleListWithCategory(String category) async {
    var vkDataList = await database.selectVkWithCategory(category);
    updateVkTitleList(vkDataList);
  }

  Future<void> updateVkTitleListWithCvAndCategory(
      String cvName, String category) async {
    var vkDataList = await database.selectVkWithCvAndCategory(cvName, category);
    updateVkTitleList(vkDataList);
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
        Get.find<UIController>().selectedVkTitle.value);

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
