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
        _startSeekTimer(-10000);
        return true;
      case LogicalKeyboardKey.arrowRight:
        _startSeekTimer(10000);
        return true;
      case LogicalKeyboardKey.arrowDown:
        _startVolmueTimer(-0.1);
        return true;
      case LogicalKeyboardKey.arrowUp:
        _startVolmueTimer(0.1);
        return true;
      default:
        return false;
    }
  }

  bool _handleKeyUpEvent(KeyUpEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowRight:
        _stopSeekTimer();
        return true;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.arrowUp:
        _stopVolumeTimer();
        return true;
      default:
        return false;
    }
  }

  void _startSeekTimer(int deltaMilliseconds) {
    _stopSeekTimer(); // cancel last timer, avoid shaking progress

    audio.player.seek(Duration(
        milliseconds: audio.position.value.inMilliseconds + deltaMilliseconds));

    _seekTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _seekTimer?.cancel();
      _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        audio.player.seek(Duration(
            milliseconds:
                audio.position.value.inMilliseconds + deltaMilliseconds));
      });
    });
  }

  void _startVolmueTimer(double deltaVolume) {
    _stopVolumeTimer();

    audio.setVolume((audio.volume.value + deltaVolume).clamp(0.0, 1.0));

    _volumeTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _volumeTimer?.cancel();
      _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        audio.setVolume((audio.volume.value + deltaVolume).clamp(0.0, 1.0));
      });
    });
  }

  void _stopSeekTimer() {
    _seekTimer?.cancel();
    _seekTimer = null;
  }

  void _stopVolumeTimer() {
    _volumeTimer?.cancel();
    _volumeTimer = null;
  }
}
