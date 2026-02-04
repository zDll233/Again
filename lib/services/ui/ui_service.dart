import 'dart:async';
import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/history/history_manager.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:window_manager/window_manager.dart';

import 'package:path/path.dart' as p;

class UIService {
  final Ref ref;
  UIService(this.ref);

  final cateScrollController = ItemScrollController();
  final cvScrollController = ItemScrollController();
  final vwScrollController = ItemScrollController();
  final viScrollController = ItemScrollController();

  Future<void> filterSelected() async {
    final voiceWorkNotifier = ref.read(voiceWorkProvider.notifier);

    if (ref.read(isSelectedFilterPlaying)) {
      await voiceWorkNotifier
          .onSelected(ref.read(voiceWorkProvider).playingIndex);
    } else {
      voiceWorkNotifier.cacheSelectedIndexAndItem(-1);

      final voiceItemNotifier = ref.read(voiceItemProvider.notifier);
      voiceItemNotifier.clearValues();
    }
  }

  Map<String, dynamic> get cachedPlayingItems {
    try {
      return {
        'sortOrder': ref.read(sortOrderProvider).cachedPlayingItem!,
        'category': ref.read(categoryProvider).cachedPlayingItem!,
        'cv': ref.read(cvProvider).cachedPlayingItem,
        'voiceWork': ref.read(voiceWorkProvider).cachedPlayingItem,
        'voiceItem': ref.read(voiceItemProvider).cachedPlayingItem,
      };
    } catch (e) {
      Log.debug('Error getting playingItems.\n$e.');
      return {};
    }
  }

  Map<String, dynamic> get cachedSelectedItems {
    try {
      return {
        'sortOrder': ref.read(sortOrderProvider).cachedSelectedItem!,
        'category': ref.read(categoryProvider).cachedSelectedItem!,
        'cv': ref.read(cvProvider).cachedSelectedItem!,
        'voiceWork': ref.read(voiceWorkProvider).cachedSelectedItem,
        'voiceItem': ref.read(voiceItemProvider).cachedSelectedItem,
      };
    } catch (e) {
      Log.debug('Error getting selectedItems.\n$e');
      return {};
    }
  }

  void setPlayingIndexByCache(Map<String, dynamic> playingItems) {
    try {
      ref
          .read(sortOrderProvider.notifier)
          .setPlayingIndexByValue(playingItems['sortOrder'] as SortOrder);
      ref
          .read(categoryProvider.notifier)
          .setPlayingIndexByValue(playingItems['category'] as String);
      ref
          .read(cvProvider.notifier)
          .setPlayingIndexByValue(playingItems['cv'] as String);
      ref
          .read(voiceWorkProvider.notifier)
          .setPlayingIndexByValue(playingItems['voiceWork']);
      ref
          .read(voiceItemProvider.notifier)
          .setPlayingIndexByValue(playingItems['voiceItem']);
    } catch (e) {
      Log.debug('Error setting playingIndex by map.\n$e');
    }
  }

  void setSelectedIndexByCache(Map<String, dynamic> selectedItems) {
    try {
      ref
          .read(sortOrderProvider.notifier)
          .setSelectedIndexByValue(selectedItems['sortOrder'] as SortOrder);
      ref
          .read(categoryProvider.notifier)
          .setSelectedIndexByValue(selectedItems['category'] as String);
      ref
          .read(cvProvider.notifier)
          .setSelectedIndexByValue(selectedItems['cv'] as String);
      ref
          .read(voiceWorkProvider.notifier)
          .setSelectedIndexByValue(selectedItems['voiceWork']);
      ref
          .read(voiceItemProvider.notifier)
          .setSelectedIndexByValue(selectedItems['voiceItem']);
    } catch (e) {
      Log.debug('Error setting selectedIndex by map.\n$e');
    }
  }

  void cacheAllPlayingState() {
    ref.read(sortOrderProvider.notifier).cachePlayingState();
    ref.read(categoryProvider.notifier).cachePlayingState();
    ref.read(cvProvider.notifier).cachePlayingState();
    ref.read(voiceWorkProvider.notifier).cachePlayingState();

    ref.read(voiceItemProvider.notifier).cachePlayingState();
    // 生成随机播放列表
    if (ref.read(audioProvider).isShufflePlay) {
      shufflePlayingState();
    }
  }

  void restoreAllPlayingState() {
    ref.read(sortOrderProvider.notifier).restorePlayingState();
    ref.read(categoryProvider.notifier).restorePlayingState();
    ref.read(cvProvider.notifier).restorePlayingState();
    ref.read(voiceWorkProvider.notifier).restorePlayingState();

    ref.read(voiceItemProvider.notifier).restorePlayingState();
    if (ref.read(audioProvider).isShufflePlay) {
      restoreShuffledState();
    }
  }

