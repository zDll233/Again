import 'dart:io';

import 'package:again/const/const.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/services/voice_updater.dart';
import 'package:again/repository/database/database.dart';
import 'package:again/repository/database_repository_state.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseRepositoryNotifier extends Notifier<DatabaseRepositoryState> {
  late final AppDatabase _database;
  late VoiceUpdater _voiceUpdater;

  @override
  DatabaseRepositoryState build() {
    _database = ref.read(databaseProvider);
    return DatabaseRepositoryState();
  }

  Future<void> initialize() async {
    final data = await ref.read(configJsonProvider).read();
    final vkRootDirPath = data['voiceWorkRoot'] ?? '';

    if (await Directory(vkRootDirPath).exists()) {
      await _initializeVoiceUpdater(vkRootDirPath);
    } else {
      await selectAndSaveRootDirectory();
    }
  }

  Future<void> _initializeVoiceUpdater(String rootDirpath) async {
    _voiceUpdater = VoiceUpdater(rootDirpath, ref);
  }

  Future<void> selectAndSaveRootDirectory() async {
    final selectedDirPath =
        await FilePicker.platform.getDirectoryPath(dialogTitle: '请选择音声作品根目录');
    if (selectedDirPath != null) {
      await _initializeVoiceUpdater(selectedDirPath);
      await ref.read(configJsonProvider).write({'voiceWorkRoot': selectedDirPath});
      await onUpdatePressed();
    }
  }

  Future<void> _updateDatabase() async {
    await _database.transaction(() async {
      final tables = _database.allTables.toList().reversed;
      for (final table in tables) {
        await _database.delete(table).go();
      }
    });
    await _voiceUpdater.insert();
  }

  Future<void> updateViewList() async {
    await updateFilterLists();
    await updateVkList();
    await updateViList();
  }

  /// update [CategoryState.values], [CvState.values]. If cateLs or cvLs is null, get both lists from db.
  Future<void> updateFilterLists({
    List<TVoiceWorkCategoryData>? cateLs,
    List<TCVData>? cvLs,
  }) async {
    cateLs ??= await _getCategoryDataList;
    cvLs ??= await _getCvDataList;

    ref
        .read(categoryProvider.notifier)
        .setValues(['All'] + cateLs.map((e) => e.description).toList());
    ref
        .read(cvProvider.notifier)
        .setValues(['All'] + cvLs.map((e) => e.cvName).toList());
  }

  Future<List<TVoiceWorkCategoryData>> get _getCategoryDataList async {
    final categories = await _database.selectAllCategory();
    categories.sort((a, b) => compareNatural(a.description, b.description));
    return categories;
  }

  Future<List<TCVData>> get _getCvDataList async {
    final cvList = await _database.selectAllCv();
    cvList.sort((a, b) => compareNatural(a.cvName, b.cvName));
    return cvList;
  }

  /// update and sort [VoiceWork.values]. If vkLs is null, get it from db according to playing filters.
  Future<void> updateVkList() async {
    final cate = ref.read(categoryProvider).cachedSelectedItem!;
    final cv = ref.read(cvProvider).cachedSelectedItem!;

    final vkLs = await getVkDataList(cate, cv);
    final sortedList = sortVoiceWorkList(VoiceWork.vkDataList2VkList(vkLs));
    ref.read(voiceWorkProvider.notifier).setValues(sortedList);
  }

  Future<List<TVoiceWorkData>> getVkDataList(String cate, String cv) async {
    if (cate == "All" && cv == "All") {
      return await _database.selectAllVoiceWorks;
    } else if (cate == "All") {
      return await _database.selectVkWithCv(cv);
    } else if (cv == "All") {
      return await _database.selectVkWithCategory(cate);
    } else {
      return await _database.selectVkWithCvAndCategory(cv, cate);
    }
  }

  List<VoiceWork> sortVoiceWorkList(List<VoiceWork> vkLs, {SortOrder? sort}) {
    switch (sort ?? ref.read(sortOrderProvider).cachedSelectedItem!) {
      case SortOrder.byTitle:
        vkLs.sort((a, b) => compareNatural(a.title, b.title));
        break;
      case SortOrder.byCreatedAt:
        vkLs.sort((a, b) => (b.createdAt ?? DateTime(1970))
            .compareTo(a.createdAt ?? DateTime(1970)));
        break;
    }
    return vkLs;
  }

  /// update [VoiceItemState.values]. If viLs is null, get it from db
  Future<void> updateViList() async {
    var vkPath = ref.read(voiceWorkProvider).cachedSelectedVoiceWorkPath ?? '';
    final viLs = await getViList(vkPath);
    ref.read(voiceItemProvider.notifier).setValues(
          (viLs),
        );
  }

  Future<List<VoiceItem>> getViList(String vkPath) async {
    final viDataLs = await _database.selectSingleWorkVoiceItemsWithPath(vkPath)
      ..sort((a, b) => compareNatural(a.title, b.title));
    return VoiceItem.viDataList2ViList(viDataLs);
  }

  Future<void> onUpdatePressed() async {
    final uiService = ref.read(uiServiceProvider);

    final playingItems = uiService.cachedPlayingItems;
    final selectedItems = uiService.cachedSelectedItems;

    await _updateDatabase();
    await updateViewList();

    // 先更新`playingValues`
    await updatePlayingValues(playingItems['category'], playingItems['cv'],
        playingItems['voiceWork']);

    // 再更新`playingIndex`
    if (playingItems.isNotEmpty) {
      uiService.setPlayingIndexByCache(playingItems);
    }
    if (selectedItems.isNotEmpty) {
      uiService.setSelectedIndexByCache(selectedItems);
    }
  }

  Future<void> updatePlayingValues(
      String cate, String cv, VoiceWork? voiceWork) async {
    if (ref.read(voiceWorkProvider).isPlaying) {
      // voiceWorkState.playingValues
      final playingVkLs = await getVkDataList(cate, cv);
      final sortedList = sortVoiceWorkList(
          VoiceWork.vkDataList2VkList(playingVkLs),
          sort: ref.read(sortOrderProvider).cachedPlayingItem!);
      ref.read(voiceWorkProvider.notifier).setPlayingValues(sortedList);

      // voiceItemState.playingValues
      final viLs = await getViList(voiceWork?.directoryPath ?? '');
      ref.read(voiceItemProvider.notifier).setPlayingValues(viLs);
    }
  }
}
