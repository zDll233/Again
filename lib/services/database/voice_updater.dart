import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/database/db/database.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

class VoiceUpdater {
  VoiceUpdater(this._database, String rootDirPath)
      : _rootDir = Directory(rootDirPath);

  final AppDatabase _database;
  late final Directory _rootDir;

  Future<void> insert() async {
    await insertVoiceWorkCategories(); // categories
    await for (final categoryDir in _rootDir.list()) {
      if (categoryDir is Directory) {
        await insertVoiceWorks(categoryDir); // voiceWorks
        await for (final voiceWorkDir in categoryDir.list()) {
          if (voiceWorkDir is Directory) {
            await insertVoiceItems(voiceWorkDir); // voiceItems
          }
        }
      }
    }
  }

  /// parse vw.title to get cv list
  static List<String> getCvList(String vwTitle) {
    return vwTitle.split('-')[0].split('&');
  }

  static bool isSourceIdValid(String sourceId) =>
      RegExp(r'^(RJ|VJ|BJ)?\d+$', caseSensitive: false).hasMatch(sourceId);

  Future<void> insertVoiceWorkCategories() async {
    List<TVoiceWorkCategoryCompanion> vwcc = [];
    await for (final collectionDir in _rootDir.list()) {
      if (collectionDir is Directory) {
        vwcc.add(TVoiceWorkCategoryCompanion(
          description: Value(p.basename(collectionDir.path)),
          rowid: const Value.absent(),
        ));
      }
    }
    await _database.insertVoiceWorkCategoryBatch(vwcc);
  }

  Future<void> insertVoiceWorks(Directory collectionDir) async {
    List<TVoiceWorkCompanion> vwc = [];
    Set<String> cvNames = {};
    List<TCVCompanion> cvc = [];
    List<TVoiceCVCompanion> vcc = [];

    await for (final entity in collectionDir.list()) {
      if (entity is Directory) {
        String vwTitle = p.basename(entity.path);
        String vwCoverPath = '';
        String vwSourceId = '';

        // vw sourceId, cover
        await for (final e in entity.list(recursive: true)) {
          if (vwSourceId.isEmpty && e is Directory) {
            final folderName = p.basename(e.path);
            if (isSourceIdValid(folderName)) {
              vwSourceId = folderName.toUpperCase();
            }
          }

          if (e is File && IMG_EXTENSIONS.any((ext) => e.path.endsWith(ext))) {
            vwCoverPath = e.path;
            break;
          }
        }

        // VoiceWork
        vwc.add(TVoiceWorkCompanion(
          title: Value(vwTitle),
          sourceId: Value(vwSourceId),
          directoryPath: Value(entity.path),
          coverPath: Value(vwCoverPath),
          category: Value(p.basename(entity.parent.path)),
          createdAt: Value(await entity.stat().then((v) => v.changed)),
          rowid: const Value.absent(),
        ));

        List<String> singleVwCvNames = getCvList(vwTitle);

        // cv
        cvNames.addAll(singleVwCvNames);

        // cv vw
        for (final cvName in singleVwCvNames) {
          vcc.add(TVoiceCVCompanion(
            voiceWorkPath: Value(entity.path),
            cvName: Value(cvName),
            rowid: const Value.absent(),
          ));
        }
      }
    }

    // VoiceWork
    await _database.insertVoiceWorkBatch(vwc);

    // cv
    for (final cvName in cvNames) {
      cvc.add(TCVCompanion(
        cvName: Value(cvName),
        rowid: const Value.absent(),
      ));
    }
    await _database.insertCvBatch(cvc);

    // cv vw
    await _database.insertVoiceCvBatch(vcc);
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
    await _database.insertVoiceItemBatch(vic);
  }
}
