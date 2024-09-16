import 'dart:io';

import 'package:again/audio/audio_providers.dart';
import 'package:again/const/const.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/log.dart';
import 'package:again/utils/move_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> deleteVoiceWork(WidgetRef ref, VoiceWork movedVoiceWork) async {
  if (!await File(deleteScriptPath).exists()) {
    Log.error(
        'Error deleting "${movedVoiceWork.title}". Cannot find "$deleteScriptPath".\nStart to generate delete script.');
    await generateDeleteScript();
  }

  try {
    await releasePlayingItems(ref, movedVoiceWork);

    List<String> arguments = [
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      deleteScriptPath,
    ];
    ProcessResult result = await Process.run('powershell', arguments);

    // updateVoiceWorkPlayingValues(ref, movedVoiceWork);

    ref.read(repositoryProvider.notifier).onUpdatePressed();
    Log.info('Delete ${movedVoiceWork.title}.\n'
        'exitcode: ${result.exitCode}.\n'
        'stdout: ${result.stdout}\n'
        'stderr: ${result.stderr}');
  } catch (e) {
    Log.error('Error deleting VoiceWork directory.\n$e');
  }
}

Future<void> changeCategory(
    WidgetRef ref, VoiceWork movedVoiceWork, String newCategory) async {
  // 将路径中的 voiceWork.category 替换为新的 cate
  final newDirectoryPath = movedVoiceWork.directoryPath
      .replaceFirst(movedVoiceWork.category, newCategory);
  Directory oldDirectory = Directory(movedVoiceWork.directoryPath);

  try {
    await releasePlayingItems(ref, movedVoiceWork);
    await moveDirectory(oldDirectory, newDirectoryPath);
    // updateVoiceWorkPlayingValues(ref, movedVoiceWork, newCategory: newCategory);

    ref.read(repositoryProvider.notifier).onUpdatePressed();

    Log.info(
        'Move "${movedVoiceWork.title}" from "${movedVoiceWork.category}" to "$newCategory".');
  } catch (e) {
    Log.error(
        'Error moving "${oldDirectory.path}" to "$newDirectoryPath".\n$e.');
  }
}

Future<void> releasePlayingItems(
    WidgetRef ref, VoiceWork movedVoiceWork) async {
  final voiceWorkState = ref.read(voiceWorkProvider);
  if (voiceWorkState.isPlaying &&
      voiceWorkState.cachedPlayingItem == movedVoiceWork) {
    await ref.read(audioProvider.notifier).release();
  }
}

void updateVoiceWorkPlayingValues(WidgetRef ref, VoiceWork movedVoiceWork,
    {String? newCategory}) {
  final voiceWorkState = ref.read(voiceWorkProvider);
  // 被移动的VoiceWork所属的SortOrder、Cv与Playing一致， 更新 playingValues
  if (voiceWorkState.isPlaying &&
      ref.read(sortOrderProvider).isSelectedItemPlaying &&
      ref.read(cvProvider).isSelectedItemPlaying) {
    final playingCategory = voiceWorkState.cachedPlayingItem!.category;
    final voiceWorkNotifier = ref.read(voiceWorkProvider.notifier);
    // 移出 playingValues
    if (playingCategory == movedVoiceWork.category) {
      voiceWorkNotifier.removeItemInPlayingValues(movedVoiceWork);
    }
    // 移入 playingValues
    else if (newCategory != null && playingCategory == newCategory) {
      final newVoiceWork = movedVoiceWork.replaceCategory(newCategory);
      voiceWorkNotifier.addItemInPlayingValues(newVoiceWork);
    }
  }
}
