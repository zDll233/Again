import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/database/db/database.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// 一次扫描的结果，全部为可跨 isolate 拷贝的纯数据。
class ScanResult {
  final List<String> categoryNames;
  final List<WorkScanInfo> works;

  const ScanResult({required this.categoryNames, required this.works});
}

class WorkScanInfo {
  final String title;
  final String sourceId;
  final String directoryPath;
  final String coverPath;
  final String category;
  final DateTime createdAt;
  final List<ItemScanInfo> items;

  const WorkScanInfo({
    required this.title,
    required this.sourceId,
    required this.directoryPath,
    required this.coverPath,
    required this.category,
    required this.createdAt,
    required this.items,
  });
}

class ItemScanInfo {
  final String title;
  final String filePath;

  const ItemScanInfo({required this.title, required this.filePath});
}

/// 扫描音声作品根目录。运行在后台 isolate 中。
/// 始终全量收集每个作品的音频条目, 变化检测在 [_VoiceUpdater._sync]
/// 中通过与数据库现有条目做集合对比完成
/// (Windows 上目录 mtime 对深层文件增删不可靠, 不能用作跳过依据)。
ScanResult scanRoot(String rootDirPath) {
  final rootDir = Directory(rootDirPath);
  final categoryNames = <String>[];
  final works = <WorkScanInfo>[];

  for (final categoryEntity in rootDir.listSync()) {
    if (categoryEntity is! Directory) continue;

    final category = p.basename(categoryEntity.path);
    categoryNames.add(category);

    for (final workEntity in categoryEntity.listSync()) {
      if (workEntity is! Directory) continue;

      final directoryPath = workEntity.path;
      final title = p.basename(directoryPath);

      String sourceId = '';
      String coverPath = '';
      final items = <ItemScanInfo>[];

      for (final e in workEntity.listSync(recursive: true)) {
        final ext = p.extension(e.path).toLowerCase();
        if (e is Directory) {
          if (sourceId.isEmpty && isSourceIdValid(p.basename(e.path))) {
            sourceId = p.basename(e.path).toUpperCase();
          }
        } else if (e is File) {
          if (coverPath.isEmpty && IMG_EXTENSIONS.contains(ext)) {
            coverPath = e.path;
          } else if (AUDIO_EXTENSIONS.contains(ext)) {
            items.add(ItemScanInfo(
              title: p.basenameWithoutExtension(e.path),
              filePath: e.path,
            ));
          }
        }
      }

      works.add(WorkScanInfo(
        title: title,
        sourceId: sourceId,
        directoryPath: directoryPath,
        coverPath: coverPath,
        category: category,
        createdAt: workEntity.statSync().modified,
        items: items,
      ));
    }
  }

  return ScanResult(categoryNames: categoryNames, works: works);
}

/// parse vw.title to get cv list
List<String> getCvList(String vwTitle) {
  return vwTitle.split('-')[0].split('&');
}

bool isSourceIdValid(String sourceId) =>
    RegExp(r'^(RJ|VJ|BJ)?\d+$', caseSensitive: false).hasMatch(sourceId);

/// compute 的 isolate 入口（必须是顶层函数，参数/返回值可发送）。
ScanResult _scanRootInIsolate(String rootDirPath) {
  return scanRoot(rootDirPath);
}

class VoiceUpdater {
  VoiceUpdater(this._database, String rootDirPath)
      : _rootDir = Directory(rootDirPath);

  final AppDatabase _database;
  late final Directory _rootDir;

  Future<void> update() async {
    final rootDirPath = _rootDir.path;
    final scan = await compute(_scanRootInIsolate, rootDirPath);
    await _database.transaction(() async {
      await _sync(scan);
    });
  }

