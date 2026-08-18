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

/// AudioService 只在进入播放状态时才 startForeground。ColorOS 的
/// AudioHardening 会在播放器注册时检查前台服务, 若此时 FGS 尚未前台
/// (level: partial) 会把播放静音 (输出静音数据), 导致播放配置非活跃、
/// OPPO 应用音量面板不显示。因此在初始化完成后立即发布一次瞬时
/// playing 状态触发 startForeground, 再恢复为暂停 (androidStopForegroundOnPause
/// 默认 false, 前台服务会保持), 保证任何播放器创建时 FGS 已在前台。
void ensureAudioServiceForeground() {
  const controls = [
    MediaControl.skipToPrevious,
    MediaControl.play,
    MediaControl.skipToNext,
  ];
  PlaybackState state(bool playing) => PlaybackState(
        controls: controls,
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: playing,
      );
  againAudioHandler.playbackState.add(state(true));
  againAudioHandler.playbackState.add(state(false));
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
    artUri:
        (coverPath == null || coverPath.isEmpty) ? null : Uri.file(coverPath),
  ));
}
