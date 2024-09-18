import 'package:again/audio/audio_providers.dart';
import 'package:again/audio/audio_state.dart';
import 'package:again/const/const.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
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
    try {
      final playingItems = _uiService.cachedPlayingItems;
      final audioState = ref.read(audioProvider);

      Map<String, dynamic> lastPlayed = {
        'ui': {
          'filter': {
            'sortOrder': playingItems['sortOrder'].toString(),
            'category': playingItems['category'] as String,
            'cv': playingItems['cv'] as String,
          },
          'voiceWork': playingItems['voiceWork']?.toMap(),
          'voiceItem': playingItems['voiceItem']?.toMap()
        },
        'audio': {
          'position': audioState.position.inMilliseconds,
          'volume': audioState.volume,
          'loopMode': audioState.loopMode.index
        },
      };
      await ref.read(historyJsonProvider).write(lastPlayed);
    } catch (e) {
      Log.error('Error saving history.\n$e');
    }
  }

  Future<void> loadHistory() async {
    final repositoryNotifier = ref.read(dbRepoProvider.notifier);
    await repositoryNotifier.updateFilterLists();

    final data = await ref.read(historyJsonProvider).read();

    if (data.isEmpty) {
      await repositoryNotifier.updateVkList();
      return;
    }

    try {
      await loadUIHistory(data['ui']);
      await loadAudioHistory(data['audio']);
    } catch (e) {
      await repositoryNotifier.updateVkList();
      Log.error('Error loading history.\n$e.');
    }
  }

  Future<void> loadUIHistory(Map<String, dynamic> uiHistory) async {
    try {
      if (uiHistory.isEmpty) return;

      final filter = uiHistory['filter'];
      final repositoryNotifier = ref.read(dbRepoProvider.notifier);

      ref.read(sortOrderProvider.notifier).cacheSelectedIndexAndItemByValue(
          SortOrderExtension.fromString(filter['sortOrder']));
      ref
          .read(categoryProvider.notifier)
          .cacheSelectedIndexAndItemByValue(filter['category'] as String);
      ref
          .read(cvProvider.notifier)
          .cacheSelectedIndexAndItemByValue(filter['cv'] as String);

      // voiceWork
      await repositoryNotifier.updateVkList();
      Map<String, dynamic>? voiceWorkMap = uiHistory['voiceWork'];
      if (voiceWorkMap != null) {
        ref
            .read(voiceWorkProvider.notifier)
            .cacheSelectedIndexAndItemByValue(VoiceWork.fromMap(voiceWorkMap));
      }

      // voiceItem
      await repositoryNotifier.updateViList();
      Map<String, dynamic>? voiceItemMap = uiHistory['voiceItem'];
      if (voiceItemMap != null) {
        ref
            .read(voiceItemProvider.notifier)
            .cacheSelectedIndexAndItemByValue(VoiceItem.fromMap(voiceItemMap));
      }

      ref.read(uiServiceProvider).cacheAllPlayingState();
    } catch (e) {
      Log.error('Error loading UI history.\n$e');
    }
  }

  Future<void> loadAudioHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    final audioNotifier = ref.read(audioProvider.notifier);
    audioNotifier
      ..setVolume(audioHistory['volume'])
      ..updateLoopMode(LoopMode.values[audioHistory['loopMode']]);

    try {
      final voiceItemSate = ref.read(voiceItemProvider);
      if (!voiceItemSate.isPlaying) return;
      await audioNotifier.setSource(voiceItemSate.cachedPlayingVoiceItemPath!);
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
