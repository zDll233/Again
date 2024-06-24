import 'dart:io';

import 'package:again/controller/u_i_controller.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:path/path.dart' as p;
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
  var playingViPathList = [];

  final loopMode = LoopMode.allLoop.obs;

  late final Logger _logger;

  @override
  void onInit() {
    super.onInit();
    _initPlayer();
    _initLogger();
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
      _logger.e('Error playing audio: $e');
    }
  }

  void playNext() {
    _changeTrack(1);
  }

  void playPrev() {
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

  void resume() {
    try {
      player.resume();
    } catch (e) {
      _logger.e('Error resuming audio: $e');
    }
  }

  void pause() {
    try {
      player.pause();
    } catch (e) {
      _logger.e('Error pausing audio: $e');
    }
  }

  void stop() {
    try {
      player.stop();
      position.value = Duration.zero;
    } catch (e) {
      _logger.e('Error stopping audio: $e');
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
    _logger.close();
    player.dispose();
    super.onClose();
  }

  Future<void> loadHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    setVolume(audioHistory['volume']);
    playingViIdx.value = audioHistory['vi'];
    playingViPathList = Get.find<UIController>().selectedViPathList.toList();
    loopMode.value = LoopMode.values[audioHistory['loopMode']];

    try {
      await player
          .setSource(DeviceFileSource(playingViPathList[playingViIdx.value]));
      await player.seek(Duration(milliseconds: audioHistory['position']));
    } catch (e) {
      _logger.e('Error loading last audio: $e');
    }
  }
}