  /// 增量同步。注意外键约束的删除顺序：tVoiceCV -> tVoiceItem -> TVoiceWork -> category。
  Future<void> _sync(ScanResult scan) async {
    final scannedCategoryNames = scan.categoryNames.toSet();
    final existingCategories =
        (await _database.selectAllCategory())
            .map((e) => e.description)
            .toSet();

    // 新增类别（必须先于作品 upsert，外键约束）
    final newCategories = scannedCategoryNames.difference(existingCategories);
    if (newCategories.isNotEmpty) {
      await _database.insertVoiceWorkCategoryBatch([
        for (final c in newCategories)
          TVoiceWorkCategoryCompanion(
            description: Value(c),
            rowid: const Value.absent(),
          ),
      ]);
    }

    final existingWorks = await _database.selectAllVoiceWorks;
    final existingByPath = {for (final w in existingWorks) w.directoryPath: w};
    final existingItemsByWork =
        (await _database.selectAllVoiceItems).groupListsBy(
      (i) => i.voiceWorkPath,
    );
    final scannedPaths = <String>{};
    var changed = false;

    // 更新或新增作品
    for (final work in scan.works) {
      scannedPaths.add(work.directoryPath);
      final existing = existingByPath[work.directoryPath];
      final existingItemPaths = {
        for (final i in existingItemsByWork[work.directoryPath] ?? const [])
          i.filePath,
      };
      final scannedItemPaths = {for (final i in work.items) i.filePath};
      final itemsUnchanged =
          scannedItemPaths.length == existingItemPaths.length &&
          scannedItemPaths.containsAll(existingItemPaths);
      final unchanged =
          existing != null &&
          itemsUnchanged &&
          existing.title == work.title &&
          existing.category == work.category &&
          existing.sourceId == work.sourceId &&
          existing.coverPath == work.coverPath;
      if (unchanged) {
        continue;
      }

      changed = true;
      await _database.deleteVoiceItemsOfWork(work.directoryPath);
      await _database.upsertVoiceWork(TVoiceWorkCompanion(
        title: Value(work.title),
        sourceId: Value(work.sourceId),
        directoryPath: Value(work.directoryPath),
        coverPath: Value(work.coverPath),
        category: Value(work.category),
        createdAt: Value(work.createdAt),
        rowid: const Value.absent(),
      ));
      if (work.items.isNotEmpty) {
        await _database.insertVoiceItemBatch([
          for (final item in work.items)
            TVoiceItemCompanion(
              title: Value(item.title),
              filePath: Value(item.filePath),
              voiceWorkPath: Value(work.directoryPath),
              rowid: const Value.absent(),
            ),
        ]);
      }
    }

    // 删除磁盘上已消失的作品
    for (final w in existingWorks) {
      if (scannedPaths.contains(w.directoryPath)) {
        continue;
      }
      changed = true;
      await _database.deleteVoiceWorkCvsWithPath(w.directoryPath);
      await _database.deleteVoiceItemsOfWork(w.directoryPath);
      await _database.deleteVoiceWorkWithPath(w.directoryPath);
    }

    // 删除已消失的类别（此时已无作品引用）
    final removedCategories =
        existingCategories.difference(scannedCategoryNames);
    if (removedCategories.isNotEmpty) {
      await _database.deleteCategories(removedCategories);
    }

    // CV 及 CV-作品关系重建（仅在有变化时）
    if (changed) {
      await _database.deleteAllCvs();
      final cvNames = <String>{};
      final vcc = <TVoiceCVCompanion>[];
      for (final work in scan.works) {
        final cvs = getCvList(work.title);
        cvNames.addAll(cvs);
        for (final cv in cvs) {
          vcc.add(TVoiceCVCompanion(
            voiceWorkPath: Value(work.directoryPath),
            cvName: Value(cv),
            rowid: const Value.absent(),
          ));
        }
      }
      if (cvNames.isNotEmpty) {
        await _database.insertCvBatch([
          for (final c in cvNames)
            TCVCompanion(cvName: Value(c), rowid: const Value.absent()),
        ]);
        await _database.insertVoiceCvBatch(vcc);
      }
    }
  }
}
