import 'dart:async';
import 'dart:io';

import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:audio_session/audio_session.dart' as session;
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;

class AudioNotifier extends Notifier<AudioState> {
  static const _sourceLoadTimeout = Duration(seconds: 10);
  static const _audioOperationTimeout = Duration(seconds: 5);

  ap.AudioPlayer? _windowsPlayer;
  ja.AudioPlayer? _androidPlayer;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Future<void>? _androidAudioSessionFuture;
  int _sourceRequestId = 0;
  bool _completionHandled = false;
  bool _isDisposed = false;

  @override
  AudioState build() {
    ref.onDispose(() {
      _isDisposed = true;
      unawaited(_disposePlayers());
    });

    if (Platform.isAndroid) {
      _androidPlayer = ja.AudioPlayer(
        handleInterruptions: false,
        handleAudioSessionActivation: false,
      );
      _initAndroidPlayer(_androidPlayer!);
    } else if (Platform.isWindows) {
      _windowsPlayer = ap.AudioPlayer();
      _initWindowsPlayer(_windowsPlayer!);
    } else {
      Log.error(
        'AudioNotifier is only supported on Android and Windows. '
        'Current platform: ${Platform.operatingSystem}.',
      );
    }

    return AudioState();
  }

  void _initWindowsPlayer(ap.AudioPlayer player) {
    Log.info('Windows audioplayers AudioPlayer initialized.');

    _runDetached(
      'Error configuring Windows audio release mode.',
      () => player.setReleaseMode(ap.ReleaseMode.release),
    );

    _subscriptions.add(
      player.onDurationChanged.listen(
        (duration) => _scheduleStateUpdate(
          'Error updating audio duration.',
          () => updateDuration(duration),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio duration.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.onPositionChanged.listen(
        (position) => _scheduleStateUpdate(
          'Error updating audio position.',
          () => updatePosition(position),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio position.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.onPlayerStateChanged.listen(
        (newPlayerState) => _scheduleStateUpdate(
          'Error updating Windows audio player state.',
          () => updatePlayState(_mapAudioplayersState(newPlayerState)),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError(
              'Error receiving Windows audio player state.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.onPlayerComplete.listen(
        (_) => _scheduleStateUpdate(
          'Error handling Windows audio completion.',
          _handlePlaybackComplete,
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError(
              'Error receiving Windows audio completion.', error, stackTrace);
        },
      ),
    );
  }

  void _initAndroidPlayer(ja.AudioPlayer player) {
    Log.info('Android just_audio AudioPlayer initialized.');

    _subscriptions.add(
      player.durationStream.listen(
        (duration) => _scheduleStateUpdate(
          'Error updating audio duration.',
          () => updateDuration(duration ?? Duration.zero),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio duration.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.positionStream.listen(
        (position) => _scheduleStateUpdate(
          'Error updating audio position.',
          () => updatePosition(position),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio position.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.playerStateStream.listen(
        (newPlayerState) => _scheduleStateUpdate(
          'Error updating Android audio player state.',
          () {
            updatePlayState(_mapJustAudioState(newPlayerState));
            if (newPlayerState.processingState ==
                ja.ProcessingState.completed) {
              _handlePlaybackComplete();
            } else {
              _completionHandled = false;
            }
          },
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError(
              'Error receiving Android audio player state.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.errorStream.listen(
        (error) {
          _logError(
            'Android just_audio playback error: ${error.code} ${error.message}',
            error,
            StackTrace.current,
          );
          _scheduleStateUpdate(
            'Error resetting audio state after playback failure.',
            _resetAfterSourceFailure,
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          _logError(
              'Error receiving Android playback error.', error, stackTrace);
        },
      ),
    );
  }

  AudioPlaybackState _mapAudioplayersState(ap.PlayerState playerState) {
    switch (playerState) {
      case ap.PlayerState.stopped:
        return AudioPlaybackState.stopped;
      case ap.PlayerState.paused:
        return AudioPlaybackState.paused;
      case ap.PlayerState.playing:
        return AudioPlaybackState.playing;
      case ap.PlayerState.completed:
        return AudioPlaybackState.completed;
      case ap.PlayerState.disposed:
        return AudioPlaybackState.stopped;
    }
  }

  AudioPlaybackState _mapJustAudioState(ja.PlayerState newPlayerState) {
    switch (newPlayerState.processingState) {
      case ja.ProcessingState.idle:
        return AudioPlaybackState.stopped;
      case ja.ProcessingState.loading:
      case ja.ProcessingState.buffering:
      case ja.ProcessingState.ready:
        return newPlayerState.playing
            ? AudioPlaybackState.playing
            : AudioPlaybackState.paused;
      case ja.ProcessingState.completed:
        return AudioPlaybackState.completed;
    }
  }

  void _handlePlaybackComplete() {
    if (_completionHandled || _isDisposed) {
      return;
    }
    _completionHandled = true;

    try {
      switch (state.playbackMode) {
        case PlaybackMode.sequentialPlay:
          final playingIdx = ref.read(voiceItemProvider).playingIndex;
          final len = ref.read(voiceItemProvider).playingValues.length;
          if (playingIdx == len - 1) {
            unawaited(stop());
          } else {
            playNext();
          }
          break;

        case PlaybackMode.singleRepeat:
          unawaited(_changeTrack(0));
          break;

        case PlaybackMode.shufflePlay:
          playNext();
          break;
      }
    } catch (error, stackTrace) {
      _logError('Error handling audio completion.', error, stackTrace);
    }
  }

  void updatePlayState(AudioPlaybackState newPlayerState) {
    state = state.copyWith(playerState: newPlayerState);
  }

  void updateDuration(Duration newDuration) {
    state = state.copyWith(duration: newDuration);
  }

  void updatePosition(Duration newPosition) {
    state = state.copyWith(position: newPosition);
  }

  /// Changes AudioState only; does not change the just_audio player volume.
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

  Future<bool> setSource(String playablePath) async {
    try {
      await _setSourcePath(playablePath);
      return true;
    } catch (error, stackTrace) {
      _logError('Error setting audio source.', error, stackTrace);
      return false;
    }
  }

  Future<void> _setSourcePath(String playablePath) async {
    _completionHandled = false;
    final requestId = ++_sourceRequestId;

    try {
      if (Platform.isAndroid) {
        await _configureAndroidAudioSession().timeout(_audioOperationTimeout);
        await _requireAndroidPlayer.setFilePath(playablePath).timeout(
              _sourceLoadTimeout,
              onTimeout: () => throw TimeoutException(
                'Timed out loading audio source: $playablePath',
                _sourceLoadTimeout,
              ),
            );
      } else if (Platform.isWindows) {
        await _requireWindowsPlayer
            .setSource(ap.DeviceFileSource(playablePath))
            .timeout(
              _sourceLoadTimeout,
              onTimeout: () => throw TimeoutException(
                'Timed out loading audio source: $playablePath',
                _sourceLoadTimeout,
              ),
            );
      } else {
        throw UnsupportedError(
          'Setting an audio source is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } on TimeoutException catch (error, stackTrace) {
      if (Platform.isAndroid) {
        _androidAudioSessionFuture = null;
      }
      _resetAfterSourceFailure(requestId);
      _logError(
          'Timed out loading audio source: $playablePath', error, stackTrace);
      rethrow;
    } catch (_) {
      _resetAfterSourceFailure(requestId);
      rethrow;
    }
  }

  Future<void> _configureAndroidAudioSession() async {
    final pendingConfiguration = _androidAudioSessionFuture;
    if (pendingConfiguration != null) {
      await pendingConfiguration;
      return;
    }

    final configuration = _configureAndroidAudioSessionOnce();
    _androidAudioSessionFuture = configuration;
    try {
      await configuration;
    } catch (_) {
      if (identical(_androidAudioSessionFuture, configuration)) {
        _androidAudioSessionFuture = null;
      }
      rethrow;
    }
  }

  Future<void> _configureAndroidAudioSessionOnce() async {
    final audioSession = await session.AudioSession.instance;
    await audioSession.configure(session.AudioSessionConfiguration.music());
  }

  Future<void> seek(Duration newPosition) async {
    try {
      if (Platform.isAndroid) {
        await _requireAndroidPlayer.seek(newPosition).timeout(
              _audioOperationTimeout,
            );
      } else if (Platform.isWindows) {
        await _requireWindowsPlayer.seek(newPosition).timeout(
              _audioOperationTimeout,
            );
      } else {
        throw UnsupportedError(
          'Seeking audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } catch (error, stackTrace) {
      _logError('Error seeking audio.', error, stackTrace);
    }
  }

  Future<bool> play(String playablePath) async {
    try {
      await _setSourcePath(playablePath);
      _startPlayback();
      return true;
    } catch (error, stackTrace) {
      _logError('Error playing audio.', error, stackTrace);
      return false;
    }
  }

  void _startPlayback() {
    try {
      if (Platform.isAndroid) {
        _runDetached('Error playing audio.', _requireAndroidPlayer.play);
      } else if (Platform.isWindows) {
        _runDetached('Error playing audio.', _requireWindowsPlayer.resume);
      } else {
        throw UnsupportedError(
          'Playing audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } catch (error, stackTrace) {
      _logError('Error playing audio.', error, stackTrace);
    }
  }

  void playNext() {
    unawaited(_changeTrack(1));
  }

  void playPrev() {
    unawaited(_changeTrack(-1));
  }

  Future<void> _changeTrack(int direction) async {
    try {
      final oldVoiceItemState = ref.read(voiceItemProvider);
      final len = oldVoiceItemState.playingValues.length;
      if (len == 0) {
        return;
      }

      int tempIdx = oldVoiceItemState.playingIndex + direction;
      if (tempIdx >= len) {
        tempIdx = 0;
      }
      if (tempIdx < 0) {
        tempIdx = len - 1;
      }

      ref.read(voiceItemProvider.notifier).changeTrack(tempIdx);
      final path = ref.read(voiceItemProvider).cachedPlayingVoiceItemPath;
      if (path == null) {
        throw StateError('No audio path exists for track index $tempIdx.');
      }
      await play(path);
    } catch (error, stackTrace) {
      _logError('Error changing audio track.', error, stackTrace);
    }
  }

  void pause() {
    try {
      if (Platform.isAndroid) {
        _runDetached('Error pausing audio.', _requireAndroidPlayer.pause);
      } else if (Platform.isWindows) {
        _runDetached('Error pausing audio.', _requireWindowsPlayer.pause);
      } else {
        throw UnsupportedError(
          'Pausing audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } catch (error, stackTrace) {
      _logError('Error pausing audio.', error, stackTrace);
    }
  }

  void resume() {
    try {
      if (Platform.isAndroid) {
        _runDetached('Error resuming audio.', _requireAndroidPlayer.play);
      } else if (Platform.isWindows) {
        _runDetached('Error resuming audio.', _requireWindowsPlayer.resume);
      } else {
        throw UnsupportedError(
          'Resuming audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } catch (error, stackTrace) {
      _logError('Error resuming audio.', error, stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      _sourceRequestId++;
      ref.read(voiceItemProvider.notifier).changeTrack(0);
      final firstItemPath =
          ref.read(voiceItemProvider).cachedPlayingVoiceItemPath;
      if (firstItemPath != null) {
        if (Platform.isAndroid) {
          await _requireAndroidPlayer.stop().timeout(_audioOperationTimeout);
        } else if (Platform.isWindows) {
          await _requireWindowsPlayer.stop().timeout(_audioOperationTimeout);
        } else {
          throw UnsupportedError(
            'Stopping audio is unsupported on ${Platform.operatingSystem}.',
          );
        }
        await _setSourcePath(firstItemPath);
      }
    } catch (error, stackTrace) {
      _logError('Error stopping audio.', error, stackTrace);
    }
  }

  Future<void> release() async {
    try {
      _sourceRequestId++;
      if (Platform.isAndroid) {
        // just_audio.stop() releases native playback resources while keeping
        // the player reusable for the next selected work.
        await _requireAndroidPlayer.stop().timeout(_audioOperationTimeout);
      } else if (Platform.isWindows) {
        await _requireWindowsPlayer.release().timeout(_audioOperationTimeout);
      } else {
        throw UnsupportedError(
          'Releasing audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
      updatePosition(Duration.zero);
      updateDuration(Duration.zero);
      ref.read(voiceWorkProvider.notifier).clearPlayingState();
      ref.read(voiceItemProvider.notifier).clearPlayingState();
    } catch (error, stackTrace) {
      _logError('Error releasing audio resource.', error, stackTrace);
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
      if (Platform.isAndroid) {
        _runDetached('Error setting volume.',
            () => _requireAndroidPlayer.setVolume(newVolume));
      } else if (Platform.isWindows) {
        _runDetached('Error setting volume.',
            () => _requireWindowsPlayer.setVolume(newVolume));
      } else {
        throw UnsupportedError(
          'Setting audio volume is unsupported on ${Platform.operatingSystem}.',
        );
      }
      _updateVolume(newVolume);
    } catch (error, stackTrace) {
      _logError('Error setting audio volume.', error, stackTrace);
    }
  }

  void switchPauseResume() {
    if (state.playerState == AudioPlaybackState.playing) {
      pause();
    } else {
      resume();
    }
  }

  void onPlaybackModePressed() {
    PlaybackMode nextMode;

    final uiService = ref.read(uiServiceProvider);
    switch (state.playbackMode) {
      case PlaybackMode.sequentialPlay:
        nextMode = PlaybackMode.singleRepeat;
        break;
      case PlaybackMode.singleRepeat:
        nextMode = PlaybackMode.shufflePlay;
        uiService.shufflePlayingState();
        break;
      case PlaybackMode.shufflePlay:
        nextMode = PlaybackMode.sequentialPlay;
        uiService.removeShuffledState();
        break;
    }

    updatePlaybackMode(nextMode);
  }

  void onPausePressed() {
    if (ref.read(voiceItemProvider).isPlaying) {
      switchPauseResume();
    }
  }

  void _scheduleStateUpdate(String operation, void Function() callback) {
    scheduleMicrotask(() {
      if (_isDisposed) {
        return;
      }
      try {
        callback();
      } catch (error, stackTrace) {
        _logError(operation, error, stackTrace);
      }
    });
  }

  void _runDetached(String operation, Future<void> Function() action) {
    try {
      final future = action();
      unawaited(
        future.then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            _logError(operation, error, stackTrace);
          },
        ),
      );
    } catch (error, stackTrace) {
      _logError(operation, error, stackTrace);
    }
  }

  Future<void> _disposePlayers() async {
    for (final subscription in _subscriptions) {
      try {
        await subscription.cancel();
      } catch (error, stackTrace) {
        _logError(
            'Error cancelling audio event subscription.', error, stackTrace);
      }
    }
    _subscriptions.clear();

    final androidPlayer = _androidPlayer;
    if (androidPlayer != null) {
      try {
        await androidPlayer.dispose();
      } catch (error, stackTrace) {
        _logError('Error disposing Android audio player.', error, stackTrace);
      }
      _androidPlayer = null;
    }

    final windowsPlayer = _windowsPlayer;
    if (windowsPlayer != null) {
      try {
        await windowsPlayer.dispose();
      } catch (error, stackTrace) {
        _logError('Error disposing Windows audio player.', error, stackTrace);
      }
      _windowsPlayer = null;
    }
  }

  ja.AudioPlayer get _requireAndroidPlayer {
    final player = _androidPlayer;
    if (player == null) {
      throw StateError('Android audio player is not initialized.');
    }
    return player;
  }

  ap.AudioPlayer get _requireWindowsPlayer {
    final player = _windowsPlayer;
    if (player == null) {
      throw StateError('Windows audio player is not initialized.');
    }
    return player;
  }

  void _resetAfterSourceFailure([int? requestId]) {
    if (_isDisposed) return;
    if (requestId != null && requestId != _sourceRequestId) return;
    state = state.copyWith(
      playerState: AudioPlaybackState.stopped,
      duration: Duration.zero,
      position: Duration.zero,
    );
    ref.read(voiceWorkProvider.notifier).clearPlayingState();
    ref.read(voiceItemProvider.notifier).clearPlayingState();
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    Log.error(message, error: error, stackTrace: stackTrace);
  }
}