  void shufflePlayingState() {
    final voiceItemState = ref.read(voiceItemProvider);
    if (!voiceItemState.isPlaying) return;

    final shuffledValues = List.of(voiceItemState.playingValues)..shuffle();
    final newPlayingIndex =
        shuffledValues.indexOf(voiceItemState.cachedPlayingItem!);

    ref.read(voiceItemProvider.notifier).cachePlayingState(
        playingIndex: newPlayingIndex, playingValues: shuffledValues);
  }

  void restoreShuffledState() {
    final voiceItemState = ref.read(voiceItemProvider);
    final viNotifier = ref.read(voiceItemProvider.notifier);

    // isPlaying时shuffle需要重新赋值playingIndex
    final restoredValues = List.of(voiceItemState.playingValues)
      ..sort((a, b) => compareNatural(a.title, b.title));

    // selectedIndex
    final restoredSelectedIndex = voiceItemState.isPlaying
        ? restoredValues.indexOf(voiceItemState.cachedPlayingItem!)
        : -1;

    viNotifier.restorePlayingState(
        selectedIndex: restoredSelectedIndex, values: restoredValues);
    viNotifier.cacheSelectedIndexAndItem(restoredSelectedIndex);
  }

  void removeShuffledState() {
    final voiceItemNotifier = ref.read(voiceItemProvider.notifier);
    final voiceItemState = ref.read(voiceItemProvider);

    // playingValues按title排序
    final newPlayingValues = List.of(voiceItemState.playingValues)
      ..sort((a, b) => compareNatural(a.title, b.title));

    // playingIndex
    final newPlayingIndex =
        newPlayingValues.indexOf(voiceItemState.cachedPlayingItem!);
    voiceItemNotifier.cachePlayingState(
        playingIndex: newPlayingIndex, playingValues: newPlayingValues);
  }

  Future<void> revealInExplorerView() async {
    if (ref.read(isSelectedVoiceWorkPlaying)) {
      selectPlayingVoiceItem();
    } else {
      String path = '';
      final vwProvider = ref.read(voiceWorkProvider);
      final selectedIndex = vwProvider.selectedIndex;

      if (selectedIndex != -1) {
        final selectedVw = vwProvider.selectedItem;
        path = p.join(selectedVw.directoryPath, selectedVw.sourceId);
      } else {
        final vwRootDirPath =
            (await ref.read(configJsonProvider).read())['voiceWorkRoot'] ?? '';
        final cate = ref.read(categoryProvider).cachedSelectedItem;
        path = p.join(vwRootDirPath, cate == null || cate == 'All' ? '' : cate);
      }

      Process.run('explorer "$path"', []);
    }
  }

  void selectPlayingVoiceItem() {
    // flutter will replace " with /" in arg list. weird
    // code below doesn't work
    // Process.run('explorer', ['/select,', '"$playingViPath"']); // wrap path in "" so that Windows can resolve it
    Process.run(
        'explorer /select, "${ref.read(voiceItemProvider).cachedPlayingVoiceItemPath}"',
        []);
  }

  /// Resets the filters(sortorder excluded) and scrolls to the top.
  Future<void> onResetFilterPressed() async {
    ref.read(categoryProvider.notifier).cacheSelectedIndexAndItem(0);
    await ref.read(cvProvider.notifier).onSelected(0);

    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToIndex(cateScrollController, 0);
      scrollToIndex(cvScrollController, 0);
      scrollToIndex(vwScrollController, 0);
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
    if (!ref.read(isSelectedVoiceWorkPlaying)) {
      restoreAllPlayingState();
    }
    scrollToSelectedIndex();
  }

  void scrollToSelectedIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToIndex(
            cateScrollController, ref.read(categoryProvider).selectedIndex);
        scrollToIndex(cvScrollController, ref.read(cvProvider).selectedIndex);
        scrollToIndex(
            vwScrollController, ref.read(voiceWorkProvider).selectedIndex);

        // final viIdx = ref.read(audioProvider).isShufflePlay
        //     ? ref.read(voiceItemProvider).selectedIndex
        //     : ref.read(voiceItemProvider).playingIndex;
        scrollToIndex(
            viScrollController, ref.read(voiceItemProvider).selectedIndex);
      });
    });
  }

  Future<void> onExit() async {
    await ref.read(historyManagerProvider).saveHistory();

    // 不要用windowManager.destroy()，有明显的卡顿
    windowManager
      ..setPreventClose(false)
      ..close();
  }
}
