import 'dart:async';

import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/common/const.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryManager {
  static const _audioHistoryTimeout = Duration(seconds: 12);

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
    final dbNotifier = ref.read(dbNotifierProvider);
    await dbNotifier.updateFilterLists();

    final data = await ref.read(historyJsonProvider).read();

    if (data.isEmpty) {
      await dbNotifier.updateVwList();
      return;
    }

    await _loadUIHistory(data['ui']);
    await _loadAudioHistory(data['audio']).timeout(
      _audioHistoryTimeout,
      onTimeout: () {
        Log.error(
          'Timed out restoring audio history; continuing startup.',
          error: TimeoutException(
            'Audio history restoration exceeded $_audioHistoryTimeout.',
            _audioHistoryTimeout,
          ),
        );
      },
    );
  }

  Future<void> _loadUIHistory(Map<String, dynamic> uiHistory) async {
    if (uiHistory.isEmpty) return;
    try {
      final filter = uiHistory['filter'];
      final dbNotifier = ref.read(dbNotifierProvider);

      final sortOrderNotifier = ref.read(sortOrderProvider.notifier);
      final categoryNotifier = ref.read(categoryProvider.notifier);
      final cvNotifier = ref.read(cvProvider.notifier);

      sortOrderNotifier.cacheSelectedIndexAndItemByValue(
          SortOrderExtension.fromString(filter['sortOrder']));
      categoryNotifier
          .cacheSelectedIndexAndItemByValue(filter['category'] as String);
      // CV 列表跟随分类刷新后再恢复选中
      await dbNotifier.updateCvList(
        ref.read(categoryProvider).cachedSelectedItem ?? 'All',
      );
      cvNotifier.cacheSelectedIndexAndItemByValue(filter['cv'] as String);
      // 历史 CV 不在当前分类时回退为 All
      if (ref.read(cvProvider).selectedIndex == -1) {
        cvNotifier.cacheSelectedIndexAndItem(0);
      }

      // voiceWork
      await dbNotifier.updateVwList();
      Map<String, dynamic>? voiceWorkMap = uiHistory['voiceWork'];
      if (voiceWorkMap != null) {
        final directoryPath = voiceWorkMap['directoryPath'];
        final workIndex = directoryPath is String
            ? ref
                .read(voiceWorkProvider)
                .values
                .indexWhere((work) => work.directoryPath == directoryPath)
            : -1;
        if (workIndex >= 0) {
          ref
              .read(voiceWorkProvider.notifier)
              .cacheSelectedIndexAndItem(workIndex);
        }
      }
      if (!ref.read(voiceWorkProvider).isSelectedIndexValid) {
        sortOrderNotifier.cacheSelectedIndexAndItem(0);
        categoryNotifier.cacheSelectedIndexAndItem(0);
        await cvNotifier.onSelected(0);
        return;
      }

      // voiceItem
      await dbNotifier.updateViList();
      Map<String, dynamic>? voiceItemMap = uiHistory['voiceItem'];
      if (voiceItemMap != null) {
        final filePath = voiceItemMap['filePath'];
        final itemIndex = filePath is String
            ? ref
                .read(voiceItemProvider)
                .values
                .indexWhere((item) => item.filePath == filePath)
            : -1;
        if (itemIndex >= 0) {
          ref
              .read(voiceItemProvider.notifier)
              .cacheSelectedIndexAndItem(itemIndex);
        }
      }

      ref.read(sortOrderProvider.notifier).cachePlayingState();
      ref.read(categoryProvider.notifier).cachePlayingState();
      ref.read(cvProvider.notifier).cachePlayingState();
      ref.read(voiceWorkProvider.notifier).cachePlayingState();
      // voiceItem和audio相关联，放在audio部分处理
    } catch (e) {
      Log.error('Error loading UI history.\n' 'error: $e');
    }
  }

  Future<void> _loadAudioHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;
    try {
      final audioNotifier = ref.read(audioProvider.notifier);
      final histPlaybackMode = PlaybackModeExtension.fromString(
          audioHistory['playbackMode'] as String? ??
              'PlaybackMode.sequentialPlay');
      audioNotifier
        ..setVolume(audioHistory['volume'] ?? 1.0)
        ..updatePlaybackMode(histPlaybackMode);

      ref.read(voiceItemProvider.notifier).cachePlayingState();

      final voiceItemSate = ref.read(voiceItemProvider);
      if (!voiceItemSate.isPlaying) return;
      final path = voiceItemSate.cachedPlayingVoiceItemPath;
      if (path == null || path.isEmpty) {
        Log.warning('Audio history has no valid track path; skipping restore.');
        return;
      }
      final loaded = await audioNotifier.setSource(path);
      if (!loaded) {
        Log.warning('Audio history source failed to load; skipping seek.');
        return;
      }
      if (ref.read(voiceItemProvider).cachedPlayingVoiceItemPath != path) {
        Log.warning('Audio history source was superseded; skipping seek.');
        return;
      }
      await audioNotifier
          .seek(Duration(milliseconds: audioHistory['position'] ?? 0));

      if (ref.read(audioProvider).isShufflePlay) {
        ref.read(uiServiceProvider).shufflePlayingState();
      }
    } catch (e) {
      Log.error('Error loading audio history.\n' 'error: $e');
    }
  }
}

final historyManagerProvider = Provider.autoDispose<HistoryManager>((ref) {
  return HistoryManager(ref: ref);
});
