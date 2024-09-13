import 'package:again/ui/states/state_interface.dart';
import 'package:audioplayers/audioplayers.dart';

enum LoopMode {
  allLoop,
  singleLoop,
}

class AudioState extends BaseState {
  final PlayerState playerState;
  final Duration duration;
  final Duration position;
  final double volume;
  final double lastVolume;
  final LoopMode loopMode;

  AudioState({
    this.playerState = PlayerState.stopped,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.volume = 1.0,
    this.lastVolume = 1.0,
    this.loopMode = LoopMode.allLoop,
  });

  @override
  AudioState copyWith({
    PlayerState? playerState,
    Duration? duration,
    Duration? position,
    double? volume,
    double? lastVolume,
    LoopMode? loopMode,
  }) {
    return AudioState(
      playerState: playerState ?? this.playerState,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      volume: volume ?? this.volume,
      lastVolume: lastVolume ?? this.lastVolume,
      loopMode: loopMode ?? this.loopMode,
    );
  }
}
