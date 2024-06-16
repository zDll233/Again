import 'dart:io';

import 'package:again/controller/database_controller.dart';
import 'package:again/database/database.dart';
import 'package:drift/drift.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:path/path.dart' as p;

class VoiceUpdater {
  VoiceUpdater(String root) : rootDir = Directory(root);

  late Directory rootDir;
  final DatabaseController db = Get.find();

  static const List<String> audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
  ];

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

  List<String> getCVList(String vkTitle) {
    return vkTitle.split('-')[0].split('&');
  }

  Future<void> insertVoiceWorkCategories() async {
    List<TVoiceWorkCategoryCompanion> vkcc = [
      const TVoiceWorkCategoryCompanion(
        description: Value('All'),
        rowid: Value.absent(),
      )
    ];
    await for (var collectionDir in rootDir.list()) {
      vkcc.add(TVoiceWorkCategoryCompanion(
        description: Value(p.basename(collectionDir.path)),
        rowid: const Value.absent(),
      ));
    }
    await db.database.insertMultipleVoiceWorkCategories(vkcc);
  }

  Future<void> insertVoiceWorks(Directory collectionDir) async {
    List<TVoiceWorkCompanion> vkc = [];
    Set<String> cvNames = {};
    List<TCVCompanion> cvc = [
      const TCVCompanion(
        cvName: Value('All'),
        rowid: Value.absent(),
      )
    ];
    List<TVoiceCVCompanion> vcc = [];

    await for (var entity in collectionDir.list()) {
      String vkTitle = p.basename(entity.path);

      // VoiceWork
      vkc.add(TVoiceWorkCompanion(
        title: Value(vkTitle),
        diretoryPath: Value(entity.path),
        category: Value(p.basename(entity.parent.path)),
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
    await db.database.insertMultipleVoiceWorks(vkc);

    // cv
    for (var cvName in cvNames) {
      cvc.add(TCVCompanion(
        cvName: Value(cvName),
        rowid: const Value.absent(),
      ));
    }
    await db.database.insertMultipleCvs(cvc);

    // cv vk
    await db.database.insertMultipleVoiceCvs(vcc);
  }

  Future<void> insertVoiceItems(Directory voiceWorkDir) async {
    List<TVoiceItemCompanion> vic = [];

    await for (var entity in voiceWorkDir.list(recursive: true)) {
      if (entity is File &&
          audioExtensions.any((ext) => entity.path.endsWith(ext))) {
        vic.add(TVoiceItemCompanion(
          title: Value(p.basenameWithoutExtension(entity.path)),
          filePath: Value(entity.path),
          voiceWorkTitle: Value(p.basename(voiceWorkDir.path)),
          rowid: const Value.absent(),
        ));
      }
    }
    await db.database.insertMultipleVoiceItems(vic);
  }
}
