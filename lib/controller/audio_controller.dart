import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
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
        play(getSource(playingViPathList[++playingViIdx.value]));
      }
    });

    player.onPlayerStateChanged.listen((state) {
      playerState.value = state;
    });
  }

  void setSelectedVkTitle(String title) {
    selectedVkTitle.value = title;
  }

  Source getSource(String path) {
    return DeviceFileSource(path);
  }

  Future<void> play(Source source) async {
    await player.stop();
    await player.setSource(source);
    await player.resume();
    playerState.value = PlayerState.playing;
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
