import 'dart:io';

import 'package:again/controller/u_i_controller.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:path/path.dart' as p;
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class AudioController extends GetxController {
  late AudioPlayer player;
  var playerState = PlayerState.stopped.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var volume = 1.0.obs;
  var lastVolume = 0.0;

  var playingViIdx = (-1).obs;
  var playingViPathList = [];

  late final Logger _logger;

  @override
  void onInit() async {
    super.onInit();
    _initPlayer();
    await _initLogger();
  }

  Future<void> _initLogger() async {
    final String logPath = p.join('debug', 'audio.log');
    final File logFile = File(logPath);
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }
    _logger = Logger(
        printer: PrettyPrinter(methodCount: 2, colors: false, printTime: true),
        level: Level.error,
        output: FileOutput(file: logFile));
  }

  void _initPlayer() {
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
      _logger.e('Error playing audio: $e');
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
      _logger.e('Error resuming audio: $e');
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
      playerState.value = PlayerState.paused;
    } catch (e) {
      _logger.e('Error pausing audio: $e');
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
      _logger.e('Error stopping audio: $e');
    }
  }

  Future<void> onMutePressed() async {
    if (volume.value != 0) {
      lastVolume = volume.value;
      setVolume(0);
    } else {
      setVolume(lastVolume);
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

  Future<void> loadCache(Map<String, dynamic> audioCache) async {
    if (audioCache.isEmpty) return;

    volume.value = audioCache['volume'];
    playingViIdx.value = audioCache['vi'];
    await Get.find<UIController>().onViSelected(playingViIdx.value);
    await player.seek(Duration(milliseconds: audioCache['position'].round()));
    await pause();
  }
}
