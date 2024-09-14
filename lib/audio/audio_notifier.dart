import 'package:again/audio/audio_state.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/utils/log.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;

  void _initPlayer() {
    Log.info('AudioPlayer initialized.', simplePrint: true);

    _player.setReleaseMode(ReleaseMode.release);

    _player.onDurationChanged.listen((d) {
      updateDuration(d);
    });
    _player.onPositionChanged.listen((p) {
      updatePosition(p);
    });
    _player.onPlayerStateChanged.listen((s) {
      updatePlayState(s);
    });
  }

  void dispose() {
    _player.dispose();
  }

  @override
  AudioState build() {
    _player = AudioPlayer();
    _initPlayer();
    return AudioState();
  }

  void updatePlayState(PlayerState newPlayerState) {
    state = state.copyWith(playerState: newPlayerState);
  }

  void updateDuration(Duration newDuration) {
    state = state.copyWith(duration: newDuration);
  }

  void updatePosition(Duration newPosition) {
    state = state.copyWith(position: newPosition);
  }

  void updateVolume(double newVolume) {
    state = state.copyWith(volume: newVolume);
  }

  void updateLastVolume(double newLastVolume) {
    state = state.copyWith(lastVolume: newLastVolume);
  }

  void updateLoopMode(LoopMode newLoopMode) {
    state = state.copyWith(loopMode: newLoopMode);
  }

  void updateState(AudioState newState) {
    state = newState;
  }

  Future<void> setSource(String playablePath) async {
    await _player.setSource(DeviceFileSource(playablePath));
  }

  Future<void> seek(Duration newPosition) async{
    try {
      _player.seek(newPosition);
    } catch (e) {
      Log.error('Error seeking audio.\n$e');
    }
  }

  Future<void> play(Source source) async {
    try {
      await _player.setSource(source);
      await _player.resume();
    } catch (e) {
      Log.error('Error playing audio: $e');
    }
  }

  void playNext() {
    _changeTrack(1);
  }

  void playPrev() {
    _changeTrack(-1);
  }

  void _changeTrack(int direction) {
    var temp = ref.read(voiceItemProvider).playingIndex + direction;
    if (temp >= ref.read(voiceItemProvider).playingValues.length || temp < 0) {
      return;
    }

    ref.read(voiceItemProvider.notifier).updatePlayingIndex(temp);
    play(DeviceFileSource(ref.read(voiceItemProvider).playingVoiceItemPath));
  }

  void pause() {
    try {
      _player.pause();
    } catch (e) {
      Log.error('Error pausing audio.\n$e');
    }
  }

  void resume() {
    try {
      _player.resume();
    } catch (e) {
      Log.error('Error resuming audio.\n$e');
    }
  }

  void stop() {
    try {
      _player.stop();
      updatePosition(Duration.zero);
    } catch (e) {
      Log.error('Error stopping audio.\n$e');
    }
  }

  Future<void> release() async {
    try {
      await _player.release();
      updatePosition(Duration.zero);
      updateDuration(Duration.zero);
      ref.watch(voiceWorkProvider.notifier).updatePlayingIndex(-1);
      ref.watch(voiceItemProvider.notifier).updatePlayingIndex(-1);
    } catch (e) {
      Log.error('Error releasing audio resource.\n$e');
    }
  }

  void onMutePressed() {
    if (state.volume != 0) {
      updateLastVolume(state.volume);
      updateVolume(0);
    } else {
      updateVolume(state.lastVolume);
    }
  }

  void setVolume(double newVolume) {
    try {
      _player.setVolume(newVolume);
      updateVolume(newVolume);
    } catch (e) {
      Log.error('Error setting volume.\n$e');
    }
  }

  void switchPauseResume() {
    if (state.playerState == PlayerState.playing) {
      pause();
    } else {
      resume();
    }
  }

  void onLoopModePressed() {
    updateLoopMode(state.loopMode == LoopMode.allLoop
        ? LoopMode.singleLoop
        : LoopMode.allLoop);
  }

  void onPausePressed() {
    if (ref.read(voiceItemProvider).isPlaying) {
      switchPauseResume();
    }
  }

  Future<void> loadHistory(Map<String, dynamic> audioHistory) async {
    if (audioHistory.isEmpty) return;

    setVolume(audioHistory['volume']);

    ref.read(voiceItemProvider.notifier).updatePlayingValues();
    updateLoopMode(LoopMode.values[audioHistory['loopMode']]);

    try {
      await setSource(ref.read(voiceItemProvider).playingVoiceItemPath);
      await seek(Duration(milliseconds: audioHistory['position']));
    } catch (e) {
      Log.error('Error loading audio history.\n$e');
    }
  }
}
