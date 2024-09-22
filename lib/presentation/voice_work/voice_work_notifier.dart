import 'package:again/presentation/state_interface/variable_list_state/variable_list_state_notifier.dart';
import 'package:again/repository/repository_providers.dart';
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
    ref.read(dbRepoProvider.notifier).updateViList();
  }
}
