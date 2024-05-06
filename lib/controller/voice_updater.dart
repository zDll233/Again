import 'dart:io';

import 'package:drift/drift.dart';

import '../database/database.dart';

// 'E:\\Media\ACG\\音声\\Marked'
// 'E:\\Media\ACG\\音声\\Loved'

class VoiceUpdater {
  VoiceUpdater(String root) : rootDir = Directory(root);

  late Directory rootDir;

  String getTitleFromPath(String path) {
    int lastIndex = path.lastIndexOf('\\');
    String result = lastIndex != -1 ? path.substring(lastIndex + 1) : path;
    return result;
  }

  Future<void> initialize() async {
    await insertVoiceWorkCategories();  // categories
    await for (var collectionDir in rootDir.list()) {
      if (collectionDir is Directory) {
        await insertVoiceWorks(collectionDir);  // voiceWorks
        await for (var voiceWorkDir in collectionDir.list()){
          if(voiceWorkDir is Directory){
            await insertVoiceItems(voiceWorkDir); // voiceItems
          }
        }
      }
    }
  }

  Future<void> insertVoiceWorkCategories() async {
    List<TVoiceWorkCategoryCompanion> vkcc = [];
    await for (var collectionDir in rootDir.list()) {
      vkcc.add(TVoiceWorkCategoryCompanion(
        description: Value(getTitleFromPath(collectionDir.path)),
        rowid: const Value.absent(),
      ));
    }
    await database.insertMultipleVoiceWorkCategories(vkcc);
  }

  Future<void> insertVoiceWorks(Directory collectionDir) async {
    List<TVoiceWorkCompanion> vkc = [];
    await for (var entity in collectionDir.list()) {
      vkc.add(TVoiceWorkCompanion(
        title: Value(getTitleFromPath(entity.path)),
        diretoryPath: Value(entity.path),
        category: Value(getTitleFromPath(entity.parent.path)),
        createdAt: Value(await entity.stat().then((v) => v.changed)),
        rowid: const Value.absent(),
      ));
    }
    await database.insertMultipleVoiceWorks(vkc);
  }

  Future<void> insertVoiceItems(Directory voiceWorkDir) async {
    List<TVoiceItemCompanion> vic = [];
    await for (var entity in voiceWorkDir.list(recursive: true)) {
      if (entity is File &&
          (entity.path.endsWith('wav') || entity.path.endsWith('mp3'))) {
        vic.add(TVoiceItemCompanion(
          title: Value(getTitleFromPath(entity.path)),
          filePath: Value(entity.path),
          voiceWorkTitle: Value(getTitleFromPath(voiceWorkDir.path)),
          rowid: const Value.absent(),
        ));
      }
    }
    await database.insertMultipleVoiceItems(vic);
  }
}

void voiceUpdate() async {
  await database.into(database.tVoiceWorkCategory).insert(
      TVoiceWorkCategoryCompanion.insert(description: 'Marked'),
      mode: InsertMode.insertOrIgnore);

  await database.into(database.tVoiceWork).insert(
      TVoiceWorkCompanion.insert(
        title: '陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～',
        diretoryPath:
            'E:\\Media\\ACG\\音声\\Marked\\陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～',
        category: 'Marked',
      ),
      mode: InsertMode.insertOrIgnore);

  await database.into(database.tVoiceItem).insert(
      TVoiceItemCompanion.insert(
          title: 'とらっく２ りなと添い寝',
          filePath:
              'E:\\Media\\ACG\\音声\\Marked\\陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～\\RJ01129638\\WAV\\とらっく２ りなと添い寝.wav',
          voiceWorkTitle: '陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～'),
      mode: InsertMode.insertOrIgnore);
}
