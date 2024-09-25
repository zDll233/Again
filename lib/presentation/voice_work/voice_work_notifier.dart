import 'package:again/presentation/state_interface/state_interface.dart';
import 'package:again/services/repository/repository_providers.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/voice_work/voice_work_state.dart';

class VoiceWorkNotifier
    extends VariableListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    if (selectedIndex < 0) return;

    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbRepoProvider.notifier).updateViList();
  }
}
