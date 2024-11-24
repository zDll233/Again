import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/common/const.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryManager {
  final Ref ref;
  late final UIService _uiService;

  HistoryManager({required this.ref})
      : _uiService = ref.read(uiServiceProvider);

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
          'voiceItem': playingItems['voiceItem']?.toMap(),
        },
        'audio': {
          'position': audioState.position.inMilliseconds,
          'volume': audioState.volume,
          'playbackMode': audioState.playbackMode.toString(),
        },
      };
      await ref.read(historyJsonProvider).write(lastPlayed);
    } catch (e) {
      Log.error('Error saving history.\n$e');
    }
  }

  Future<void> loadHistory() async {
    final dbService = ref.read(dbServiceProvider);
    await dbService.updateFilterLists();

    final data = await ref.read(historyJsonProvider).read();

    if (data.isEmpty) {
      await dbService.updateVkList();
      return;
    }

    try {
      await _loadUIHistory(data['ui']);
      await _loadAudioHistory(data['audio']);
    } catch (e) {
      await dbService.updateVkList();
      Log.error('Error loading history.\n$e.');
    }
  }

  Future<void> _loadUIHistory(Map<String, dynamic> uiHistory) async {
    try {
      if (uiHistory.isEmpty) return;

      final filter = uiHistory['filter'];
      final dbService = ref.read(dbServiceProvider);

      final sortOrderNotifier = ref.read(sortOrderProvider.notifier);
      final categoryNotifier = ref.read(categoryProvider.notifier);
      final cvNotifier = ref.read(cvProvider.notifier);

      sortOrderNotifier.cacheSelectedIndexAndItemByValue(
          SortOrderExtension.fromString(filter['sortOrder']));
      categoryNotifier
          .cacheSelectedIndexAndItemByValue(filter['category'] as String);
      cvNotifier.cacheSelectedIndexAndItemByValue(filter['cv'] as String);

      // voiceWork
      await dbService.updateVkList();
      Map<String, dynamic>? voiceWorkMap = uiHistory['voiceWork'];
      if (voiceWorkMap != null) {
        ref
            .read(voiceWorkProvider.notifier)
            .cacheSelectedIndexAndItemByValue(VoiceWork.fromMap(voiceWorkMap));
      }
      if (!ref.read(voiceWorkProvider).isSelectedIndexValid) {
        sortOrderNotifier.cacheSelectedIndexAndItem(0);
        categoryNotifier.cacheSelectedIndexAndItem(0);
        await cvNotifier.onSelected(0);
        return;
      }

      // voiceItem
      await dbService.updateViList();
      Map<String, dynamic>? voiceItemMap = uiHistory['voiceItem'];
      if (voiceItemMap != null) {
        ref
            .read(voiceItemProvider.notifier)
            .cacheSelectedIndexAndItemByValue(VoiceItem.fromMap(voiceItemMap));
      }

      _uiService.cacheAllPlayingState();
    } catch (e) {
      Log.error('Error loading UI history.\n$e');
    }
  }

  Future<void> _loadAudioHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    final audioNotifier = ref.read(audioProvider.notifier);
    audioNotifier
      ..setVolume(audioHistory['volume'])
      ..updatePlaybackMode(PlaybackModeExtension.fromString(
          audioHistory['playbackMode'] as String));

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

final historyManagerProvider = Provider.autoDispose<HistoryManager>((ref) {
  return HistoryManager(ref: ref);
});
