import 'dart:async';

import 'package:again/models/voice_work.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class UIService {
  final Ref ref;
  UIService(this.ref);

  late Completer viCompleter;

  final cateScrollController = ItemScrollController();
  final cvScrollController = ItemScrollController();
  final vkScrollController = ItemScrollController();
  final viScrollController = ItemScrollController();

  bool get isFilterPlaying {
    final sortOrder = ref.read(sortOrderProvider);
    final category = ref.read(categoryProvider);
    final cv = ref.read(cvProvider);
    final voiceItem = ref.read(voiceItemProvider);

    return sortOrder.isPlaying &&
        category.isPlaying &&
        cv.isPlaying &&
        voiceItem.isPlaying;
  }

  bool get isVoiceWorkPlaying =>
      isFilterPlaying && ref.read(voiceWorkProvider).isPlaying;

  bool get isVoiceItemPlaying =>
      isVoiceWorkPlaying && ref.read(voiceItemProvider).isPlaying;

  Future<void> filterSelected() async {
    final voiceWorkNotifier = ref.read(voiceWorkProvider.notifier);

    if (isFilterPlaying) {
      await voiceWorkNotifier
          .onSelected(ref.read(voiceWorkProvider).playingIndex);
    } else {
      voiceWorkNotifier.updateSelectedIndex(-1);
      final voiceItemNotifier = ref.read(voiceItemProvider.notifier);
      voiceItemNotifier.clearValues();
    }
  }

  void setAllSelectedIndex2Playing() {
    ref.read(sortOrderProvider.notifier).setSelectedIndex2Playing();
    ref.read(categoryProvider.notifier).setSelectedIndex2Playing();
    ref.read(cvProvider.notifier).setSelectedIndex2Playing();
    ref.read(voiceWorkProvider.notifier).setSelectedIndex2Playing();
    ref.read(voiceItemProvider.notifier).setSelectedIndex2Playing();
  }

  Future<Map<String, dynamic>> get playingStringMap async {
    try {
      return {
        'category': ref.read(categoryProvider).playingItem,
        'cv': ref.read(cvProvider).playingItem,
        'vk': ref.read(voiceWorkProvider).playingItem,
      };
    } catch (e) {
      Log.debug('Error getting playingStringMap.\n$e.');
      return {};
    }
  }

  Map<String, dynamic> get selectedStringMap {
    try {
      return {
        'category': ref.read(categoryProvider).selectedItem,
        'cv': ref.read(cvProvider).selectedItem,
        'vk': ref.read(voiceWorkProvider).selectedItem,
      };
    } catch (e) {
      Log.debug('Error getting selectedStringMap.\n$e');
      return {};
    }
  }

  Future<void> setPlayingIdxByString(String cate, String cv, VoiceWork vk,
      {SortOrder? sort}) async {
    if (sort != null) {
      ref.read(sortOrderProvider.notifier).updatePlayingIndexByValue(sort);
    }
    ref.read(categoryProvider.notifier).updatePlayingIndexByValue(cate);
    ref.read(cvProvider.notifier).updatePlayingIndexByValue(cv);
    ref.read(voiceWorkProvider.notifier).updatePlayingIndexByValue(vk);
  }

  void setSelectedIdxByString(String cate, String cv, VoiceWork vk) {
    ref.read(categoryProvider.notifier).updateSelectedIndexByValue(cate);
    ref.read(cvProvider.notifier).updateSelectedIndexByValue(cv);
    ref.read(voiceWorkProvider.notifier).updateSelectedIndexByValue(vk);
  }

  void cachePlayingState() {
    ref.read(voiceWorkProvider.notifier).updatePlayingValues();
    ref.read(voiceItemProvider.notifier).updatePlayingValues();
    setAllSelectedIndex2Playing();
  }
}
