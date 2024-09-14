import 'package:again/audio/audio_providers.dart';
import 'package:again/audio/audio_state.dart';
import 'package:again/config/config.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryManager {
  final Ref ref;
  late final UIService _uiService;

  HistoryManager({required this.ref}) {
    _uiService = ref.read(uiServiceProvider);
  }

  Future<void> saveHistory() async {
    final playingData = await _uiService.playingStringMap;
    final audioState = ref.read(audioProvider);

    Map<String, dynamic> lastPlayed = {
      'ui': {
        'filter': {
          'category': playingData['category'],
          'cv': playingData['cv'],
          'sortOrder': ref.read(sortOrderProvider).playingIndex
        },
        'vk': playingData['vk'],
        'vi': ref.read(voiceItemProvider).playingIndex
      },
      'audio': {
        'position': audioState.position.inMilliseconds,
        'volume': audioState.volume,
        'loopMode': audioState.loopMode
      },
    };
    await ref.read(historyProvider).write(lastPlayed);
  }

  Future<void> loadHistory() async {
    final data = await ref.read(historyProvider).read();
    if (data.isEmpty) return;

    final repositoryNotifier = ref.read(repositoryProvider.notifier);

    await repositoryNotifier.updateFilterLists();
    try {
      await loadUIHistory(data['ui']);
      await loadAudioHistory(data['audio']);
    } catch (e) {
      await repositoryNotifier.updateVkList();
      Log.error('Error loading history.\n$e.');
    }
  }

  Future<void> loadUIHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;

    final filter = uiHistory['filter'];

    // filter vk
    await _uiService.setPlayingIdxByString(
        filter['category'], filter['cv'], uiHistory['vk'],
        sort: filter['sortOrder']);

    // vi
    ref.read(voiceItemProvider.notifier).updatePlayingIndex(uiHistory['vi']);

    await _uiService.onLocateBtnPressed();
  }

  Future<void> loadAudioHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    final audioNotifier = ref.read(audioProvider.notifier);
    audioNotifier
      ..setVolume(audioHistory['volume'])
      ..updateLoopMode(LoopMode.values[audioHistory['loopMode']]);
    ref.read(voiceItemProvider.notifier).updatePlayingValues();

    try {
      await audioNotifier
          .setSource(ref.read(voiceItemProvider).playingVoiceItemPath);
      await audioNotifier
          .seek(Duration(milliseconds: audioHistory['position']));
    } catch (e) {
      Log.error('Error loading audio history.\n$e');
    }
  }
}

final historyManagerProvider = Provider<HistoryManager>((ref) {
  return HistoryManager(ref: ref);
});
