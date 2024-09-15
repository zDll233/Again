import 'package:again/audio/audio_providers.dart';
import 'package:again/audio/audio_state.dart';
import 'package:again/config/config.dart';
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
    final playingItems = _uiService.playingItems;
    final audioState = ref.read(audioProvider);

    Map<String, dynamic> lastPlayed = {
      'ui': {
        'filter': {
          'sortOrder': playingItems['sortOrder'].toString(),
          'category': playingItems['category'] as String,
          'cv': playingItems['cv'] as String,
        },
        'voiceWork': playingItems['voiceWork'].toMap() as Map<String, dynamic>,
        'voiceItem': playingItems['voiceItem'].toMap() as Map<String, dynamic>
      },
      'audio': {
        'position': audioState.position.inMilliseconds,
        'volume': audioState.volume,
        'loopMode': audioState.loopMode.index
      },
    };
    await ref.read(historyProvider).write(lastPlayed);
  }

  Future<void> loadHistory() async {
    final repositoryNotifier = ref.read(repositoryProvider.notifier);
    await repositoryNotifier.updateFilterLists();

    final data = await ref.read(historyProvider).read();

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
    final repositoryNotifier = ref.read(repositoryProvider.notifier);

    ref.read(sortOrderProvider.notifier).updateSelectedIndexByValue(
        SortOrderExtension.fromString(filter['sortOrder']));
    ref
        .read(categoryProvider.notifier)
        .updateSelectedIndexByValue(filter['category'] as String);
    ref
        .read(cvProvider.notifier)
        .updateSelectedIndexByValue(filter['cv'] as String);
    await repositoryNotifier.updateVkList();
    ref
        .read(voiceWorkProvider.notifier)
        .updateSelectedIndexByValue(VoiceWork.fromMap(uiHistory['voiceWork']));
    await repositoryNotifier.updateViList();
    ref
        .read(voiceItemProvider.notifier)
        .updateSelectedIndexByValue(VoiceItem.fromMap(uiHistory['voiceItem']));

    ref.read(uiServiceProvider).cachePlayingState();
  }

  Future<void> loadAudioHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    final audioNotifier = ref.read(audioProvider.notifier);
    audioNotifier
      ..setVolume(audioHistory['volume'])
      ..updateLoopMode(LoopMode.values[audioHistory['loopMode']]);

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
