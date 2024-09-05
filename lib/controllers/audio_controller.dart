import 'package:again/controllers/u_i_controller.dart';
import 'package:again/utils/log.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:get/get.dart';

enum LoopMode {
  allLoop,
  singleLoop,
}

class AudioController extends GetxController {
  late final AudioPlayer player;
  final playerState = PlayerState.stopped.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;
  final volume = 1.0.obs;
  var lastVolume = 1.0;

  final playingViIdx = (-1).obs;
  List<String> playingViPathList = [];
  String get playingViPath => playingViPathList[playingViIdx.value];

  final loopMode = LoopMode.allLoop.obs;

  @override
  void onInit() {
    super.onInit();
    _initPlayer();
  }

  void _initPlayer() {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.release);

    // Initialize streams
    player.onDurationChanged.listen((d) {
      duration.value = d;
    });

    player.onPositionChanged.listen((p) {
      position.value = p;
    });

    player.onPlayerComplete.listen((event) {
      loopMode.value == LoopMode.allLoop
          ? playingViIdx.value == playingViPathList.length - 1
              ? stop()
              : playNext()
          : _changeTrack(0);
    });

    player.onPlayerStateChanged.listen((state) {
      playerState.value = state;
    });
  }

  Future<void> play(Source source) async {
    try {
      await player.setSource(source);
      await player.resume();
    } catch (e) {
      Log.error("Error playing audio. $e");
    }
  }

  void playNext() {
    _changeTrack(1);
  }

  void playPrev() {
    _changeTrack(-1);
  }

  void _changeTrack(int direction) {
    var temp = playingViIdx.value + direction;
    if (temp >= playingViPathList.length || temp < 0) return;
    playingViIdx.value = temp;
    play(DeviceFileSource(playingViPathList[playingViIdx.value]));
  }

  void resume() {
    try {
      player.resume();
    } catch (e) {
      Log.error("Error resuming audio. $e");
    }
  }

  void pause() {
    try {
      player.pause();
    } catch (e) {
      Log.error("Error pausing audio. $e");
    }
  }

  void stop() {
    try {
      player.stop();
      position.value = Duration.zero;
    } catch (e) {
      Log.error("Error stopping audio. $e");
    }
  }

  void onMutePressed() {
    if (volume.value != 0) {
      lastVolume = volume.value;
      setVolume(0);
    } else {
      setVolume(lastVolume);
    }
  }

  void setVolume(double v) {
    volume.value = v;
    player.setVolume(v);
  }

  void onLoopModePressed() {
    loopMode.value = loopMode.value == LoopMode.allLoop
        ? LoopMode.singleLoop
        : LoopMode.allLoop;
  }

  void switchPauseResume() {
    playerState.value == PlayerState.playing ? pause() : resume();
  }

  void onPausePressed() {
    if (playingViIdx.value >= 0) {
      switchPauseResume();
    }
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }

  Future<void> loadHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    setVolume(audioHistory['volume']);
    playingViPathList = Get.find<UIController>().selectedViPathList;
    loopMode.value = LoopMode.values[audioHistory['loopMode']];

    try {
      await player.setSource(DeviceFileSource(playingViPath));
      await player.seek(Duration(milliseconds: audioHistory['position']));
    } catch (e) {
      Log.error("Error loading audio history. $e");
    }
  }
}
