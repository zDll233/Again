import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/database/voice_updater.dart';
import 'package:again/services/database/db/database.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseNotifier {
  late VoiceUpdater _voiceUpdater;
  late final AppDatabase _database;

  final Ref ref;
  DatabaseNotifier(this.ref) : _database = ref.read(dbProvider);

  Future<void> initialize() async {
    final data = await ref.read(configJsonProvider).read();
    final vwRootDirPath = data['voiceWorkRoot'] ?? '';

    if (await Directory(vwRootDirPath).exists()) {
      _voiceUpdater = VoiceUpdater(_database, vwRootDirPath);
    } else {
      await selectAndSaveRootDirectory();
    }
  }

  Future<void> selectAndSaveRootDirectory() async {
    final selectedDirPath = await FilePicker.getDirectoryPath(
      dialogTitle: '请选择音声作品根目录',
      // 以主窗口为 owner, 无 owner 的 IFileDialog 在部分 Windows 上会
      // 在 comdlg32 内崩溃 (0xc0000005)
      lockParentWindow: true,
    );
    if (selectedDirPath != null) {
      _voiceUpdater = VoiceUpdater(_database, selectedDirPath);
      await ref
          .read(configJsonProvider)
          .write({'voiceWorkRoot': selectedDirPath});
      await onUpdatePressed();
    }
  }

  Future<void> _updateDatabase() async {
    await _voiceUpdater.update();
  }

  Future<void> updateViewList() async {
    await updateFilterLists();
    await updateVwList();
    await updateViList();
  }

  /// update [CategoryState.values], [CvState.values]. If cateLs or cvLs is null, get both lists from db.
  Future<void> updateFilterLists() async {
    final cateLs = await _getCategoryDataList;

    ref
        .read(categoryProvider.notifier)
        .setValues(['All'] + cateLs.map((e) => e.description).toList());

    // CV 跟随当前分类, 按作品数倒序
    await updateCvList(
      ref.read(categoryProvider).cachedSelectedItem ?? 'All',
    );
  }

  /// 刷新 CV 列表: 跟随分类 + 按作品数倒序, 并重置选中为 All。
  Future<void> updateCvList(String category) async {
    final cvs = await _database.selectCvsOrderedByCount(
      category == 'All' ? null : category,
    );
    final cvNotifier = ref.read(cvProvider.notifier);
    cvNotifier.setValues(['All', ...cvs]);
    cvNotifier.cacheSelectedIndexAndItem(0);
  }

  Future<List<TVoiceWorkCategoryData>> get _getCategoryDataList async {
    final categories = await _database.selectAllCategory();
    categories.sort((a, b) => compareNatural(a.description, b.description));
    return categories;
  }

  /// update and sort [VoiceWork.values]. If vwLs is null, get it from db according to playing filters.
  Future<void> updateVwList() async {
    final cate = ref.read(categoryProvider).cachedSelectedItem!;
    final cv = ref.read(cvProvider).cachedSelectedItem!;

    final vwLs = await getVwDataList(cate, cv);
    final sortedList = sortVoiceWorkList(VoiceWork.vwDataList2VwList(vwLs));
    ref.read(voiceWorkProvider.notifier).setValues(sortedList);
  }

  Future<List<TVoiceWorkData>> getVwDataList(String cate, String cv) async {
    if (cate == 'All' && cv == 'All') {
      return await _database.selectAllVoiceWorks;
    } else if (cate == 'All') {
      return await _database.selectVwWithCv(cv);
    } else if (cv == 'All') {
      return await _database.selectVwWithCategory(cate);
    } else {
      return await _database.selectVwWithCvAndCategory(cv, cate);
    }
  }

  List<VoiceWork> sortVoiceWorkList(List<VoiceWork> vwLs, {SortOrder? sort}) {
    switch (sort ?? ref.read(sortOrderProvider).cachedSelectedItem!) {
      case SortOrder.byTitle:
        vwLs.sort((a, b) => compareNatural(a.title, b.title));
        break;
      case SortOrder.byCreatedAt:
        vwLs.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        break;
    }
    return vwLs;
  }

  /// update [VoiceItemState.values].
  Future<void> updateViList() async {
    final voiceWorkState = ref.read(voiceWorkProvider);
    final voiceItemNotifier = ref.read(voiceItemProvider.notifier);
    if (!voiceWorkState.cachedSelectedVoiceWorkExist) {
      Log.info('Error updating voiceItem list\n'
          'error: selected voicework ${voiceWorkState.cachedSelectedItem?.title} not exists.');
      voiceItemNotifier.clearValues();
    } else {
      final vwPath = voiceWorkState.cachedSelectedVoiceWorkPath!;
      final viLs = await getViList(vwPath);
      voiceItemNotifier.setValues(viLs);
    }
  }

  Future<List<VoiceItem>> getViList(String vwPath) async {
    final viDataLs = await _database.selectSingleWorkVoiceItemsWithPath(vwPath)
      ..sort((a, b) => compareNatural(a.title, b.title));
    return VoiceItem.viDataList2ViList(viDataLs);
  }

  Future<void> onUpdatePressed() async {
    await _updateDatabase();
    await updateViewList();

    final uiService = ref.read(uiServiceProvider);
    final cachedPlayingItems = uiService.cachedPlayingItems;
    final cachedSelectedItems = uiService.cachedSelectedItems;

    // 先更新`playingValues`
    await updatePlayingValues(
      cachedPlayingItems['category'] as String,
      cachedPlayingItems['cv'] as String,
      cachedPlayingItems['voiceWork'] as VoiceWork?,
    );

    // 再更新`playingIndex`
    if (cachedPlayingItems.isNotEmpty) {
      uiService.setPlayingIndexByCache(cachedPlayingItems);
    }
    if (cachedSelectedItems.isNotEmpty) {
      uiService.setSelectedIndexByCache(cachedSelectedItems);
    }
  }

  /// 启动后的静默增量刷新，失败只记日志，不影响启动。
  Future<void> silentRefresh() async {
    try {
      await onUpdatePressed();
      Log.info('Silent refresh finished.');
    } catch (e, st) {
      Log.error('Error in silent refresh.\n$e\n$st');
    }
  }

  Future<void> updatePlayingValues(
      String cate, String cv, VoiceWork? voiceWork) async {
    if (ref.read(voiceWorkProvider).isPlaying) {
      // voiceWorkState.playingValues
      final playingVwLs = await getVwDataList(cate, cv);
      final sortedVwLs = sortVoiceWorkList(
        VoiceWork.vwDataList2VwList(playingVwLs),
        sort: ref.read(sortOrderProvider).cachedPlayingItem!,
      );
      ref.read(voiceWorkProvider.notifier).setPlayingValues(sortedVwLs);

      // voiceItemState.playingValues
      final viLs = await getViList(voiceWork?.directoryPath ?? '');
      ref.read(voiceItemProvider.notifier).setPlayingValues(viLs);
    }
  }
}
