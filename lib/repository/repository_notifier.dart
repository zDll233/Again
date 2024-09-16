import 'dart:io';

import 'package:again/const/const.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/services/voice_updater.dart';
import 'package:again/repository/database/database.dart';
import 'package:again/repository/repository_state.dart';
import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/utils/log.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepositoryNotifier extends Notifier<RepositoryState> {
  late final AppDatabase _database;
  late VoiceUpdater _voiceUpdater;

  @override
  RepositoryState build() {
    _database = ref.read(databaseProvider);
    return RepositoryState();
  }

  Future<void> initialize() async {
    final data = await ref.read(configProvider).read();
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
      await ref.read(configProvider).write({'voiceWorkRoot': selectedDirPath});
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
        .updateValues(['All'] + cateLs.map((e) => e.description).toList());
    ref
        .read(cvProvider.notifier)
        .updateValues(['All'] + cvLs.map((e) => e.cvName).toList());
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
  Future<void> updateVkList({List<TVoiceWorkData>? vkLs}) async {
    String cate = '';
    String cv = '';
    try {
      cate = ref.read(categoryProvider).selectedItem;
      cv = ref.read(cvProvider).selectedItem;
    } catch (e) {
      Log.debug('$e');
    }
    vkLs ??= await getVkDataList(cate, cv);
    final sortedList = sortVoiceWorkList(VoiceWork.vkDataList2VkList(vkLs));
    ref.read(voiceWorkProvider.notifier).updateValues(sortedList);
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
    switch (sort ?? ref.read(sortOrderProvider).selectedItem) {
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
  Future<void> updateViList({List<TVoiceItemData>? viLs}) async {
    viLs ??= await _getSelectedViList;
    ref.read(voiceItemProvider.notifier).updateValues(
          VoiceItem.viDataList2ViList(viLs),
        );
  }

  Future<List<TVoiceItemData>> get _getSelectedViList async {
    String vkPath = '';
    try {
      final voiceWorkState = ref.read(voiceWorkProvider);
      vkPath = voiceWorkState.cachedSelectedVoiceWorkPath!;
    } catch (e) {
      Log.debug('error `_getSelectedViList`\n$e');
    }
    return await _database.selectSingleWorkVoiceItemsWithString(vkPath)
      ..sort((a, b) => compareNatural(a.title, b.title));
  }

  Future<void> onUpdatePressed() async {
    final uiService = ref.read(uiServiceProvider);

    final playingItems = uiService.playingItems;
    final selectedItems = uiService.selectedItems;

    await _updateDatabase();
    await updateViewList();

    if (playingItems.isNotEmpty) {
      uiService.setPlayingIndexByMap(playingItems);
    }
    if (selectedItems.isNotEmpty) {
      uiService.setSelectedIndexByMap(selectedItems);
    }
  }
}
