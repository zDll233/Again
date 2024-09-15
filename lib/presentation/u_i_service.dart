import 'dart:async';
import 'dart:io';

import 'package:again/models/voice_work.dart';
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

  void cacheAllPlayingIndex() {
    ref.read(sortOrderProvider.notifier).cachePlayingIndex();
    ref.read(categoryProvider.notifier).cachePlayingIndex();
    ref.read(cvProvider.notifier).cachePlayingIndex();
    ref.read(voiceWorkProvider.notifier).cachePlayingIndex();
    ref.read(voiceItemProvider.notifier).cachePlayingIndex();
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
      {int? sort}) async {
    if (sort != null) {
      ref.read(sortOrderProvider.notifier).updatePlayingIndex(sort);
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
    ref.read(voiceWorkProvider.notifier).cachePlayingValues();
    ref.read(voiceItemProvider.notifier).cachePlayingValues();
    cacheAllPlayingIndex();
  }

  Future<void> revealInExplorerView() async {
    // final db = Get.find<DatabaseController>();
    // VoiceWork vk = await db.getVkByPath(selectedVkPath);

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

  /// Locates the playing item by updating the selection and scrolling to it.
  Future<void> onLocateBtnPressed() async {
    if (!isVoiceWorkPlaying) {
      await _setFilterPlaying();
    }
    scrollToPlayingIdx();
  }

  /// set filter playing idx value, update vk list
  ///
  /// filterSelected will open vi list when filter is playing
  Future<void> _setFilterPlaying() async {
    // sortOrder.value = playingSortOrder;
    // selectedCategoryIdx.value = playingCategoryIdx.value;
    // await onCvSelected(playingCvIdx.value);
    ref.read(sortOrderProvider.notifier).setSelectedIndex2Playing();
    ref.read(categoryProvider.notifier).setSelectedIndex2Playing();
    await ref
        .read(cvProvider.notifier)
        .onSelected(ref.read(cvProvider).playingIndex);
  }

  void scrollToPlayingIdx() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await viCompleter.future;
        scrollToIndex(
            cateScrollController, ref.read(categoryProvider).playingIndex);
        scrollToIndex(cvScrollController, ref.read(cvProvider).playingIndex);
        scrollToIndex(
            vkScrollController, ref.read(voiceWorkProvider).playingIndex);
        scrollToIndex(
            viScrollController, ref.read(voiceItemProvider).playingIndex);
      });
    });
  }
}
