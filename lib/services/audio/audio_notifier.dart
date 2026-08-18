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
  ap.AudioPlayer? _windowsPlayer;
  ja.AudioPlayer? _androidPlayer;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Future<void>? _androidAudioSessionFuture;
  bool _completionHandled = false;
  bool _isDisposed = false;

  @override
  AudioState build() {
    ref.onDispose(() {
      _isDisposed = true;
      unawaited(_disposePlayers());
    });

    if (Platform.isAndroid) {
      _androidPlayer = ja.AudioPlayer();
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
    Log.info('Windows AudioPlayer initialized.');

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
          'Error updating audio player state.',
          () => updatePlayState(newPlayerState),
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio player state.', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      player.onPlayerComplete.listen(
        (_) => _scheduleStateUpdate(
          'Error handling audio completion.',
          _handlePlaybackComplete,
        ),
        onError: (Object error, StackTrace stackTrace) {
          _logError('Error receiving audio completion.', error, stackTrace);
        },
      ),
    );
  }

  void _initAndroidPlayer(ja.AudioPlayer player) {
    Log.info('Android AudioPlayer initialized.');

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
  }

  ap.PlayerState _mapJustAudioState(ja.PlayerState newPlayerState) {
    switch (newPlayerState.processingState) {
      case ja.ProcessingState.idle:
        return ap.PlayerState.stopped;
      case ja.ProcessingState.loading:
      case ja.ProcessingState.buffering:
      case ja.ProcessingState.ready:
        return newPlayerState.playing
            ? ap.PlayerState.playing
            : ap.PlayerState.paused;
      case ja.ProcessingState.completed:
        return ap.PlayerState.completed;
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

  void updatePlayState(ap.PlayerState newPlayerState) {
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
    try {
      await _setSourcePath(playablePath);
    } catch (error, stackTrace) {
      _logError('Error setting audio source.', error, stackTrace);
    }
  }

  Future<void> _setSourcePath(String playablePath) async {
    _completionHandled = false;

    if (Platform.isAndroid) {
      final player = _androidPlayer;
      if (player == null) {
        throw StateError('Android audio player is not initialized.');
      }
      await _configureAndroidAudioSession();
      await player.setFilePath(playablePath);
      return;
    }

    if (Platform.isWindows) {
      final player = _windowsPlayer;
      if (player == null) {
        throw StateError('Windows audio player is not initialized.');
      }
      await player.setSource(ap.DeviceFileSource(playablePath));
      return;
    }

    throw UnsupportedError(
      'Setting an audio source is unsupported on ${Platform.operatingSystem}.',
    );
  }

  Future<void> _setSource(ap.Source source) async {
    _completionHandled = false;

    if (Platform.isWindows) {
      final player = _windowsPlayer;
      if (player == null) {
        throw StateError('Windows audio player is not initialized.');
      }
      await player.setSource(source);
      return;
    }

    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Playing an audio source is unsupported on ${Platform.operatingSystem}.',
      );
    }

    final player = _androidPlayer;
    if (player == null) {
      throw StateError('Android audio player is not initialized.');
    }
    await _configureAndroidAudioSession();

    if (source is ap.DeviceFileSource) {
      await player.setFilePath(source.path);
    } else if (source is ap.UrlSource) {
      await player.setUrl(source.url);
    } else if (source is ap.AssetSource) {
      await player.setAsset(source.path);
    } else {
      throw UnsupportedError(
        'Android playback does not support ${source.runtimeType}.',
      );
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
        final player = _androidPlayer;
        if (player == null) {
          throw StateError('Android audio player is not initialized.');
        }
        await player.seek(newPosition);
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        await player.seek(newPosition);
      } else {
        throw UnsupportedError(
          'Seeking audio is unsupported on ${Platform.operatingSystem}.',
        );
      }
    } catch (error, stackTrace) {
      _logError('Error seeking audio.', error, stackTrace);
    }
  }

  Future<void> play(ap.Source source) async {
    try {
      await _setSource(source);
      if (Platform.isAndroid) {
        _startAndroidPlayback();
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        await player.resume();
      }
    } catch (error, stackTrace) {
      _logError('Error playing audio.', error, stackTrace);
    }
  }

  void _startAndroidPlayback() {
    final player = _androidPlayer;
    if (player == null) {
      _logError(
          'Error playing audio.',
          StateError('Android audio player is not initialized.'),
          StackTrace.current);
      return;
    }
    _runDetached('Error playing audio.', player.play);
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
      await play(ap.DeviceFileSource(path));
    } catch (error, stackTrace) {
      _logError('Error changing audio track.', error, stackTrace);
    }
  }

  void pause() {
    try {
      if (Platform.isAndroid) {
        final player = _androidPlayer;
        if (player == null) {
          throw StateError('Android audio player is not initialized.');
        }
        _runDetached('Error pausing audio.', player.pause);
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        _runDetached('Error pausing audio.', player.pause);
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
        final player = _androidPlayer;
        if (player == null) {
          throw StateError('Android audio player is not initialized.');
        }
        _runDetached('Error resuming audio.', player.play);
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        _runDetached('Error resuming audio.', player.resume);
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
      ref.read(voiceItemProvider.notifier).changeTrack(0);
      final firstItemPath =
          ref.read(voiceItemProvider).cachedPlayingVoiceItemPath;
      if (firstItemPath != null) {
        if (Platform.isAndroid) {
          final player = _androidPlayer;
          if (player == null) {
            throw StateError('Android audio player is not initialized.');
          }
          await player.stop();
        } else if (Platform.isWindows) {
          final player = _windowsPlayer;
          if (player == null) {
            throw StateError('Windows audio player is not initialized.');
          }
          await player.stop();
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
      if (Platform.isAndroid) {
        final player = _androidPlayer;
        if (player == null) {
          throw StateError('Android audio player is not initialized.');
        }
        // just_audio.stop() releases native playback resources while keeping
        // the player reusable for the next selected work.
        await player.stop();
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        await player.release();
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
        final player = _androidPlayer;
        if (player == null) {
          throw StateError('Android audio player is not initialized.');
        }
        _runDetached(
            'Error setting volume.', () => player.setVolume(newVolume));
      } else if (Platform.isWindows) {
        final player = _windowsPlayer;
        if (player == null) {
          throw StateError('Windows audio player is not initialized.');
        }
        _runDetached(
            'Error setting volume.', () => player.setVolume(newVolume));
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
    if (state.playerState == ap.PlayerState.playing) {
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

  void _logError(String message, Object error, StackTrace stackTrace) {
    Log.error(message, error: error, stackTrace: stackTrace);
  }
}
