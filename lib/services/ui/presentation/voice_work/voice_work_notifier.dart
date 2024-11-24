import 'package:again/services/ui/presentation/state_interface/state_interface.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_state.dart';

class VoiceWorkNotifier
    extends VariableListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbServiceProvider).updateViList();
  }
}
