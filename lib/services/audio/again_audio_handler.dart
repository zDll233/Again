import 'package:audio_service/audio_service.dart';

/// 媒体通知/锁屏控制桥接: 把 audio_service 的控制请求转发给现有
/// AudioNotifier (通过回调注入), 并把播放状态镜像为通知栏 UI。
/// 仅 Android 使用; Windows 不初始化 audio_service。
class AgainAudioHandler extends BaseAudioHandler {
  void Function()? onPlayPressed;
  void Function()? onPausePressed;
  void Function()? onNextPressed;
  void Function()? onPrevPressed;
  void Function(Duration)? onSeek;
  void Function()? onStopPressed;

  @override
  Future<void> play() async => onPlayPressed?.call();

  @override
  Future<void> pause() async => onPausePressed?.call();

  @override
  Future<void> seek(Duration position) async => onSeek?.call(position);

  @override
  Future<void> skipToNext() async => onNextPressed?.call();

  @override
  Future<void> skipToPrevious() async => onPrevPressed?.call();

  @override
  Future<void> stop() async => onStopPressed?.call();
}

/// 全局单例 (AudioService.init 的 builder 只调用一次, 回调由桥接层注入)。
final AgainAudioHandler againAudioHandler = AgainAudioHandler();
