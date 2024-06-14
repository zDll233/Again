import 'package:again/controller/controller.dart';
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

  final Controller c = Get.find();

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
        _stopPlayer();
      } else {
        playNext();
      }
    });

    player.onPlayerStateChanged.listen((state) {
      playerState.value = state;
    });
  }

  Future<void> play(Source source) async {
    try {
      await player.stop();
      await player.setSource(source);
      await player.resume();
      playerState.value = PlayerState.playing;
    } catch (e) {
      c.logger.e('Error playing audio: $e');
    }
  }

  Future<void> playNext() async {
    _changeTrack(1);
  }

  Future<void> playPrev() async {
    _changeTrack(-1);
  }

  void _changeTrack(int direction) {
    playingViIdx.value += direction;
    if (playingViIdx.value >= playingViPathList.length) {
      playingViIdx.value = playingViPathList.length - 1;
    } else if (playingViIdx.value < 0) {
      playingViIdx.value = 0;
    }
    play(DeviceFileSource(playingViPathList[playingViIdx.value]));
  }

  Future<void> resume() async {
    try {
      await player.resume();
      playerState.value = PlayerState.playing;
    } catch (e) {
      c.logger.e('Error resuming audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
      playerState.value = PlayerState.paused;
    } catch (e) {
      c.logger.e('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    await _stopPlayer();
  }

  Future<void> _stopPlayer() async {
    try {
      await player.stop();
      playerState.value = PlayerState.stopped;
      position.value = Duration.zero;
    } catch (e) {
      c.logger.e('Error stopping audio: $e');
    }
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
    await player.setVolume(v);
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
