import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;

  void _initPlayer() {
    Log.info('AudioPlayer initialized.');

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

    _player.onPlayerComplete.listen((event) {
      state.playbackMode == PlaybackMode.sequentialPlay
          ? ref.read(voiceItemProvider).playingIndex ==
                  ref.read(voiceItemProvider).playingValues.length - 1
              ? stop()
              : playNext()
          : _changeTrack(0);
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

  /// change audioState only, will *not* change audioplayer volume.
  void _updateVolume(double newVolume) {
    state = state.copyWith(volume: newVolume);
  }

  void updateLastVolume(double newLastVolume) {
    state = state.copyWith(lastVolume: newLastVolume);
  }

  void updatePlaybackMode(PlaybackMode newPlaybackMode) {
    state = state.copyWith(playbackMode: newPlaybackMode);
  }

  void updateState(AudioState newState) {
    state = newState;
  }

  Future<void> setSource(String playablePath) async {
    await _player.setSource(DeviceFileSource(playablePath));
  }

  Future<void> seek(Duration newPosition) async {
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

  Future<void> _changeTrack(int direction) async {
    final oldVoiceItemState = ref.read(voiceItemProvider);
    final temp = oldVoiceItemState.playingIndex + direction;
    if (temp >= oldVoiceItemState.playingValues.length || temp < 0) {
      return;
    }

    ref.read(voiceItemProvider.notifier).changeTrack(temp);
    await play(DeviceFileSource(
        ref.read(voiceItemProvider).cachedPlayingVoiceItemPath!));
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

  Future<void> stop() async {
    try {
      await _changeTrack(0);
      pause();
    } catch (e) {
      Log.error('Error stopping audio.\n$e');
    }
  }

  Future<void> release() async {
    try {
      await _player.release();
      updatePosition(Duration.zero);
      updateDuration(Duration.zero);
      ref.read(voiceWorkProvider.notifier).clearPlayingState();
      ref.read(voiceItemProvider.notifier).clearPlayingState();
    } catch (e) {
      Log.error('Error releasing audio resource.\n$e');
    }
  }

  void onMutePressed() {
    if (state.volume != 0) {
      updateLastVolume(state.volume);
      setVolume(0);
    } else {
      setVolume(state.lastVolume);
    }
  }

  void setVolume(double newVolume) {
    try {
      _player.setVolume(newVolume);
      _updateVolume(newVolume);
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

  void onPlaybackModePressed() {
    updatePlaybackMode(state.playbackMode == PlaybackMode.sequentialPlay
        ? PlaybackMode.singleRepeat
        : PlaybackMode.sequentialPlay);
  }

  void onPausePressed() {
    if (ref.read(voiceItemProvider).isPlaying) {
      switchPauseResume();
    }
  }
}
