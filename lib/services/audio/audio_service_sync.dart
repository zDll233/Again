import 'package:again/services/audio/again_audio_handler.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// 桥接 audio_service 与现有 AudioNotifier: 注入控制回调 + 镜像播放状态
/// 到媒体通知/锁屏界面。仅 Android 生效。
void initAudioServiceBridge(Ref ref) {
  againAudioHandler.onPlayPressed =
      () => ref.read(audioProvider.notifier).resume();
  againAudioHandler.onPausePressed =
      () => ref.read(audioProvider.notifier).pause();
  againAudioHandler.onNextPressed =
      () => ref.read(audioProvider.notifier).playNext();
  againAudioHandler.onPrevPressed =
      () => ref.read(audioProvider.notifier).playPrev();
  againAudioHandler.onSeek =
      (pos) => ref.read(audioProvider.notifier).seek(pos);
  againAudioHandler.onStopPressed =
      () => ref.read(audioProvider.notifier).release();

  // 播放状态/当前曲目变化 → 同步通知栏
  ref.listen<AudioState>(audioProvider, (prev, next) {
    _syncPlaybackState(next);
    _syncMediaItemIfChanged(next, ref);
  });
}

String? _lastMediaItemId;
Duration? _lastMediaItemDuration;

void _syncPlaybackState(AudioState state) {
  final playing = state.playerState == PlayerState.playing;
  againAudioHandler.playbackState.add(PlaybackState(
    controls: [
      MediaControl.skipToPrevious,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
    ],
    systemActions: const {MediaAction.seek},
    androidCompactActionIndices: const [0, 1, 2],
    processingState: AudioProcessingState.ready,
    playing: playing,
    updatePosition: state.position,
  ));
}

void _syncMediaItemIfChanged(AudioState state, Ref ref) {
  final vi = ref.read(voiceItemProvider);
  final path = vi.cachedPlayingVoiceItemPath;
  if (path == null) {
    _lastMediaItemId = null;
    _lastMediaItemDuration = null;
    return;
  }
  if (_lastMediaItemId == path && _lastMediaItemDuration == state.duration) {
    return;
  }
  _lastMediaItemId = path;
  _lastMediaItemDuration = state.duration;

  final vw = ref.read(voiceWorkProvider).cachedPlayingItem;
  final coverPath = vw?.coverPath;
  againAudioHandler.mediaItem.add(MediaItem(
    id: path,
    title: p.basenameWithoutExtension(path),
    artist: (vw?.sourceId.isEmpty ?? true) ? null : vw!.sourceId,
    duration: state.duration,
    artUri: (coverPath == null || coverPath.isEmpty)
        ? null
        : Uri.file(coverPath),
  ));
}
