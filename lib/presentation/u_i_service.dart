import 'dart:async';
import 'dart:io';

import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/widgets.dart';
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

    return sortOrder.isPlaying && category.isPlaying && cv.isPlaying;
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
    ref.read(sortOrderProvider.notifier).restorePlayingIndex();
    ref.read(categoryProvider.notifier).restorePlayingIndex();
    ref.read(cvProvider.notifier).restorePlayingIndex();
    ref.read(voiceWorkProvider.notifier).restorePlayingIndex();
    ref.read(voiceItemProvider.notifier).restorePlayingIndex();
  }

  void cacheAllPlayingIndex() {
    ref.read(sortOrderProvider.notifier).cachePlayingIndex();
    ref.read(categoryProvider.notifier).cachePlayingIndex();
    ref.read(cvProvider.notifier).cachePlayingIndex();
    ref.read(voiceWorkProvider.notifier).cachePlayingIndex();
  }

  void restoreAllPlayingIndex() {
    ref.read(sortOrderProvider.notifier).restorePlayingIndex();
    ref.read(categoryProvider.notifier).restorePlayingIndex();
    ref.read(cvProvider.notifier).restorePlayingIndex();
    ref.read(voiceWorkProvider.notifier).restorePlayingIndex();
  }

  Map<String, dynamic> get playingItems {
    try {
      return {
        'sortOrder': ref.read(sortOrderProvider).playingItem,
        'category': ref.read(categoryProvider).playingItem,
        'cv': ref.read(cvProvider).playingItem,
        'voiceWork': ref.read(voiceWorkProvider).playingItem,
        'voiceItem': ref.read(voiceItemProvider).playingItem
      };
    } catch (e) {
      Log.debug('Error getting playingItems.\n$e.');
      return {};
    }
  }

  Map<String, dynamic> get selectedItems {
    try {
      return {
        'sortOrder': ref.read(sortOrderProvider).selectedItem,
        'category': ref.read(categoryProvider).selectedItem,
        'cv': ref.read(cvProvider).selectedItem,
        'voiceWork': ref.read(voiceWorkProvider).selectedItem,
        'voiceItem': ref.read(voiceItemProvider).selectedItem
      };
    } catch (e) {
      Log.debug('Error getting selectedItems.\n$e');
      return {};
    }
  }

  void setPlayingIndexByMap(Map<String, dynamic> playingItems) {
    try {
      ref
          .read(sortOrderProvider.notifier)
          .updatePlayingIndexByValue(playingItems['sortOrder'] as SortOrder);
      ref
          .read(categoryProvider.notifier)
          .updatePlayingIndexByValue(playingItems['category'] as String);
      ref
          .read(cvProvider.notifier)
          .updatePlayingIndexByValue(playingItems['cv'] as String);
      ref
          .read(voiceWorkProvider.notifier)
          .updatePlayingIndexByValue(playingItems['voiceWork'] as VoiceWork);
      ref
          .read(voiceItemProvider.notifier)
          .updatePlayingIndexByValue(playingItems['voiceItem'] as VoiceItem);
    } catch (e) {
      Log.debug('Error setting playingIndex by map.\n$e');
    }
  }

  void setSelectedIndexByMap(Map<String, dynamic> selectedItems) {
    try {
      ref
          .read(sortOrderProvider.notifier)
          .updateSelectedIndexByValue(selectedItems['sortOrder'] as SortOrder);
      ref
          .read(categoryProvider.notifier)
          .updateSelectedIndexByValue(selectedItems['category'] as String);
      ref
          .read(cvProvider.notifier)
          .updateSelectedIndexByValue(selectedItems['cv'] as String);
      ref
          .read(voiceWorkProvider.notifier)
          .updateSelectedIndexByValue(selectedItems['voiceWork'] as VoiceWork);
      ref
          .read(voiceItemProvider.notifier)
          .updateSelectedIndexByValue(selectedItems['voiceItem'] as VoiceItem);
    } catch (e) {
      Log.debug('Error setting selectedIndex by map.\n$e');
    }
  }

  void cachePlayingState() {
    ref.read(voiceWorkProvider.notifier).cachePlayingValues();
    ref.read(voiceItemProvider.notifier).cachePlayingValues();
    cacheAllPlayingIndex();
  }

  void restorePlayingState() {
    ref.read(voiceWorkProvider.notifier).restorePlayingValues();
    ref.read(voiceItemProvider.notifier).restorePlayingValues();
    restoreAllPlayingIndex();
  }

  Future<void> revealInExplorerView() async {
    if (isVoiceWorkPlaying) {
      selectPlayingVoiceItem();
    } else {
      Process.run(
          'explorer /select, "${ref.read(voiceWorkProvider).selectedVoiceWorkPath}"',
          []);
    }
  }

  void selectPlayingVoiceItem() {
    // flutter will replace " with /" in arg list. weird
    // code below doesn't work
    // Process.run('explorer', ['/select,', '"$playingViPath"']); // wrap path in "" so that Windows can resolve it
    Process.run(
        'explorer /select, "${ref.read(voiceItemProvider).playingVoiceItemPath}"',
        []);
  }

  /// Resets the filters and scrolls to the top.
  Future<void> onRemoveFilterPressed() async {
    await _resetFilters();
    _scrollToTop();
  }

  /// reset category & cv, except sortOrder
  Future<void> _resetFilters() async {
    ref.read(categoryProvider.notifier).updateSelectedIndex(0);
    await ref.read(cvProvider.notifier).onSelected(0);
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex(cateScrollController, 0);
      scrollToIndex(cvScrollController, 0);
      scrollToIndex(vkScrollController, 0);
    });
  }

  void scrollToIndex(ItemScrollController controller, int index,
      {int duration = 200, Curve curve = Curves.linear}) {
    if (index >= 0 && controller.isAttached) {
      controller.scrollTo(
        index: index,
        duration: Duration(milliseconds: duration),
        curve: curve,
      );
    }
  }

  /// Locates the playing item by restoring PlayingStates and scrolling to it.
  void onLocateBtnPressed() {
    if (!isVoiceWorkPlaying) {
      restorePlayingState();
    }
    scrollToPlayingIdx();
  }

  void scrollToPlayingIdx() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await viCompleter.future;
      scrollToIndex(
          cateScrollController, ref.read(categoryProvider).playingIndex);
      scrollToIndex(cvScrollController, ref.read(cvProvider).playingIndex);
      scrollToIndex(
          vkScrollController, ref.read(voiceWorkProvider).playingIndex);
      scrollToIndex(
          viScrollController, ref.read(voiceItemProvider).playingIndex);
      // });
    });
  }
}
