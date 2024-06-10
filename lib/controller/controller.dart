import 'package:again/controller/voice_updater.dart';
import 'package:again/database/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  late AudioPlayer player;
  var playerState = PlayerState.stopped.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  var selectedVkTitle = "".obs;
  var selectedViPathList = [];

  var playingViIdx = (-1).obs;
  var playingViPathList = [];

  var vkTitleList = [].obs;
  var playingVkIdx = 0.obs;
  var selectedVkIdx = 0.obs;

  var vkScrollController = ScrollController();
  var vkOffsetMap = {};

  var volume = 1.0.obs;
  var leastVolume = 0.0;

  Future<void> onMutePressed() async {
    if (volume.value != 0) {
      leastVolume = volume.value;
      setVolume(0);
    } else {
      setVolume(leastVolume);
    }
  }

  Future<void> setVolume(double v) async {
    volume.value = v;
    player.setVolume(v);
  }

  Future<void> updateDatabase() async {
    await voiceUpdater.update();
    await updateVkTitleList();
  }

  Future<void> updateVkTitleList() async {
    var vkDataList = await database.selectAllVoiceWorks;
    vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
  }

  Future<void> onRefreshPressed() async {
    await database.transaction(() async {
      // Deleting tables in reverse topological order to avoid foreign-key conflicts
      final tables = database.allTables.toList().reversed;

      for (final table in tables) {
        await database.delete(table).go();
      }
    });

    updateDatabase();
  }

  void onLocateBtnPressed() {
    vkScrollController.animateTo(vkOffsetMap[playingVkIdx],
        duration: const Duration(microseconds: 300), curve: Curves.bounceIn);

    selectedVkIdx.value = playingVkIdx.value;
    setSelectedVkTitle(vkTitleList[playingVkIdx.value]);
  }

  void onVkSelected(int idx) {
    setSelectedVkTitle(vkTitleList[idx]);
    selectedVkIdx.value = idx;

    var offset = vkScrollController.offset;
    vkOffsetMap.update(idx, (value) => offset, ifAbsent: () => offset);
  }

  void onViSelected(int idx) {
    playingViIdx.value = idx;
    playingVkIdx.value = selectedVkIdx.value;
    playingViPathList = selectedViPathList.toList();

    Source source = DeviceFileSource(playingViPathList[idx]);
    play(source);
  }

  void setSelectedVkTitle(String title) {
    selectedVkTitle.value = title;
  }

  Source getSource(String path) {
    return DeviceFileSource(path);
  }

  @override
  void onInit() {
    super.onInit();
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);

    // Initialize streams
    player.onDurationChanged.listen((d) {
      duration.value = d;
    });

    player.onPositionChanged.listen((p) {
      position.value = p;
    });

    player.onPlayerComplete.listen((event) {
      if (playingViIdx.value == playingViPathList.length - 1) {
        playerState.value = PlayerState.stopped;
        position.value = Duration.zero;
      } else {
        playNext();
      }
    });

    player.onPlayerStateChanged.listen((state) {
      playerState.value = state;
    });

    updateVkTitleList();
  }

  Future<void> play(Source source) async {
    await player.stop();
    await player.setSource(source);
    await player.resume();
    playerState.value = PlayerState.playing;
  }

  Future<void> playNext() async {
    playingViIdx++;
    if (playingViIdx >= playingViPathList.length - 1) {
      playingViIdx.value = playingViPathList.length - 1;
    }

    play(getSource(playingViPathList[playingViIdx.value]));
  }

  Future<void> playPrev() async {
    playingViIdx--;
    if (playingViIdx < 0) {
      playingViIdx.value = 0;
    }

    play(getSource(playingViPathList[playingViIdx.value]));
  }

  Future<void> resume() async {
    await player.resume();
    playerState.value = PlayerState.playing;
  }

  Future<void> pause() async {
    await player.pause();
    playerState.value = PlayerState.paused;
  }

  Future<void> stop() async {
    await player.stop();
    playerState.value = PlayerState.stopped;
    position.value = Duration.zero;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
