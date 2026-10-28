import 'package:again/services/audio/audio_state.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/services.dart';

/// 播放引擎状态快照 (由原生层定时轮询得出)。
class AudioEngineStatus {
  const AudioEngineStatus({
    required this.position,
    required this.duration,
    required this.state,
    this.isLoading = false,
    this.error,
  });

  final Duration position;
  final Duration duration;
  final AudioPlaybackState state;

  /// 原生端仍在打开解码器/输出设备 (setSource 之后的准备阶段)。
  final bool isLoading;

  /// 原生端报告的加载/解码错误, 正常为 null。
  final String? error;
}

/// 播放引擎的 Dart 侧封装。
///
/// 为什么不用 audioplayers / just_audio: 播放中实时对调左右声道需要拿到
/// 解码后的 PCM 采样, 而这两个插件都是「交文件 → 黑盒解码 → 直接输出」,
/// 既不暴露采样数据, 也没有左右声道重定向的 API。因此两端各自用系统
/// 解码器 + 系统输出写了一个最小播放器, 统一通过 `again/audio` 这个
/// MethodChannel 控制:
///
/// - Windows: `windows/runner/again_audio_engine.cpp`
///   (Media Foundation Source Reader 解码 + WASAPI 共享模式输出)
/// - Android: `android/.../AgainAudioEngine.kt`
///   (MediaExtractor + MediaCodec 解码 + AudioTrack 输出)
///
/// 位置/时长/播放状态由 Dart 侧轮询 [status] 获得 (见 AudioNotifier),
/// 两端行为保持一致。
class AudioEngine {
  static const MethodChannel _channel = MethodChannel('again/audio');

  bool _disposed = false;

  /// 加载音源 (只加载, 不自动播放)。返回是否加载成功。
  Future<bool> setSource(String playablePath) async {
    try {
      final loaded = await _channel.invokeMethod<bool>(
        'setSource',
        <String, Object>{'path': playablePath},
      );
      return loaded ?? false;
    } catch (error, stackTrace) {
      _logError('Error setting native audio source.', error, stackTrace);
      return false;
    }
  }

  Future<void> play() => _invoke('play');

  Future<void> pause() => _invoke('pause');

  /// 停止播放并把位置复位到 0 (音源保持加载)。
  Future<void> stop() => _invoke('stop');

  /// 卸载音源并释放解码/输出资源。
  Future<void> release() => _invoke('release');

  Future<void> seek(Duration position) => _invoke(
        'seek',
        <String, Object>{'position': position.inMilliseconds},
      );

  Future<void> setVolume(double volume) => _invoke(
        'setVolume',
        <String, Object>{'volume': volume},
      );

  /// 实时对调左右声道; 播放过程中调用立即生效, 不影响播放进度。
  Future<void> setChannelSwap(bool swap) => _invoke(
        'setChannelSwap',
        <String, Object>{'swap': swap},
      );

  /// 读取当前位置/时长/播放状态; 引擎不可用时返回 null。
  Future<AudioEngineStatus?> status() async {
    if (_disposed) return null;
    try {
      final raw = await _channel.invokeMethod<Object?>('status');
      if (raw is! Map) return null;
      final positionMs = raw['position'];
      final durationMs = raw['duration'];
      final state = raw['state'];
      final loading = raw['loading'];
      final error = raw['error'];
      return AudioEngineStatus(
        position: Duration(milliseconds: positionMs is int ? positionMs : 0),
        duration: Duration(milliseconds: durationMs is int ? durationMs : 0),
        state: _mapState(state is int ? state : 0),
        isLoading: loading == true,
        error: error is String && error.isNotEmpty ? error : null,
      );
    } catch (error, stackTrace) {
      _logError('Error reading native audio status.', error, stackTrace);
      return null;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    // 先释放原生资源, 再把实例标记为已销毁 (否则 _invoke 会直接返回)。
    await _invoke('release');
    _disposed = true;
  }

  Future<void> _invoke(String method, [Object? arguments]) async {
    if (_disposed) return;
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } catch (error, stackTrace) {
      _logError('Error invoking native audio "$method".', error, stackTrace);
    }
  }

  static AudioPlaybackState _mapState(int state) {
    switch (state) {
      case 1:
        return AudioPlaybackState.playing;
      case 2:
        return AudioPlaybackState.paused;
      case 3:
        return AudioPlaybackState.completed;
      default:
        return AudioPlaybackState.stopped;
    }
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    Log.error(message, error: error, stackTrace: stackTrace);
  }
}
