import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  late AudioPlayer player;
  var playerState = PlayerState.stopped.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var volume = 1.0.obs;
  var leastVolume = 0.0;

  var playingViIdx = (-1).obs;
  var playingViPathList = [];

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
    play(DeviceFileSource(playingViPathList[playingViIdx.value]));
  }

  Future<void> playPrev() async {
    playingViIdx--;
    if (playingViIdx < 0) {
      playingViIdx.value = 0;
    }
    play(DeviceFileSource(playingViPathList[playingViIdx.value]));
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

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
