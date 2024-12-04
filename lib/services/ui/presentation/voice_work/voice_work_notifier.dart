import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/presentation/state_interface/state_interface.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/log.dart';
import 'package:again/utils/move_file.dart';
import 'package:again/utils/tool_function.dart';

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

  Future<void> deleteVoiceWork(VoiceWork movedVoiceWork) async {
    try {
      if (!await Directory(movedVoiceWork.directoryPath).exists()) {
        Log.error('Error deleting "${movedVoiceWork.title}".\n'
            'Cannot find "${movedVoiceWork.directoryPath}".');
        return;
      }

      if (!await File(DELETE_SCRIPT_PATH).exists()) {
        Log.error(
            'Error deleting "${movedVoiceWork.title}". Cannot find "$DELETE_SCRIPT_PATH".\nStart to generate delete script.');
        await generateDeleteScript();
      }

      await playingOrSelected(movedVoiceWork);

      List<String> arguments = [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        DELETE_SCRIPT_PATH,
        '-path',
        movedVoiceWork.directoryPath,
      ];
      ProcessResult result = await Process.run('powershell', arguments);

      Log.info('Delete ${movedVoiceWork.title}.\n'
          'exitcode: ${result.exitCode}.\n'
          'stdout: ${result.stdout}\n'
          'stderr: ${result.stderr}');
    } catch (e) {
      Log.error('Error deleting VoiceWork directory.\n$e');
    }
  }

  Future<void> changeCategory(
    VoiceWork movedVoiceWork,
    String newCategory,
  ) async {
    Directory oldDirectory = Directory(movedVoiceWork.directoryPath);
    if (!await oldDirectory.exists()) {
      Log.error('Error changing category of "${movedVoiceWork.title}".\n'
          'Cannot find "${movedVoiceWork.directoryPath}".');
      return;
    }

    // 将路径中的 voiceWork.category 替换为新的 cate
    final newDirectoryPath = replaceLast(
      movedVoiceWork.directoryPath,
      movedVoiceWork.category,
      newCategory,
    );

    try {
      await playingOrSelected(movedVoiceWork);
      await moveDirectory(oldDirectory, newDirectoryPath);

      Log.info(
          'Move "${movedVoiceWork.title}" from "${movedVoiceWork.category}" to "$newCategory".');
    } catch (e) {
      Log.error(
          'Error moving "${oldDirectory.path}" to "$newDirectoryPath".\n$e.');
    }
  }

  Future<void> playingOrSelected(VoiceWork movedVoiceWork) async {
    // playing
    if (state.cachedPlayingItem == movedVoiceWork) {
      await ref.read(audioProvider.notifier).release();
    }

    // selected
    if (state.cachedSelectedItem == movedVoiceWork) {
      ref.read(voiceItemProvider.notifier).clearValues();
    }
  }
}
