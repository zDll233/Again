import 'package:again/repository/repository_providers.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/feature/state_interface.dart';
import 'package:again/feature/voice_work/voice_work_state.dart';

class VoiceWorkNotifier
    extends VariableListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    if (selectedIndex < 0) return;

    updateSelectedIndex(selectedIndex);
    ref.read(repositoryProvider.notifier).updateViList();
  }
}
