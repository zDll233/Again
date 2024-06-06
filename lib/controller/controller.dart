import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  late AudioPlayer player;
  var playerState = PlayerState.stopped.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  var selectedVkTitle = "".obs;
  var selectedViPathList = [].obs;

  var playingViIdx = 0.obs;
  var playingViPathList = [].obs;

  var vkTitleList = [].obs;
  var playingVkIdx = 0.obs;
  var selectedVkIdx = 0.obs;

  var vkScrollController = ScrollController();
  var playingVkOffset = 0.0.obs;
  var latestSelectedVkOffset = 0.0.obs;

  void onLocateBtnPressed() {
    vkScrollController.animateTo(playingVkOffset.value,
        duration: const Duration(microseconds: 300), curve: Curves.bounceIn);

    selectedVkIdx.value = playingVkIdx.value;
    setSelectedVkTitle(vkTitleList[playingVkIdx.value]);
  }

  void onVkSelected(int idx) {
    setSelectedVkTitle(vkTitleList[idx]);
    selectedVkIdx.value = idx;
    latestSelectedVkOffset.value = vkScrollController.offset;
  }

  void onViSelected(int idx) {
    Source source = DeviceFileSource(selectedViPathList[idx]);
    play(source);

    playingViIdx.value = idx;
    playingVkIdx.value = selectedVkIdx.value;
    playingViPathList = selectedViPathList;
    playingVkOffset.value = latestSelectedVkOffset.value;
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
