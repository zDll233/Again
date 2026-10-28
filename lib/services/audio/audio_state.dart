import 'package:again/services/ui/presentation/state_interface/base_state.dart';

enum PlaybackMode {
  sequentialPlay,
  singleRepeat,
  shufflePlay,
}

enum AudioPlaybackState {
  stopped,
  paused,
  playing,
  completed,
}

extension PlaybackModeExtension on PlaybackMode {
  static PlaybackMode fromString(String value) {
    return PlaybackMode.values.firstWhere(
      (e) => e.toString() == value,
    );
  }
}

class AudioState extends BaseState {
  final AudioPlaybackState playerState;
  final Duration duration;
  final Duration position;
  final double volume;
  final double lastVolume;
  final PlaybackMode playbackMode;

  /// 左右声道是否对调 (实时生效, 状态持久化在 config.json 的 channelSwap)。
  final bool channelSwap;

  AudioState({
    this.playerState = AudioPlaybackState.stopped,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.volume = 1.0,
    this.lastVolume = 1.0,
    this.playbackMode = PlaybackMode.sequentialPlay,
    this.channelSwap = false,
  });

  @override
  AudioState copyWith({
    AudioPlaybackState? playerState,
    Duration? duration,
    Duration? position,
    double? volume,
    double? lastVolume,
    PlaybackMode? playbackMode,
    bool? channelSwap,
  }) {
    return AudioState(
      playerState: playerState ?? this.playerState,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      volume: volume ?? this.volume,
      lastVolume: lastVolume ?? this.lastVolume,
      playbackMode: playbackMode ?? this.playbackMode,
      channelSwap: channelSwap ?? this.channelSwap,
    );
  }

  bool get isPlaying => playerState == AudioPlaybackState.playing;
  bool get isShufflePlay => playbackMode == PlaybackMode.shufflePlay;
}
