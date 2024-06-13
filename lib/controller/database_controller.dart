import 'package:again/controller/u_i_controller.dart';
import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  Future<void> updateDatabase() async {
    await voiceUpdater.update();
    await updateViewList();
  }

  Future<void> updateViewList() async {
    var selectedCvIdx = Get.find<UIController>().selectedCvIdx.value;

    if (selectedCvIdx != 0) {
      await updateVkTitleListWithCv(
          Get.find<UIController>().cvNames[selectedCvIdx]);
    } else {
      await updateVkTitleList();
    }

    await updateFilterList();
  }

  Future<void> updateVkTitleList() async {
    var vkDataList = await database.selectAllVoiceWorks;
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateVkTitleListWithCv(String cvName) async {
    var vkDataList = await database.selectVkWithCv(cvName);
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateVkTitleListWithCategory(String category) async {
    var vkDataList = await database.selectVkWithCategory(category);
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateVkTitleListWithCvAndCategory(
      String cvName, String category) async {
    var vkDataList = await database.selectVkWithCvAndCategory(cvName, category);
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> updateFilterList() async {
    var cvDataList = await database.selectAllCv();
    var categoryDataList = await database.selectAllCategory();
    Get.find<UIController>().cvNames
      ..clear()
      ..addAll(cvDataList.map((item) => item.cvName));
    Get.find<UIController>().categories
      ..clear()
      ..addAll(categoryDataList.map((item) => item.description));
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
