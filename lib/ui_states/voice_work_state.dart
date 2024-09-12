import 'package:again/controllers/database_controller.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/ui_states/state_interface.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class VoiceWorkState extends ListState<VoiceWork> {
  VoiceWorkState({
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
  });

  @override
  VoiceWorkState copyWith({
    List<VoiceWork>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return VoiceWorkState(
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  Future<List<String>> get playingVkPathList {
    // TODO: implement the method.
    throw UnimplementedError();
  }

  List<String> get selectedVkPathList {
    // TODO: implement the method.
    throw UnimplementedError();
  }

  Future<String> get playingVkPath async {
    // TODO: implement the method.
    throw UnimplementedError();
  }

  String get selectedVkPath {
    // TODO: implement the method.
    throw UnimplementedError();
  }
}

class VoiceWorkNotifier extends ListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    Log.debug('VoiceWorkState rebuilded.');
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    if (selectedIndex < 0) return;

    final DatabaseController db = Get.find();
    updateSelectedIndex(selectedIndex);
    await db.updateViList();
  }
}

final voiceWorkProvider =
    NotifierProvider<VoiceWorkNotifier, VoiceWorkState>(VoiceWorkNotifier.new);
