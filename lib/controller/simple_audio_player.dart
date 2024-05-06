import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'package:again/database/database.dart';
import 'package:again/screens/player_widget.dart';

class SimpleAudioPlayer extends StatefulWidget {
  const SimpleAudioPlayer({super.key});

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late AudioPlayer player = AudioPlayer();

  Future<List<File>> getWavList() async {
    List<File> wavList = [];

    // Get the system temp directory.
    var systemTempDir = Directory(
        'E:\\Media\\ACG\\音声\\Marked\\陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～');

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    await for (var entity
        in systemTempDir.list(recursive: true, followLinks: true)) {
      if (entity is File && entity.path.endsWith('.wav')) {
        wavList.add(entity);
      }
    }
    return wavList;
  }

  @override
  void initState() {
    super.initState();

    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    //==============================
    final database = AppDatabase();
    Future<List<TVoiceItemData>> allItems = (() async {
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

      return await database.select(database.tVoiceItem).get();
    })();
    //==============================

    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await player.setSource(AssetSource('songs/song01.flac'));

      // await player.setSource(DeviceFileSource(
      //     await getWavList().then((List<File> wavList) => wavList[0].path)));

      await player.setSource(DeviceFileSource(await allItems.then(
          (List<TVoiceItemData> voiceItemList) => voiceItemList[0].filePath)));

      // await player.setSource(DeviceFileSource(await database
      //     .select(database.voiceItem)
      //     .get()
      //     .then((List<VoiceItemData> vec) => vec[0].filePath)));

      // await player.setSource(DeviceFileSource('E:\\Media\\Songs\\sprnova - Mikawa.flac'));

      // await player.resume();
    });
  }

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerWidget(player: player);
  }
}
