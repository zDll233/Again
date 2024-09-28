import 'dart:async';
import 'package:again/services/audio/audio_notifier.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeyEventHandler {
  Timer? _seekTimer;
  Timer? _volumeTimer;
  final WidgetRef ref;
  late final AudioNotifier audioNotifier;

  KeyEventHandler(this.ref) : audioNotifier = ref.read(audioProvider.notifier);

  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      return _handleKeyDownEvent(event);
    } else if (event is KeyUpEvent) {
      return _handleKeyUpEvent(event);
    }
    return false;
  }

  bool _handleKeyDownEvent(KeyDownEvent event) {
    if (HardwareKeyboard.instance.isControlPressed) {
      return _handleControlKeyDownEvent(event);
    } else {
      return _handleNonControlKeyDownEvent(event);
    }
  }

  bool _handleControlKeyDownEvent(KeyDownEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        audioNotifier.playPrev();
        return true;
      case LogicalKeyboardKey.arrowRight:
        audioNotifier.playNext();
        return true;
      case LogicalKeyboardKey.arrowUp:
        ref.read(miscUIProvider.notifier).showLyricPanel();
        return true;
      case LogicalKeyboardKey.arrowDown:
        ref.read(miscUIProvider.notifier).hideLyricPanel();
        return true;
      default:
        return false;
    }
  }

  bool _handleNonControlKeyDownEvent(KeyDownEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        audioNotifier.onPausePressed();
        return true;
      case LogicalKeyboardKey.arrowLeft:
        _startTimer(_seekTimer, () => updateProgress(-10000),
            (newTimer) => _seekTimer = newTimer);
        return true;
      case LogicalKeyboardKey.arrowRight:
        _startTimer(_seekTimer, () => updateProgress(10000),
            (newTimer) => _seekTimer = newTimer);
        return true;
      case LogicalKeyboardKey.arrowDown:
        _startTimer(_volumeTimer, () => updateVolume(-0.1),
            (newTimer) => _volumeTimer = newTimer);
        return true;
      case LogicalKeyboardKey.arrowUp:
        _startTimer(_volumeTimer, () => updateVolume(0.1),
            (newTimer) => _volumeTimer = newTimer);
        return true;
      default:
        return false;
    }
  }

  bool _handleKeyUpEvent(KeyUpEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        _stopTimer(_seekTimer);
        return true;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowUp:
        _stopTimer(_volumeTimer);
        return true;
      default:
        return false;
    }
  }

  void updateProgress(int deltaMilliseconds) {
    audioNotifier.seek(Duration(
        milliseconds: ref.read(audioProvider).position.inMilliseconds +
            deltaMilliseconds));
  }

  void updateVolume(double deltaVolume) {
    audioNotifier.setVolume(
        (ref.read(audioProvider).volume + deltaVolume).clamp(0.0, 1.0));
  }

  void _startTimer(
      Timer? timer, void Function() action, void Function(Timer) onTimerUpdate,
      {int initDelay = 400, periodicDelay = 100}) {
    _stopTimer(timer);
    action();

    Timer newTimer = Timer(Duration(milliseconds: initDelay), () {
      Timer periodicTimer =
          Timer.periodic(Duration(milliseconds: periodicDelay), (_) {
        action();
      });
      onTimerUpdate(periodicTimer);
    });
    onTimerUpdate(newTimer);
  }

  void _stopTimer(Timer? timer) {
    timer?.cancel();
    timer = null;
  }
}
