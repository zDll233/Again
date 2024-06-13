import 'package:again/controller/u_i_controller.dart';
import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:get/get.dart';

class DatabaseController extends GetxController {
  Future<void> updateDatabase() async {
    await voiceUpdater.update();
    await updateVkTitleList();
  }

  Future<void> updateVkTitleList() async {
    var vkDataList = await database.selectAllVoiceWorks;
    Get.find<UIController>().vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
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
