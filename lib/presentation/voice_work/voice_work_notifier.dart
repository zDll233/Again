import 'package:again/controllers/database_controller.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/voice_work/voice_work_state.dart';
import 'package:get/get.dart';


class VoiceWorkNotifier extends VariableListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    if (selectedIndex < 0) return;

    // TODO: DatabaseController
    final DatabaseController db = Get.find();
    updateSelectedIndex(selectedIndex);
    await db.updateViList();
  }
}