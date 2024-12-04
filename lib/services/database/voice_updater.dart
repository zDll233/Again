import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/database/db/database.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class VoiceUpdater {
  VoiceUpdater(String root, this.ref) : rootDir = Directory(root);

  late Directory rootDir;
  final Ref ref;

  Future<void> insert() async {
    await insertVoiceWorkCategories(); // categories
    await for (final collectionDir in rootDir.list()) {
      if (collectionDir is Directory) {
        await insertVoiceWorks(collectionDir); // voiceWorks
        await for (final voiceWorkDir in collectionDir.list()) {
          if (voiceWorkDir is Directory) {
            await insertVoiceItems(voiceWorkDir); // voiceItems
          }
        }
      }
    }
  }

  /// parse vk.title to get cv list
  static List<String> getCvList(String vkTitle) {
    return vkTitle.split('-')[0].split('&');
  }

  static bool isSourceIdValid(String sourceId) =>
      RegExp(r'^(RJ|VJ|BJ)?\d+$', caseSensitive: false).hasMatch(sourceId);

  Future<void> insertVoiceWorkCategories() async {
    List<TVoiceWorkCategoryCompanion> vkcc = [];
    await for (final collectionDir in rootDir.list()) {
      vkcc.add(TVoiceWorkCategoryCompanion(
        description: Value(p.basename(collectionDir.path)),
        rowid: const Value.absent(),
      ));
    }
    await ref.read(dbProvider).insertMultipleVoiceWorkCategories(vkcc);
  }

  Future<void> insertVoiceWorks(Directory collectionDir) async {
    List<TVoiceWorkCompanion> vkc = [];
    Set<String> cvNames = {};
    List<TCVCompanion> cvc = [];
    List<TVoiceCVCompanion> vcc = [];

    await for (final entity in collectionDir.list()) {
      if (entity is Directory) {
        String vkTitle = p.basename(entity.path);
        String vkCoverPath = '';
        String vkSourceId = '';

        // vk sourceId, cover
        await for (final e in entity.list(recursive: true)) {
          if (vkSourceId.isEmpty && e is Directory) {
            final folderName = p.basename(e.path);
            vkSourceId = isSourceIdValid(folderName)
                ? folderName.toUpperCase()
                : '无sourceId';
          }

          if (e is File && IMG_EXTENSIONS.any((ext) => e.path.endsWith(ext))) {
            vkCoverPath = e.path;
            break;
          }
        }

        // VoiceWork
        vkc.add(TVoiceWorkCompanion(
          title: Value(vkTitle),
          sourceId: Value(vkSourceId.isEmpty ? '无sourceId' : vkSourceId),
          directoryPath: Value(entity.path),
          coverPath: Value(vkCoverPath),
          category: Value(p.basename(entity.parent.path)),
          createdAt: Value(await entity.stat().then((v) => v.changed)),
          rowid: const Value.absent(),
        ));

        List<String> singleVkCvNames = getCvList(vkTitle);

        // cv
        cvNames.addAll(singleVkCvNames);

        // cv vk
        for (final cvName in singleVkCvNames) {
          vcc.add(TVoiceCVCompanion(
            voiceWorkPath: Value(entity.path),
            cvName: Value(cvName),
            rowid: const Value.absent(),
          ));
        }
      }
    }

    // VoiceWork
    await ref.read(dbProvider).insertMultipleVoiceWorks(vkc);

    // cv
    for (final cvName in cvNames) {
      cvc.add(TCVCompanion(
        cvName: Value(cvName),
        rowid: const Value.absent(),
      ));
    }
    await ref.read(dbProvider).insertMultipleCvs(cvc);

    // cv vk
    await ref.read(dbProvider).insertMultipleVoiceCvs(vcc);
  }

  Future<void> insertVoiceItems(Directory voiceWorkDir) async {
    List<TVoiceItemCompanion> vic = [];

    await for (final entity in voiceWorkDir.list(recursive: true)) {
      if (entity is File &&
          AUDIO_EXTENSIONS.any((ext) => entity.path.endsWith(ext))) {
        vic.add(TVoiceItemCompanion(
          title: Value(p.basenameWithoutExtension(entity.path)),
          filePath: Value(entity.path),
          voiceWorkPath: Value(voiceWorkDir.path),
          rowid: const Value.absent(),
        ));
      }
    }
    await ref.read(dbProvider).insertMultipleVoiceItems(vic);
  }
}
