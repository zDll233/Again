import 'dart:io';

import 'package:again/services/audio/audio_providers.dart';
import 'package:again/common/const.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/log.dart';
import 'package:again/utils/move_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> deleteVoiceWork(WidgetRef ref, VoiceWork movedVoiceWork) async {
  if (!await File(DELETE_SCRIPT_PATH).exists()) {
    Log.error(
        'Error deleting "${movedVoiceWork.title}". Cannot find "$DELETE_SCRIPT_PATH".\nStart to generate delete script.');
    await generateDeleteScript();
  }

  try {
    await playingOrSelected(ref, movedVoiceWork);

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
  WidgetRef ref,
  VoiceWork movedVoiceWork,
  String newCategory,
) async {
  // 将路径中的 voiceWork.category 替换为新的 cate
  final newDirectoryPath = movedVoiceWork.directoryPath
      .replaceFirst(movedVoiceWork.category, newCategory);
  Directory oldDirectory = Directory(movedVoiceWork.directoryPath);

  try {
    await playingOrSelected(ref, movedVoiceWork);
    await moveDirectory(oldDirectory, newDirectoryPath);

    Log.info(
        'Move "${movedVoiceWork.title}" from "${movedVoiceWork.category}" to "$newCategory".');
  } catch (e) {
    Log.error(
        'Error moving "${oldDirectory.path}" to "$newDirectoryPath".\n$e.');
  }
}

Future<void> playingOrSelected(WidgetRef ref, VoiceWork movedVoiceWork) async {
  final voiceWorkState = ref.read(voiceWorkProvider);
  // playing
  if (voiceWorkState.cachedPlayingItem == movedVoiceWork) {
    await ref.read(audioProvider.notifier).release();
  }

  // selected
  if (voiceWorkState.cachedSelectedItem == movedVoiceWork) {
    ref.read(voiceItemProvider.notifier).clearValues();
  }
}
