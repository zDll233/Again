import 'dart:async';
import 'package:again/controllers/audio_controller.dart';
import 'package:again/controllers/u_i_controller.dart';
import 'package:flutter/services.dart';

class KeyEventHandler {
  final AudioController audio;
  final UIController ui;
  Timer? _seekTimer;
  Timer? _volumeTimer;

  KeyEventHandler(this.audio, this.ui);

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
        audio.playPrev();
        return true;
      case LogicalKeyboardKey.arrowRight:
        audio.playNext();
        return true;
      case LogicalKeyboardKey.arrowUp:
        ui.showLrcPanel.value = true;
        return true;
      case LogicalKeyboardKey.arrowDown:
        ui.showLrcPanel.value = false;
        return true;
      default:
        return false;
    }
  }

  bool _handleNonControlKeyDownEvent(KeyDownEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        audio.onPausePressed();
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
    audio.player.seek(Duration(
        milliseconds: audio.position.value.inMilliseconds + deltaMilliseconds));
  }

  void updateVolume(double deltaVolume) {
    audio.setVolume((audio.volume.value + deltaVolume).clamp(0.0, 1.0));
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
