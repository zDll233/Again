import 'dart:async';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_engine.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 播放控制: 把 UI/托盘/媒体通知的操作转发给原生播放引擎, 并轮询引擎状态
/// 回填 [AudioState]。
///
/// 引擎实现见 [AudioEngine] (Windows: MF + WASAPI, Android: MediaCodec +
/// AudioTrack) — 引擎需要直接拿到 PCM 才能实时对调左右声道。
class AudioNotifier extends Notifier<AudioState> {
  static const _sourceLoadTimeout = Duration(seconds: 15);

  /// 状态轮询间隔 (位置/时长/播放状态), 与原先播放器的位置推送频率相当。
  static const _statusPollInterval = Duration(milliseconds: 200);

  final AudioEngine _engine = AudioEngine();
  Timer? _statusTimer;
  int _sourceRequestId = 0;
  bool _completionHandled = false;
  bool _isDisposed = false;
  bool _statusInFlight = false;

  @override
  AudioState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _stopStatusPolling();
      unawaited(_engine.dispose());
    });

    return AudioState();
  }

  // ---------------------------------------------------------------------------
  // 状态更新
  // ---------------------------------------------------------------------------

  void updatePlayState(AudioPlaybackState newPlayerState) {
    if (state.playerState == newPlayerState) return;
    state = state.copyWith(playerState: newPlayerState);
  }

  void updateDuration(Duration newDuration) {
    state = state.copyWith(duration: newDuration);
  }

  void updatePosition(Duration newPosition) {
    state = state.copyWith(position: newPosition);
  }

  /// 只改 AudioState, 不动引擎音量。
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

  // ---------------------------------------------------------------------------
  // 左右声道对调
  // ---------------------------------------------------------------------------

  void toggleChannelSwap() => setChannelSwap(!state.channelSwap);

  /// 实时对调左右声道。播放中调用立即生效, 不打断播放、不改变进度。
  ///
  /// [persist] 为 false 时只应用不写 config.json (启动恢复时用)。
  void setChannelSwap(bool value, {bool persist = true}) {
    if (state.channelSwap != value) {
      state = state.copyWith(channelSwap: value);
    }
    _runDetached(
      'Error setting channel swap.',
      () => _engine.setChannelSwap(value),
    );
    if (persist) {
      unawaited(_persistChannelSwap(value));
    }
  }

  Future<void> _persistChannelSwap(bool value) async {
    try {
      await ref
          .read(configJsonProvider)
          .mutate((config) => {...config, 'channelSwap': value});
    } catch (error, stackTrace) {
      _logError('Error persisting channel swap.', error, stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // 引擎状态轮询
  // ---------------------------------------------------------------------------

  void _startStatusPolling() {
    _statusTimer ??= Timer.periodic(
      _statusPollInterval,
      (_) => unawaited(_pollStatus()),
    );
  }

  void _stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  Future<void> _pollStatus() async {
    if (_isDisposed || _statusInFlight) return;
    _statusInFlight = true;
    try {
      final status = await _engine.status();
      if (_isDisposed || status == null) return;
      _applyStatus(status);
    } catch (error, stackTrace) {
      _logError('Error polling native audio status.', error, stackTrace);
    } finally {
      _statusInFlight = false;
    }
  }

  void _applyStatus(AudioEngineStatus status) {
    var next = state;
    if (next.position != status.position) {
      next = next.copyWith(position: status.position);
    }
    if (next.duration != status.duration) {
      next = next.copyWith(duration: status.duration);
    }
    if (next.playerState != status.state) {
      next = next.copyWith(playerState: status.state);
    }
    if (!identical(next, state)) {
      state = next;
    }

    if (status.state == AudioPlaybackState.completed) {
      if (!_completionHandled) {
        _handlePlaybackComplete();
      }
    } else {
      _completionHandled = false;
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

  // ---------------------------------------------------------------------------
  // 音源加载 / 播放控制
  // ---------------------------------------------------------------------------

  /// 加载音源 (不自动播放)。
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
    final requestId = ++_sourceRequestId;

    try {
      final accepted = await _engine.setSource(playablePath);
      if (requestId != _sourceRequestId) {
        // 已被更新的加载请求取代
        return;
      }
      if (!accepted) {
        throw StateError('Failed to load audio source: $playablePath');
      }
      await _awaitSourceReady(requestId, playablePath);
      if (requestId != _sourceRequestId) {
        return;
      }
      _completionHandled = false;
      _startStatusPolling();
      // 引擎会记住音量/声道设置, 但重开音源 (Android 会重建 AudioTrack)
      // 后补齐一次, 避免状态与引擎不一致。
      await _engine.setVolume(state.volume);
      await _engine.setChannelSwap(state.channelSwap);
    } on TimeoutException catch (error, stackTrace) {
      _resetAfterSourceFailure(requestId);
      _logError(
          'Timed out loading audio source: $playablePath', error, stackTrace);
      rethrow;
    } catch (_) {
      _resetAfterSourceFailure(requestId);
      rethrow;
    }
  }

  /// 等待原生端完成解码器/输出设备准备 (通常几十~几百毫秒)。
  /// setSource 本身立即返回, 避免堵住平台线程。
  Future<void> _awaitSourceReady(int requestId, String playablePath) async {
    final deadline = DateTime.now().add(_sourceLoadTimeout);
    while (true) {
      final status = await _engine.status();
      if (requestId != _sourceRequestId) return;
      if (status == null) {
        throw StateError('Audio engine unavailable: $playablePath');
      }
      if (!status.isLoading) {
        final error = status.error;
        if (error != null) {
          throw StateError('Failed to load audio source: $error');
        }
        return;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
            'Timed out loading audio source: $playablePath', _sourceLoadTimeout);
      }
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  Future<void> seek(Duration newPosition) async {
    try {
      updatePosition(newPosition);
      await _engine.seek(newPosition);
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
    // 乐观更新: 引擎状态轮询有 200ms 间隔, 先让 UI (播放按钮/托盘) 立刻响应
    updatePlayState(AudioPlaybackState.playing);
    _runDetached('Error playing audio.', _engine.play);
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
    updatePlayState(AudioPlaybackState.paused);
    _runDetached('Error pausing audio.', _engine.pause);
  }

  void resume() {
    updatePlayState(AudioPlaybackState.playing);
    _runDetached('Error resuming audio.', _engine.play);
  }

  Future<void> stop() async {
    try {
      _sourceRequestId++;
      ref.read(voiceItemProvider.notifier).changeTrack(0);
      final firstItemPath =
          ref.read(voiceItemProvider).cachedPlayingVoiceItemPath;
      if (firstItemPath != null) {
        await _engine.stop();
        updatePosition(Duration.zero);
        updatePlayState(AudioPlaybackState.stopped);
        await _setSourcePath(firstItemPath);
      }
    } catch (error, stackTrace) {
      _logError('Error stopping audio.', error, stackTrace);
    }
  }

  Future<void> release() async {
    try {
      _sourceRequestId++;
      _stopStatusPolling();
      _completionHandled = false;
      await _engine.release();
      updatePosition(Duration.zero);
      updateDuration(Duration.zero);
      updatePlayState(AudioPlaybackState.stopped);
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
    _runDetached('Error setting volume.', () => _engine.setVolume(newVolume));
    _updateVolume(newVolume);
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

  // ---------------------------------------------------------------------------
  // 内部工具
  // ---------------------------------------------------------------------------

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

  void _resetAfterSourceFailure([int? requestId]) {
    if (_isDisposed) return;
    if (requestId != null && requestId != _sourceRequestId) return;
    _stopStatusPolling();
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
