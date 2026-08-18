import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/database/db/database.dart';
import 'package:again/utils/file_time.dart';
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
        // 排序用的"时间"= 目录创建时间 (添加时间), 非修改时间:
        // 批量添加时入库时间都一样, mtime 会随内容变动而变化;
        // dart:io 无创建时间 API, 用 Win32 CreateFileW + GetFileTime 读取
        createdAt: directoryCreationTime(directoryPath) ??
            workEntity.statSync().modified,
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
  /// 写路径全部批量合并; CV 关系按变更作品差量维护, 最后清理孤立 CV。
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
        (await _database.selectAllVoiceItemPaths).groupListsBy(
      (i) => i.voiceWorkPath,
    );
    final scannedPaths = <String>{};
    final changedWorks = <WorkScanInfo>[];
    final workCompanions = <TVoiceWorkCompanion>[];
    final itemCompanions = <TVoiceItemCompanion>[];

    // 识别变更作品（无变化作品零写入）
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

      changedWorks.add(work);
      workCompanions.add(TVoiceWorkCompanion(
        title: Value(work.title),
        sourceId: Value(work.sourceId),
        directoryPath: Value(work.directoryPath),
        coverPath: Value(work.coverPath),
        category: Value(work.category),
        createdAt: Value(work.createdAt),
        rowid: const Value.absent(),
      ));
      itemCompanions.addAll([
        for (final item in work.items)
          TVoiceItemCompanion(
            title: Value(item.title),
            filePath: Value(item.filePath),
            voiceWorkPath: Value(work.directoryPath),
            rowid: const Value.absent(),
          ),
      ]);
    }

    // 磁盘上已消失的作品
    final removedPaths = [
      for (final w in existingWorks)
        if (!scannedPaths.contains(w.directoryPath)) w.directoryPath,
    ];

    // 一次 batch 完成所有写入（删除顺序满足外键: 先子表后父表）
    final changedPaths = [for (final w in changedWorks) w.directoryPath];
    if (removedPaths.isNotEmpty || changedPaths.isNotEmpty) {
      await _database.batch((batch) {
        if (removedPaths.isNotEmpty) {
          batch.deleteWhere(_database.tVoiceCV,
              (t) => t.voiceWorkPath.isIn(removedPaths));
          batch.deleteWhere(_database.tVoiceItem,
              (t) => t.voiceWorkPath.isIn(removedPaths));
          batch.deleteWhere(_database.tVoiceWork,
              (t) => t.directoryPath.isIn(removedPaths));
        }
        if (changedPaths.isNotEmpty) {
          // changed 作品整作品重写 (含其 CV 关系), 差量粒度=作品
          batch.deleteWhere(_database.tVoiceCV,
              (t) => t.voiceWorkPath.isIn(changedPaths));
          batch.deleteWhere(_database.tVoiceItem,
              (t) => t.voiceWorkPath.isIn(changedPaths));
          batch.deleteWhere(_database.tVoiceWork,
              (t) => t.directoryPath.isIn(changedPaths));
          batch.insertAll(_database.tVoiceWork, workCompanions);
          batch.insertAll(_database.tVoiceItem, itemCompanions,
              mode: InsertMode.insertOrIgnore);
        }
      });
    }

    // 删除已消失的类别（此时已无作品引用）
    final removedCategories =
        existingCategories.difference(scannedCategoryNames);
    if (removedCategories.isNotEmpty) {
      await _database.deleteCategories(removedCategories);
    }

    // CV 关系同步（仅变更作品重建; 不变式: 结果恒等于从全部标题全量推导）
    if (changedPaths.isNotEmpty || removedPaths.isNotEmpty) {
      final newCvNames = <String>{};
      final vcc = <TVoiceCVCompanion>[];
      for (final work in scan.works) {
        if (!changedPaths.contains(work.directoryPath)) continue;
        for (final cv in getCvList(work.title)) {
          newCvNames.add(cv);
          vcc.add(TVoiceCVCompanion(
            voiceWorkPath: Value(work.directoryPath),
            cvName: Value(cv),
            rowid: const Value.absent(),
          ));
        }
      }
      if (newCvNames.isNotEmpty) {
        await _database.insertCvBatch([
          for (final c in newCvNames)
            TCVCompanion(cvName: Value(c), rowid: const Value.absent()),
        ]);
        await _database.insertVoiceCvBatch(vcc);
      }

      // 清理不再被引用的孤立 CV (覆盖删除作品/改名后消失的 CV)
      await _database.deleteOrphanCvs();
    }
  }
}
