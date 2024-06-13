import 'dart:io';

import 'package:again/database/database.dart';
import 'package:drift/drift.dart';

VoiceUpdater voiceUpdater = VoiceUpdater('E:\\Media\\ACG\\音声');

class VoiceUpdater {
  VoiceUpdater(String root) : rootDir = Directory(root);

  late Directory rootDir;

  Future<void> update() async {
    await insertVoiceWorkCategories(); // categories
    await for (var collectionDir in rootDir.list()) {
      if (collectionDir is Directory) {
        await insertVoiceWorks(collectionDir); // voiceWorks
        await for (var voiceWorkDir in collectionDir.list()) {
          if (voiceWorkDir is Directory) {
            await insertVoiceItems(voiceWorkDir); // voiceItems
          }
        }
      }
    }
  }

  String getTitleFromPath(String path) {
    int lastIndex = path.lastIndexOf('\\');
    String result = lastIndex != -1 ? path.substring(lastIndex + 1) : path;
    return result;
  }

  List<String> getCVList(String vkTitle) {
    String input = vkTitle;
    List<String> cvList = input.split('-')[0].split('&');
    return cvList;
  }

  Future<void> insertVoiceWorkCategories() async {
    List<TVoiceWorkCategoryCompanion> vkcc = [
      const TVoiceWorkCategoryCompanion(
        description: Value("All"),
        rowid: Value.absent(),
      )
    ];
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
    Set<String> cvNames = {};
    List<TCVCompanion> cvc = [
      const TCVCompanion(
        cvName: Value("All"),
        rowid: Value.absent(),
      )
    ];
    List<TVoiceCVCompanion> vcc = [];

    await for (var entity in collectionDir.list()) {
      String vkTitle = getTitleFromPath(entity.path);

      // VoiceWork
      vkc.add(TVoiceWorkCompanion(
        title: Value(vkTitle),
        diretoryPath: Value(entity.path),
        category: Value(getTitleFromPath(entity.parent.path)),
        createdAt: Value(await entity.stat().then((v) => v.changed)),
        rowid: const Value.absent(),
      ));

      List<String> singleVkCvNames = getCVList(vkTitle);

      // cv
      cvNames.addAll(singleVkCvNames);

      // cv vk
      for (var cvName in singleVkCvNames) {
        vcc.add(TVoiceCVCompanion(
          vkTitle: Value(vkTitle),
          cvName: Value(cvName),
          rowid: const Value.absent(),
        ));
      }
    }

    // VoiceWork
    await database.insertMultipleVoiceWorks(vkc);

    // cv
    for (var cvName in cvNames) {
      cvc.add(TCVCompanion(
        cvName: Value(cvName),
        rowid: const Value.absent(),
      ));
    }
    await database.insertMultipleCvs(cvc);

    // cv vk
    await database.insertMultipleVoiceCvs(vcc);
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
